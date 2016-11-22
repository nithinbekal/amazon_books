defmodule AmazonBooks do
  import SweetXml

  @default_query_params %{
    "AWSAccessKeyId" => Application.get_env(:amazon_books, :access_key_id),
    "AssociateTag"   => Application.get_env(:amazon_books, :associate_tag),
    "Operation"      => "ItemSearch",
    "ResponseGroup"  => "Small,OfferSummary",
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
  Get the HTTPoison response for a given ISBN.

      AmazonBooks.lookup("076243631X")
      #=> %{author: 'Lal Hardy', title: 'The Mammoth Book of Tattoos', xml: "..."}

  Include custom options:

      AmazonBooks.lookup("076243631X", %{"Sort" => "relevancerank"})

  """ 
  def lookup(isbn, opts \\ %{}) do
    %{"IdType" => "ISBN", "ItemId" => isbn, "Operation" => "ItemLookup"}
    |> send_request(opts)
    |> fetch_one
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
  end

  defp fetch_one(response) do
    response.body
    |> build_result
    |> List.first
  end

  defp build_result(xml) do
    SweetXml.xpath(xml,
      ~x"//Item/ItemAttributes"l,
      title: ~x"./Title/text()",
      author: ~x"./Author/text()")
  end
end
