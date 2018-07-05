defmodule Gixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :gixir,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      compilers: [:rustler] ++ Mix.compilers(),
      rustler_crates: rustler_crates(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.17.1"}
    ]
  end

  defp rustler_crates do
    [
      io: [
        path: "native/gixir",
        mode: if(Mix.env() == :prod, do: :release, else: :debug)
      ]
    ]
  end
end
