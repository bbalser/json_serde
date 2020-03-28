defmodule JsonSerde.Alias do

  defmacro __using__(opts) do
    alias = Keyword.fetch!(opts, :alias)

    quote do
      @on_load :__json_serde_load__

      def __json_serde_load__() do
        Application.put_env(:json_serde, unquote(alias), __MODULE__, persistent: true)
        :ok
      end

      def __json_serde_alias__() do
        unquote(alias)
      end
    end
  end

  @to_aliases %{
    DateTime => "date_time",
    Date => "date",
    MapSet => "map_set",
    NaiveDateTime => "naive_date_time",
    Time => "time"
  }

  @from_aliases Enum.map(@to_aliases, fn {a, b} -> {b, a} end) |> Map.new()

  def to_alias(module) do
    Map.get_lazy(@to_aliases, module, fn ->
      case function_exported?(module, :__json_serde_alias__, 0) do
        true -> apply(module, :__json_serde_alias__, [])
        false -> module
      end
    end)
  end

  def from_alias(alias) do
    Map.get_lazy(@from_aliases, alias, fn ->
      case Application.get_env(:json_serde, String.to_atom(alias)) do
        nil -> String.to_atom(alias)
        module -> module
      end
    end)
  end
end
