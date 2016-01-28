defmodule GB2260.Division do
  @moduledoc """
  #{__MODULE__} provides a struct.
  """

  alias GB2260.Division
  alias GB2260.Data

  @type t :: %__MODULE__{
    code: String.t,
    name: String.t,
    revision: non_neg_integer
  }

  defstruct code: nil, name: nil, revision: "2014"

  @doc """
  Build a struct of `GB2260.Division`.

  ## Example


      iex> GB2260.Division.build("110000", "北京市")
      %GB2260.Division{ code: "110000", name: "北京市", revision: 2014 }
      iex> GB2260.Division.build("110000", "北京市", 2013)
      %GB2260.Division{ code: "110000", name: "北京市", revision: 2013 }
  """
  @spec build(String.t, String.t, non_neg_integer) :: GB2260.Division.t
  def build(code, name, revision \\ Data.last_revision) do
    %Division{ code: code, name: name, revision: revision }
  end

  @doc false
  @spec batch_build(non_neg_integer, ((String.t, any) -> as_boolean(term))) :: [GB2260.Division.t]
  def batch_build(revision, filter_rule) do
    Data.data(revision)
      |> Enum.filter(filter_rule)
      |> Enum.map(fn({code, name}) -> build(code, name, revision) end)
  end
end
