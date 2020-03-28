defimpl JsonSerde.Serializer, for: NaiveDateTime do
  require JsonSerde
  def serialize(datetime) do
    {:ok, %{
        JsonSerde.data_type_key() => JsonSerde.Alias.to_alias(NaiveDateTime),
        "value" => NaiveDateTime.to_iso8601(datetime)
     }}
  end
end

defimpl JsonSerde.Deserializer, for: NaiveDateTime do
  def deserialize(_, map) do
    Map.get(map, "value")
    |> NaiveDateTime.from_iso8601()
  end
end
