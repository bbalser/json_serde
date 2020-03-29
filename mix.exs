defmodule JsonSerde.MixProject do
  use Mix.Project

  def project do
    [
      app: :json_serde,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainer: ["Brian Balser"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bbalser/json_serde"}
    ]
  end

  defp description() do
    "JsonSerde serializes and deserializes nested elixir datastructures."
  end
end
