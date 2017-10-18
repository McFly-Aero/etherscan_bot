defmodule EtherscanBot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :etherscan_bot,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpotion, :mailchimp, :poison],
      mod: {EtherscanBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:mailchimp, "~> 0.0.6"},
      {:poison, "~> 3.1"}
    ]
  end
end
