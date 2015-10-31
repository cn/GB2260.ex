defmodule GB2260.Division do
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

  @doc """
  Get the specific struct.

  ## Example


      iex> GB2260.Division.get("110000")
      %GB2260.Division{ code: "110000", name: "北京市", revision: 2014 }
      iex> GB2260.Division.get("110000", 2013)
      %GB2260.Division{ code: "110000", name: "北京市", revision: 2013 }
  """
  @spec get(String.t, non_neg_integer) :: GB2260.Division.t
  def get(code, revision \\ Data.last_revision) do
    build(code, Data.fetch(code, revision), revision)
  end

  @doc """
  Return batch of structs by list of codes.

  ## Example


      iex> GB2260.Division.batch(["110000", "110100"])
      [
        %GB2260.Division{ code: "110000", name: "北京市", revision: 2014 },
        %GB2260.Division{ code: "110100", name: "市辖区", revision: 2014 }
      ]
      iex> GB2260.Division.batch(["110000", "110100"], 2013)
      [
        %GB2260.Division{ code: "110000", name: "北京市", revision: 2013 },
        %GB2260.Division{ code: "110100", name: "市辖区", revision: 2013 }
      ]
  """
  @spec batch(list(String.t), non_neg_integer) :: list(GB2260.Division.t)
  def batch(list, revision \\ Data.last_revision) do
    list |> Enum.map(fn(code)-> get(code, revision) end)
  end


  @doc """
  Return province of specific struct.
  """
  @spec province(GB2260.Division.t) :: GB2260.Division.t
  def province(division) do
    code = province_code(division)

    name = Data.fetch(code, division.revision)
    build(code, name, division.revision)
  end

  @doc """
  Return prefecture of specific struct.
  """
  @spec prefecture(GB2260.Division.t) :: GB2260.Division.t | nil
  def prefecture(division) do
    if is_province?(division) do
      nil
    else
      code = prefecture_code(division)

      name = Data.fetch(code, division.revision)
      build(code, name, division.revision)
    end
  end

  @doc """
  Return county of specific struct.
  """
  @spec county(GB2260.Division.t) :: GB2260.Division.t | nil
  def county(division) do
    if is_county?(division), do: division
  end

  @doc """
  Return all prefectures of province.
  """
  @spec prefectures(GB2260.Division.t) :: list(GB2260.Division.t)
  def prefectures(division) do
    if is_province?(division) do
      Data.prefectures(division.revision)
        |> Enum.filter(
          fn(code) ->
            Regex.match?(~r/#{province_prefix(division)}\d{2}00/, code)
          end
        ) |> batch(division.revision)
    else
      []
    end
  end

  @doc """
  Return all counties of province or prefecture.
  """
  @spec counties(GB2260.Division.t) :: list(GB2260.Division.t)
  def counties(division) do
    cond do
      is_province?(division) ->
        regex = ~r/#{province_prefix(division)}\d{4}/
      is_prefecture?(division) ->
        regex = ~r/#{prefecture_prefix(division)}\d{2}/
      true -> :none
    end

    if is_atom(regex) do
      []
    else
      Data.counties(division.revision)
        |> Enum.filter(fn(code) -> Regex.match?(regex, code) end)
        |> batch(division.revision)
    end
  end

  @doc """
  Return true if the struct is province.
  """
  @spec is_province?(Division.Division.t) :: boolean
  def is_province?(division) do
    Data.is_province?(division.code, division.revision)
  end

  @doc """
  Return true if the struct is prefecture.
  """
  @spec is_prefecture?(Division.Division.t) :: boolean
  def is_prefecture?(division) do
    Data.is_prefecture?(division.code, division.revision)
  end

  @doc """
  Return true if the struct is county.
  """
  @spec is_county?(Division.Division.t) :: boolean
  def is_county?(division) do
    Data.is_county?(division.code, division.revision)
  end

  @doc false
  @spec province_code(Division.Division.t) :: String.t
  defp province_code(division) do
    province_prefix(division) <> "0000"
  end

  @doc false
  @spec prefecture_code(Division.Division.t) :: String.t
  defp prefecture_code(division) do
    prefecture_prefix(division) <> "00"
  end

  @doc false
  @spec province_prefix(Division.Division.t) :: String.t
  defp province_prefix(division) do
    String.slice(division.code, 0..1)
  end

  @doc false
  @spec prefecture_prefix(Division.Division.t) :: String.t
  defp prefecture_prefix(division) do
    String.slice(division.code, 0..3)
  end
end
