defmodule Naughtygram.Mixfile do
  use Mix.Project

  def project do
    [app: :naughtygram,
     version: "0.1.3",
     elixir: "~> 1.1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: app_list(Mix.env)]
  end

  defp app_list(:dev), do: [:dotenv | app_list]
  defp app_list(:test), do: [:dotenv | app_list]
  defp app_list(_), do: app_list
  defp app_list, do: [:logger, :httpoison, :poison]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.7.4"},
      {:exprintf, "~> 0.1.6"},
      {:poison, "~> 1.5"},
      {:exvcr, "~> 0.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.10.0", only: [:dev, :docs]},
      {:excoveralls, "~> 0.3", only: [:dev, :test]},
      {:inch_ex, "~> 0.4.0", only: [:dev, :docs]},
      {:dotenv, "~> 1.0.0", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Instagram Private API client library for Elixir.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      keywords: ["Elixir", "Instagram", "instagram", "REST", "HTTP", "API", "Private", "naughty"],
      maintainers: ["Zen Savona"],
      links: %{"GitHub" => "https://github.com/zensavona/naughtygram",
               "Docs" => "https://hexdocs.pm/naughtygram"}
    ]
  end
end
