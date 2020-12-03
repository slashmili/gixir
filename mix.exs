defmodule Gixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :gixir,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:rustler] ++ Mix.compilers(),
      rustler_crates: rustler_crates(),
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.19"},
      {:ex_guard, "~> 1.3", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false}
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
