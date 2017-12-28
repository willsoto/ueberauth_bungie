defmodule UeberauthBungie.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/willsoto/ueberauth_bungie"

  def project do
    [
      app: :ueberauth_bungie,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @url,
      homepage_url: @url,
      docs: docs(),
      package: package(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ueberauth, "~> 0.4"},
      {:oauth2, "~> 0.9"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Uberauth strategy for Bungie authentication."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Will Soto"],
      licenses: ["Apache 2.0"],
      links: %{GitHub: @url}
    ]
  end
end
