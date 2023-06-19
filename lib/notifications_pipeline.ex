defmodule NotificationsPipeline do
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    qos: [prefetch_count: 100],
    queue: "notifications"
  ]

  def start_link(_args) do
    options = [
      name: NotificationsPipeline,
      batchers: [email: [batch_timeout: 3_000, concurrency: 5]],
      processors: [default: []],
      producer: [module: {@producer, @producer_config}]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    events = messages |> Enum.map(& &1.data.event) |> Enum.uniq() |> Enum.join(", ")

    Tickets.send_email(batch_info.batch_key, events)
    IO.inspect("#{events} for #{batch_info.batch_key}", label: "Booking succeeded")

    messages
  end

  def handle_message(_processor, message, _context) do
    message
    |> Broadway.Message.put_batcher(:email)
    |> Broadway.Message.put_batch_key(message.data.recipient)
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        [type, event, recipient] = String.split(data, ",")
        %{type: type, event: event, recipient: recipient}
      end)
    end)
  end
end
