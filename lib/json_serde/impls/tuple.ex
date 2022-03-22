defimpl JsonSerde.Serializer, for: Tuple do
  require JsonSerde

  def serialize(tuple) do
    with list <- Tuple.to_list(tuple),
         {:ok, values} <- JsonSerde.Serializer.serialize(list) do
      {:ok,
       %{
         JsonSerde.data_type_key() => "tuple",
         "values" => values
       }}
    end
  end
end
