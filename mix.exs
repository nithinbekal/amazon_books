defmodule AmazonBooks.Mixfile do
  use Mix.Project

  def project do
    [app: :amazon_books,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: "Fetch book information from Amazon API",
     package: package()
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

      {:ex_doc, ">= 0.19.0", only: :dev},
    ]
  end

  def package do
    [ name: :amazon_books,
      files: ["lib", "mix.exs"],
      maintainers: ["Nithin Bekal"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/nithinbekal/amazon_books"},
    ]
  end
end
