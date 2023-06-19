defmodule Tickets do
  @users [
    %{id: "1", email: "foo@internet.com"},
    %{id: "2", email: "bar@internet.com"},
    %{id: "3", email: "baz@internet.com"}
  ]

  def insert_all_tickets(messages) do
    Process.sleep(Enum.count(messages) * 5)

    messages
  end

  def create_ticket(_user, _event) do
    Process.sleep(Enum.random(100..200))
  end

  def send_email(_user, _message) do
    Process.sleep(Enum.random(100..200))
  end

  def tickets_available?("opera") do
    Process.sleep(Enum.random(100..200))

    false
  end

  def tickets_available?(_event) do
    Process.sleep(Enum.random(100..200))

    true
  end

  def users_by_ids(ids) do
    Process.sleep(Enum.random(100..200))

    Enum.filter(@users, fn user -> user.id in ids end)
  end
end
