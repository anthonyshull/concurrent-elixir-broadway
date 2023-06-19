defmodule BookingsPipeline do
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "bookings"
  ]

  def start_link(_args) do
    options = [
      name: BookingsPipeline,
      batchers: [default: [batch_size: 10]],
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_batch(_batcher, messages, _batch_info, _context) do
    messages
    |> Tickets.insert_all_tickets()
    |> Enum.each(fn message ->
      channel = message.metadata.amqp_channel
      payload = "email,#{message.data.event},#{message.data.user.email}"
      AMQP.Basic.publish(channel, "", "notifications", payload)
    end)

    messages
  end

  def handle_message(_processor, message, _context) do
    %{data: %{event: event}} = message

    if Tickets.tickets_available?(event) do
      Broadway.Message.put_batcher(message, :default)

      message
    else
      Broadway.Message.failed(message, "no_tickets_available")
    end
  end

  def prepare_messages(messages, _context) do
    messages =
      Enum.map(messages, fn message ->
        Broadway.Message.update_data(message, fn data ->
          [event, user_id] = String.split(data, ",")

          %{event: event, user_id: user_id}
        end)
      end)

    users = Tickets.users_by_ids(Enum.map(messages, & &1.data.user_id))

    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        user = Enum.find(users, fn user -> user.id == data.user_id end)

        Map.put(data, :user, user)
      end)
    end)
  end

  def handle_failed(messages, _context) do
    Enum.each(messages, fn message ->
      IO.inspect("#{message.data.event} for #{message.data.user.email}", label: "Booking failed")
    end)

    messages
  end
end
