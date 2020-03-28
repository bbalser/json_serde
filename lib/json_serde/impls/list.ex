defimpl JsonSerde.Serializer, for: List do
  alias JsonSerde.Ok
  require JsonSerde

  def serialize(list) do
    case Keyword.keyword?(list) do
      true ->
        with {:ok, values} <- keyword_list(list) do
          {:ok,
           %{
             JsonSerde.data_type_key() => "keyword_list",
             "values" => values
           }}
        end

      false ->
        Ok.transform(list, &JsonSerde.Serializer.serialize/1)
    end
  end

  defp keyword_list(keywords) do
    Ok.transform(keywords, fn {key, value} ->
      with {:ok, serialized_value} <- JsonSerde.Serializer.serialize(value) do
        {:ok, [to_string(key), serialized_value]}
      end
    end)
  end
end

defimpl JsonSerde.Deserializer, for: List do
  alias JsonSerde.Ok

  def deserialize(_, list) do
    Ok.transform(list, &JsonSerde.Deserializer.deserialize(&1, &1))
  end
end
