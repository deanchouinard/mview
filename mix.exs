defmodule Mview.Mixfile do
  use Mix.Project

  def project do
    [app: :mview,
     version: "0.2.0",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript(),
     deps: deps()]
  end

  def escript do
    [main_module: Mview]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # [applications: [:logger, :mix, :eex, :cowboy, :plug, :httpoison],
    # [applications: [:logger, :mix, :plug_cowboy, :httpoison ],
    [extra_applications: [:logger, :mix],
     mod: {Mview, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:plug_cowboy, "~> 2.7"},
  #    {:plug, "~> 1.0"},
      {:plug, "~> 1.15"},
      {:earmark, "~> 1.4"},
      {:httpoison, "~> 1.4", only: :test},
      {:floki, "~> 0.12.0", only: :test}
    ]
  end
end
