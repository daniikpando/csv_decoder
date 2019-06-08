defmodule CsvDecode do
  @moduledoc """
  Documentation for CsvDecode.
  """

  @allow_file_extensions ~w(.csv)

  def decode(path, schema) do
    with {:ok, stream_file} <- validate_file_format(path),
         {:ok, {header, values}} <- convert_rows_to_list(stream_file),
         {:ok, decoded_values} <- cast_header_with_values(header, values, schema) do
      {:ok, decoded_values}
    else
      {:error, _} = err -> err
    end
  end

  @spec validate_file_format(String.t()) :: {:ok, Stream.t()} | {:error, String.t()}
  def validate_file_format(path) do
    %{path: path} = stream_file = File.stream!(path)
    file_extension = path |> Path.extname() |> String.downcase()

    if Enum.member?(@allow_file_extensions, file_extension) do
      {:ok, stream_file}
    else
      {:error,
       "Invalid file format #{file_extension}, use these: #{
         Enum.join(@allow_file_extensions, ", ")
       }"}
    end
  end

  def convert_rows_to_list(stream_file) do
    stream_file
    |> Stream.with_index()
    |> Stream.map(fn {row, line} ->
      # TODO: Improve split function with regular expression, in case a field contains other ","
      list_row =
        row
        |> String.replace("\n", "")
        |> String.split(",")

      %{
        type: detect_row_type(line),
        value: list_row,
        count: Enum.count(list_row),
        line: line
      }
    end)
    |> Enum.to_list()
    |> Enum.split_while(fn %{type: type} -> type == :header end)
    |> case do
      {[header], [_ | _] = values} ->
        {:ok, {header, values}}

      _ ->
        {:error, "No data in csv file"}
    end
  end

  def cast_header_with_values(%{count: header_length, value: header_names}, values, schema) do
    schema_keys = Map.keys(schema)

    values
    |> Enum.reduce({:ok, []}, fn
      %{count: count, value: value}, {:ok, elements} when count == header_length ->
        header_names
        |> Enum.zip(value)
        |> Map.new()
        |> parse_data_with_schema(schema_keys, schema)
        |> case do
          {:ok, map_value} ->
            {:ok, [map_value | elements]}

          {:error, _} = err ->
            err
        end

      %{line: line}, {:ok, _} ->
        {:error, "Invalid number of values in line #{line}"}

      _, {:error, _} = err ->
        err
    end)
  end

  defp parse_data_with_schema(map, schema_keys, schema) do
    map
    |> Map.take(schema_keys)
    |> Enum.reduce({:ok, %{}}, fn
      {key, val}, {:ok, map} ->
        type = Map.get(schema, key)

        try do
          {:ok, Map.merge(%{key => parse_value(val, type)}, map)}
        rescue
          _ ->
            {:error, "Invalid type #{type} for this value:  #{val}"}
        end

      _, {:error, _} = err ->
        err
    end)
  end

  defp parse_value(val, :integer), do: String.to_integer(val)
  defp parse_value(val, :boolean), do: val |> String.downcase() |> String.to_existing_atom()
  defp parse_value(val, :string), do: val

  defp detect_row_type(0), do: :header
  defp detect_row_type(n) when n > 0, do: :value
end
