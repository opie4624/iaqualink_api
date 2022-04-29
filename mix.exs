defmodule IaqualinkApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :iaqualink_api,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {IaqualinkApi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mox, "~> 1.0"},
      {:knigge, "~> 1.4"},
      {:finch, "~> 0.11"},
      {:jason, "~> 1.3"},
      {:plug, "~> 1.12"}
    ]
  end
end
