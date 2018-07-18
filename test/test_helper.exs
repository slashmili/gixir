cleanup = fn ->
  "./priv/test_tmp/"
  |> Path.expand()
  |> File.rm_rf!()
end

cleanup.()
System.at_exit(fn _ -> cleanup.() end)

ExUnit.start()
