send_messages = fn n ->
  {:ok, connection} = AMQP.Connection.open()
  {:ok, channel} = AMQP.Channel.open(connection)

  Enum.each(1..n, fn _ ->
    event = Enum.random(["cinema", "theatre", "concert", "opera"])
    user_id = Enum.random(1..3)
    AMQP.Basic.publish(channel, "", "bookings", "#{event},#{user_id}")
  end)

  AMQP.Connection.close(connection)
end
