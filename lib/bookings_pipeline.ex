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
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    %{data: %{event: event, user: user}} = message

    if Tickets.tickets_available?(event) do
      Tickets.create_ticket(user, event)
      Tickets.send_email(user)

      IO.inspect(message.data, label: "Successful message")

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
      IO.inspect(message.data, label: "Failed message")
    end)

    messages
  end
end
