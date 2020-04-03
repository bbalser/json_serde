defmodule JsonSerde.Alias do

  @to_aliases %{
    DateTime => "date_time",
    Date => "date",
    MapSet => "map_set",
    NaiveDateTime => "naive_date_time",
    Time => "time"
  }

  @from_aliases Enum.map(@to_aliases, fn {a, b} -> {b, a} end) |> Map.new()

  @spec setup_alias(module, String.t()) :: no_return
  def setup_alias(_module, nil), do: :ok
  def setup_alias(module, alias) do
    module_contents = quote do
      def alias() do
        unquote(alias)
      end
    end

    name = Module.concat(JsonSerde.Custom.Modules, module)
    Module.create(name, module_contents, Macro.Env.location(__ENV__))

    alias_contents = quote do
      def module() do
        unquote(module)
      end
    end

    name = Module.concat(JsonSerde.Custom.Aliases, alias)
    Module.create(name, alias_contents, Macro.Env.location(__ENV__))
  end

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
