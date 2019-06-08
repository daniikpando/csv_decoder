# CsvDecode

It's a CSV decoder for elixir language

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `csv_decode` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:csv_decode, "~> 0.1.0"}
  ]
end
```


# Use 

Use the main function something like that

```
alias CsvDecode

path = "./example_csv.csv"

schema = %{
  "Active" => :boolean,
  "Phone" => :string,
  "School" => :string,
  "State" => :string,
  "System ID" => :integer
}

CsvDecode.decode(path, schema)

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/csv_decode](https://hexdocs.pm/csv_decode).

