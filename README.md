# Usage

```
%> docker run -d --hostname tickets --name tickets -p 5672:5672 -p 15672:15672 rabbitmq:management
%> iex -S mix
```

Go to `http://localhost:15672` and use the credentials `u: guest` and `p: guest`.

In the `bookings` queue, you can publish messages.

The message `musical,1` will result in:
```
Successful message: %{event: "musical", user: %{email: "foo@internet.com", id: "1"}, user_id: "1"}
```

The message `cinema,1` will result in:
```
Failed message: %{event: "cinema", user: %{email: "foo@internet.com", id: "1"}, user_id: "1"}
```