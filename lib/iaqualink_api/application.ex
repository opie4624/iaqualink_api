defmodule IaqualinkApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IaqualinkApi.Auth.Session,
      IaqualinkApi.Auth.SessionUpdater,
      {Finch, name: ApiFinch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IaqualinkApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
