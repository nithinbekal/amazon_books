defmodule AmazonBooks do
  import SweetXml

  @default_query_params %{
    "AWSAccessKeyId" => Application.get_env(:amazon_books, :access_key_id),
    "AssociateTag"   => Application.get_env(:amazon_books, :associate_tag),
    "Operation"      => "ItemSearch",
    "ResponseGroup"  => "ItemAttributes",
    "SearchIndex"    => "Books",
    "Service"        => "AWSECommerceService",
    "Sort"           => "salesrank"
  }

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

  @secret_access_key Application.get_env(:amazon_books, :secret_access_key)

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
    service_url = @service_urls[country]

    query_str =
      @default_query_params
      |> Map.merge(opts)
      |> Map.merge(params)
      |> URI.encode_query()

    "#{service_url}?#{query_str}"
    |> AwsSignUrl.call(@secret_access_key)
    |> HTTPoison.get!
    |> xml_to_list
  end

  @xpath_list [
    title: ~x"./Title/text()",
    author: ~x"./Author/text()",
    ean: ~x"./EAN/text()",
    isbn: ~x"./ISBN/text()",
    publisher: ~x"./Publisher/text()",
    number_of_pages: ~x"./NumberOfPages/text()",
    price: ~x"./ListPrice/Amount/text()",
    currency: ~x"./ListPrice/CurrencyCode/text()"
  ]

  defp xml_to_list(xml) do
    xml.body
    |> SweetXml.xpath(~x"//Item/ItemAttributes"l, @xpath_list)
    |> Enum.map(&convert_values_to_string/1)
  end

  defp convert_values_to_string(result) when is_map(result) do
    Enum.reduce(result, %{}, fn {key, val}, acc -> Map.put(acc, key, to_string(val)) end)
  end
end
