defimpl JsonSerde.Serializer, for: Any do
  require JsonSerde

  def serialize(%module{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.put(JsonSerde.data_type_key(), JsonSerde.Alias.to_alias(module))
    |> JsonSerde.Serializer.serialize()
  end

  def serialize(term) do
    {:ok, term}
  end
end

defimpl JsonSerde.Deserializer, for: Any do
  require JsonSerde
  import Brex.Result.Base, only: [fmap: 2, ok: 1]
  import Brex.Result.Mappers

  def deserialize(%module{}, map) do
    convert(map)
    |> fmap(&construct(module, &1))
  end

  def deserialize(_, term) do
    ok(term)
  end

  defp construct(module, map) do
    Code.ensure_loaded?(module)
    case function_exported?(module, :new, 1) do
      true -> apply(module, :new, [map])
      false -> struct(module, map)
    end
  end

  defp convert(map) do
    map
    |> Map.delete(JsonSerde.data_type_key())
    |> map_while_success(fn {key, value} ->
      with {:ok, deserialized} <- JsonSerde.Deserializer.deserialize(value, value) do
        {:ok, {String.to_atom(key), deserialized}}
      end
    end)
    |> fmap(&Map.new/1)
  end

end
