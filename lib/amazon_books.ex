defmodule AmazonBooks do
  import SweetXml

  @service_urls %{
    "US" => "http://webservices.amazon.com/onca/xml",
    "UK" => "http://webservices.amazon.co.uk/onca/xml",
    "CA" => "http://webservices.amazon.ca/onca/xml",
    "DE" => "http://webservices.amazon.de/onca/xml",
    "JP" => "http://webservices.amazon.co.jp/onca/xml",
    "FR" => "http://webservices.amazon.fr/onca/xml",
    "IT" => "http://webservices.amazon.it/onca/xml",
    "CN" => "http://webservices.amazon.cn/onca/xml",
    "ES" => "http://webservices.amazon.es/onca/xml",
    "IN" => "http://webservices.amazon.in/onca/xml",
    "BR" => "http://webservices.amazon.com.br/onca/xml",
    "MX" => "http://webservices.amazon.com.mx/onca/xml"
  }

  @doc """
  Find book by ISBN, ASIN or EAN.

  Returns the result in the form of a list. Lookup multiple books by passing in
  a comma separated list of ISBNs.

      AmazonBooks.lookup("9781633430112")

      AmazonBooks.lookup("9781633430112,9780141035482")
      # =>
      # [%{author: "Benjamin Tan Wei Hao", title: "The Little Elixir ", ...},
      #  %{author: "Niall Ferguson", title: "The Ascent of Money: A Financial History of the World"}]

  Include custom options:

      AmazonBooks.lookup("076243631X", %{"Sort" => "relevancerank"})

  """
  def lookup(isbn, opts \\ %{}) do
    %{"IdType" => "ISBN", "ItemId" => isbn, "Operation" => "ItemLookup"}
    |> send_request(opts)
  end

  @doc """
  Perform custom queries.

      AmazonBooks.query(%{"Title" => "Harry Potter", "Sort" => "relevancerank"})

  """
  def query(params), do: send_request(params)

  def search_by_keywords(keywords, opts \\ %{}) do
    %{"Keywords" => keywords, "Operation" => "ItemSearch"}
    |> send_request(opts)
  end

  def search_by_title(title, opts \\ %{}) do
   %{"Operation" => "ItemSearch", "Title" => title}
   |> send_request(opts)
  end

  defp send_request(params, opts \\ %{}) do
    country = Map.get(opts, "country", "US")
    service_url = Map.get(@service_urls, country, @service_urls["US"])
    opts = Map.drop(opts, ["country"])

    query_str =
      default_query_params()
      |> Map.merge(opts)
      |> Map.merge(params)
      |> URI.encode_query()

    "#{service_url}?#{query_str}"
    |> AwsSignUrl.call(fetch_config(:secret_access_key))
    |> HTTPoison.get!
    |> xml_to_list
  end

  @xpath_list [
    asin: ~x"./ASIN/text()"s,
    title: ~x"./ItemAttributes/Title/text()"s,
    author: ~x"./ItemAttributes/Author/text()"s,
    ean: ~x"./ItemAttributes/EAN/text()"s,
    isbn: ~x"./ItemAttributes/ISBN/text()"s,
    publisher: ~x"./ItemAttributes/Publisher/text()"s,
    number_of_pages: ~x"./ItemAttributes/NumberOfPages/text()"s,
    list_price: ~x"./ItemAttributes/ListPrice/Amount/text()"s,
    list_price_currency: ~x"./ItemAttributes/ListPrice/CurrencyCode/text()"s,
    offer_price: ~x"./OfferSummary/LowestNewPrice/Amount/text()"s,
    offer_currency: ~x"./OfferSummary/LowestNewPrice/CurrencyCode/text()"s,
  ]

  defp xml_to_list(xml), do: SweetXml.xpath(xml.body, ~x"//Item"l, @xpath_list)

  defp default_query_params do
    %{
      "AWSAccessKeyId" => fetch_config(:access_key_id),
      "AssociateTag"   => fetch_config(:associate_tag),
      "Operation"      => "ItemSearch",
      "ResponseGroup"  => "ItemAttributes,OfferSummary",
      "SearchIndex"    => "Books",
      "Service"        => "AWSECommerceService",
      "Sort"           => "salesrank"
    }
  end

  defp fetch_config(key) when is_atom(key) do
    Application.get_env(:amazon_books, key)
    |> fetch_config
  end
  defp fetch_config(string) when is_binary(string), do: string
  defp fetch_config({:system, env_var}), do: System.get_env(env_var)
end
