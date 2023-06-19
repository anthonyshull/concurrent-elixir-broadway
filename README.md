# Usage

```
%> docker run -d --hostname tickets --name tickets -p 5672:5672 -p 15672:15672 rabbitmq:management
%> iex -S mix
```

```elixir
iex> send_messages.(50)
```