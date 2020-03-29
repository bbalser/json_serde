defimpl JsonSerde.Serializer, for: Atom do
  require JsonSerde
  def serialize(atom) do
    {:ok, %{
        JsonSerde.data_type_key() => "atom",
        "value" => to_string(atom)
     }}
  end
end
