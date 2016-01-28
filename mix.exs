defmodule GB2260.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :gb2260,
      version: @version,
      elixir: "~> 1.1",
      description: description,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package,
      deps: deps
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev}
    ]
  end

  defp description do
    """
    The Elixir implementation for looking up the Chinese administrative divisions.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "data"],
      maintainers: ["lcp_marvel"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/LcpMarvel/gb2260"
      }
    ]
  end
end
