defimpl JsonSerde.Serializer, for: Any do
  require JsonSerde

  def serialize(%module{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.drop(get_exclusions(module))
    |> Map.put(JsonSerde.data_type_key(), JsonSerde.Alias.to_alias(module))
    |> JsonSerde.Serializer.serialize()
  end

  def serialize(term) do
    {:ok, term}
  end

  def get_exclusions(module) do
    case function_exported?(module, :__json_serde_exclusions__, 0) do
      true -> apply(module, :__json_serde_exclusions__, [])
      false -> []
    end
  end
end

defimpl JsonSerde.Deserializer, for: Any do
  require JsonSerde
  import Brex.Result.Base, only: [fmap: 2, ok: 1, bind: 2]
  import Brex.Result.Mappers

  def deserialize(%module{}, map) do
    convert(map)
    |> bind(&construct(module, &1))
  end

  def deserialize(_, term) do
    ok(term)
  end

  defp construct(module, map) do
    Code.ensure_loaded?(module)
    case function_exported?(module, :new, 1) do
      true -> apply(module, :new, [map]) |> wrap()
      false -> struct(module, map) |> ok()
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

  defp wrap({:ok, _} = ok), do: ok
  defp wrap({:error, _} = error), do: error
  defp wrap(value), do: {:ok, value}

end
