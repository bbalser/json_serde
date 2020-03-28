defmodule JsonSerde.Alias do

  @to_aliases %{
    DateTime => "date_time",
    Date => "date",
    MapSet => "map_set",
    NaiveDateTime => "naive_date_time",
    Time => "time"
  }

  @from_aliases Enum.map(@to_aliases, fn {a, b} -> {b, a} end) |> Map.new()

  def to_alias(module) do
    Map.get(@to_aliases, module, module)
  end

  def from_alias(alias) do
    Map.get(@from_aliases, alias, alias)
  end
end
