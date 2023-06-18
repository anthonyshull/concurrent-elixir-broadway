defmodule Tickets do
  @users [
    %{id: "1", email: "foo@internet.com"},
    %{id: "2", email: "bar@internet.com"},
    %{id: "3", email: "baz@internet.com"}
  ]

  def tickets_available?("cinema") do
    Process.sleep(Enum.random(100..200))
    false
  end

  def tickets_available?(_event) do
    Process.sleep(Enum.random(100..200))
    true
  end

  def create_ticket(_user, _event) do
    Process.sleep(Enum.random(100..200))
  end

  def send_email(_user) do
    Process.sleep(Enum.random(100..200))
  end

  def users_by_ids(ids) do
    Process.sleep(Enum.random(100..200))

    Enum.filter(@users, fn user -> user.id in ids end)
  end
end
