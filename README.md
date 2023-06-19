# Usage

```
%> docker run -d --hostname tickets --name tickets -p 5672:5672 -p 15672:15672 rabbitmq:management
%> iex -S mix
```

```elixir
iex> send_messages.(10)
```

You'll see some failed bookings for 'opera' as there are no tickets for the event.

You'll see *at most* three successful booking notifications after the three second window has elapsed.
We are batching notifications by email address so that anyone booking multiple events only gets one notification rather than N number.