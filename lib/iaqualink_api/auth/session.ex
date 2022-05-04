defmodule IaqualinkApi.Auth.Session do
  use Agent

  alias IaqualinkApi.Auth

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_expiration do
    case expiry = Agent.get(__MODULE__, &Map.get(&1, "expiration")) do
      nil ->
        renew_token()
      _ ->
        expiry
    end
  end

  def renew_token do
    new_expiration = 6000
    Agent.update(__MODULE__, &Map.put(&1, "expiration", new_expiration))
    new_expiration
  end
end

defmodule IaqualinkApi.Auth.SessionUpdater do
  use Task

  alias IaqualinkApi.Auth.Session

  require Logger

  def start_link(_arg) do
    Task.start_link(&poll/0)
  end

  def poll(), do: poll(Session.get_expiration())

  def poll(renew_time) do
    Logger.info("Renewing token in #{renew_time} seconds")

    receive do
    after
      renew_time ->
        Logger.info("Renewing token now")

        Session.renew_token()
        |> poll()
    end
  end
end
