defimpl JsonSerde.Serializer, for: Decimal do
  require JsonSerde

  def serialize(decimal) do
    {:ok,
     %{
       JsonSerde.data_type_key() => JsonSerde.Alias.to_alias(Decimal),
       "value" => Decimal.to_string(decimal)
     }}
  end
end

defimpl JsonSerde.Deserializer, for: Decimal do
  def deserialize(_, map) do
    {decimal, ""} =
      map
      |> Map.get("value")
      |> Decimal.parse()

    {:ok, decimal}
  end
end
