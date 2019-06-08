defmodule Examples.ExampleDecode do
  alias CsvDecode

  def example do
    path = "./example_csv.csv"

    schema = %{
      "Active" => :boolean,
      "Phone" => :string,
      "School" => :string,
      "State" => :string,
      "System ID" => :integer
    }

    result = CsvDecode.decode(path, schema)

    IO.inspect(result, label: "********** result")
  end
end
