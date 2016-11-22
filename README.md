
# Amazon Books API

Provides functions to fetch book information from Amazon Products API.

Currently the only available option is to lookup by ISBN.

```elixir
AmazonBooks.lookup("076243631X")
#=> %{author: 'Lal Hardy', title: 'The Mammoth Book of Tattoos', xml: "..."}
```

## Usage

Add `amazon_books` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:amazon_books, "~> 0.1.0"}]
end
```

Configure your AWS credentials like this:

```elixir
config :amazon_books, :associate_tag, "associate-tag"
config :amazon_books, :access_key_id, "your-access-key"
config :amazon_books, :secret_access_key, "your-key" 
```

```elixir
# Lookup by ISBN 10 or ASIN
AmazonBooks.lookup("076243631X")

# Search by title or keywords
AmazonBooks.search_by_title("Elixir in Action")
AmazonBooks.search_by_keywords("elixir programming")

# Search within a country (defaults to US)
AmazonBooks.search_by_title("Elixir in Action", %{"country" => "IN"})

# Include additional options
AmazonBooks.lookup("076243631X", %{"Sort" => "relevancerank"})

# Perform custom queries
AmazonBooks.query(%{"Title" => "Harry Potter", "Sort" => "relevancerank"})
```

