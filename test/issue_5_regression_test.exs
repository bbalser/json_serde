defmodule Issue5RegressionTest do
  use ExUnit.Case

  defmodule Car do
    defstruct driver: nil
  end

  describe "JsonSerde" do
    test "should serialize and deserialize nil values as `null`" do
      {:ok, json} = JsonSerde.serialize(%Car{})

      assert json == "{\"driver\":null,\"__data_type__\":\"Elixir.Issue5RegressionTest.Car\"}"

      {:ok, car} = JsonSerde.deserialize(json)

      assert is_nil(car.driver)
    end
  end
end
