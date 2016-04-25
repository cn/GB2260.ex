defmodule BasicBench do
  use Benchfella

  @times 1000

  setup_all do
    Application.ensure_all_started(:gb2260)

    {:ok, []}
  end

  bench "geting specific division" do
    (1..@times)
      |> Enum.each(fn(_) -> GB2260.get("110000", "2013") end)
  end
end
