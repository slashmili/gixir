use ExGuard.Config

guard("unit-test")
|> command("mix test --color test/gixir/commit_test.exs")
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> ignore(~r{deps})
|> notification(:auto)
