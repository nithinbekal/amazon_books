
# Changelog

## v0.3.0

- Default to US service URL if invalid country given
- Include ASIN and lowest offer in result
- Move offer out of nested map
- Fix Elixir 1.4 warnings

## v0.2.0

- Include ISBN, EAN, publisher, # of pages, price and currency in the response map.
- All lookup and search functions return a list. The previous version returned
  XML string in case of ISBN lookups.
