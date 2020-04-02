defmodule JsonSerde.Alias do

  @to_aliases %{
    DateTime => "date_time",
    Date => "date",
    MapSet => "map_set",
    NaiveDateTime => "naive_date_time",
    Time => "time"
  }

  @from_aliases Enum.map(@to_aliases, fn {a, b} -> {b, a} end) |> Map.new()

  @spec to_alias(module) :: String.t()
  def to_alias(module) do
    Map.get_lazy(@to_aliases, module, fn ->
      custom_module = Module.concat(JsonSerde.Custom.Modules, module)
      case Code.ensure_loaded?(custom_module) do
        true -> apply(custom_module, :alias, [])
        false -> to_string(module)
      end
    end)
  end

  @spec from_alias(String.t()) :: module
  def from_alias(alias) do
    Map.get_lazy(@from_aliases, alias, fn ->
      custom_module = Module.concat(JsonSerde.Custom.Aliases, alias)
      case Code.ensure_loaded?(custom_module) do
        true -> apply(custom_module, :module, [])
        false -> String.to_atom(alias)
      end
    end)
  end
end
