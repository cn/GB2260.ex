defmodule BasicBench do
  use Benchfella

  @times 1000

  bench "geting specific division" do
    (1..@times)
      |> Enum.each(fn(_) -> GB2260.get("110000", "2013") end)
  end
end
