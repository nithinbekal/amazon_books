defmodule AmazonBooks.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :amazon_books,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: """
      Fetch book information from Amazon API"
      """
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:aws_sign_url, "~> 0.1.0"},
      {:httpoison, "~> 1.4.0"},
      {:sweet_xml, "~> 0.6"},
      {:ex_doc, ">= 0.19.0", only: :dev}
    ]
  end

  def package do
    [
      name: :amazon_books,
      files: ["lib", "mix.exs"],
      maintainers: ["Nithin Bekal"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/nithinbekal/amazon_books"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme"
    ]
  end
end
