defimpl JsonSerde.Serializer, for: DateTime do
  require JsonSerde
  def serialize(datetime) do
    {:ok, %{
        JsonSerde.data_type_key() => JsonSerde.Alias.to_alias(DateTime),
        "value" => DateTime.to_iso8601(datetime)
     }}
  end
end

defimpl JsonSerde.Deserializer, for: DateTime do
  def deserialize(_, map) do
    with value <- Map.get(map, "value"),
         {:ok, date_time, _} <- DateTime.from_iso8601(value) do
      {:ok, date_time}
    end
  end
end
