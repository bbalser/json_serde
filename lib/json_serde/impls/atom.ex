defimpl JsonSerde.Serializer, for: Atom do
  require JsonSerde

  def serialize(true) do
    {:ok, true}
  end

  def serialize(false) do
    {:ok, false}
  end

  def serialize(atom) do
    {:ok, %{
        JsonSerde.data_type_key() => "atom",
        "value" => to_string(atom)
     }}
  end
end
