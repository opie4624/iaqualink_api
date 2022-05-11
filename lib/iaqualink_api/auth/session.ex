defmodule IaqualinkApi.Auth.Session do
  use Agent

  alias IaqualinkApi.Auth

  require Logger

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_expiration do
    expiry = Agent.get(__MODULE__, &Map.get(&1, :expires))
    Logger.info("Expiry #{expiry}")

    case expiry do
      nil ->
        Auth.login()
        get_expiration()

      _ ->
        # 30s buffer good enough?
        expiry = expiry - 30
        # Convert seconds to millis
        expiry * 1_000
    end
  end

  def renew_token do
    url = Agent.get(__MODULE__, &Map.get(&1, :refresh_url))
    client_id = Agent.get(__MODULE__, &Map.get(&1, :client_id))
    refresh_token = Agent.get(__MODULE__, &Map.get(&1, :refresh_token))

    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    url =
      "#{url}/oauth2/token?grant_type=refresh_token&client_id=#{client_id}&refresh_token=#{refresh_token}"

    with {:ok, response} <-
           Finch.build(:post, url, headers)
           |> Finch.request(ApiFinch),
         {:ok, decoded} <- Jason.decode(response.body),
         do:
           %{
             id_token: Map.get(decoded, "id_token"),
             access_token: Map.get(decoded, "access_token"),
             expires: Map.get(decoded, "expires_in")
           }
           |> put_keys

    get_expiration()
  end

  def put_keys(map) do
    Logger.info("replacing values")
    Agent.update(__MODULE__, &Map.merge(&1, map))
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
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
    Logger.info("Renewing token in #{renew_time} milliseconds")

    receive do
    after
      renew_time ->
        Logger.info("Renewing token now")

        Session.renew_token()
        |> poll()
    end
  end
end
