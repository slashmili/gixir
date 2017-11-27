defmodule Gixir.Mixfile do
  use Mix.Project

  def project do
    [app: :gixir,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:rustler] ++ Mix.compilers,
     elixirc_paths: elixirc_paths(Mix.env),
     rustler_crates: rustler_crates(),
     deps: deps()]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:rustler, "~> 0.10.1"},
      {:ex_unit_notifier, "~> 0.1", only: :test}
    ]
  end

  defp rustler_crates do
    [gixir: [
      path: "native/gixir",
      mode: (if Mix.env == :prod, do: :release, else: :debug),
    ]]
  end
end
