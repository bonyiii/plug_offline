defmodule PlugOffline.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_offline,
     version: "0.0.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "PlugOffline",
     source_url: "https://github.com/bonyiii/plug_offline",
     package: package,
     description: description,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
    [
      {:plug, "~> 1.1"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.3", only: [:dev]}
    ]
  end

  defp description do
    """
    This package provides cache manifest file with digest and
    file or inline assets helper for .eex templates.
    """
  end

  defp package do
    [
      maintainers: ["bonyiii"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bonyiii/plug_offline"}
    ]
  end
end
