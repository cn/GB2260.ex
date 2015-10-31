defmodule GB2260 do
  alias GB2260.Data
  alias GB2260.Division

  @spec get(String.t, non_neg_integer) :: GB2260.Division.t
  def get(code, revision \\ Data.last_revision) do
    Division.build(code, Data.fetch(code, revision), revision)
  end

  @spec provinces(non_neg_integer) :: list(GB2260.Division.t)
  def provinces(revision \\ Data.last_revision) do
    Data.provinces(revision) |> to_divistion(revision)
  end

  @spec prefectures(non_neg_integer) :: list(GB2260.Division.t)
  def prefectures(revision \\ Data.last_revision) do
    Data.prefectures(revision) |> to_divistion(revision)
  end

  @spec counties(non_neg_integer) :: list(GB2260.Division.t)
  def counties(revision \\ Data.last_revision) do
    Data.counties(revision) |> to_divistion(revision)
  end

  @doc false
  defp to_divistion(codes, revision) do
    Enum.map(codes, fn(code) -> get(code, revision) end)
  end
end
