defimpl JsonSerde.Serializer, for: Time do
  require JsonSerde

  def serialize(time) do
    {:ok,
     %{
       JsonSerde.data_type_key() => JsonSerde.Alias.to_alias(Time),
       "value" => Time.to_iso8601(time)
     }}
  end
end

defimpl JsonSerde.Deserializer, for: Time do
  def deserialize(_, map) do
    Map.get(map, "value")
    |> Time.from_iso8601()
  end
end
