defmodule GB2260 do
  @moduledoc """
  #{__MODULE__} is where data stored.
  """

  alias GB2260.Data
  alias GB2260.Division

  @doc """
  Get the specific struct.

  ## Example


      iex> GB2260.get("110000")
      %GB2260.Division{ code: "110000", name: "北京市", revision: "2014" }
      iex> GB2260.get("110000", "2013")
      %GB2260.Division{ code: "110000", name: "北京市", revision: "2013" }
  """
  @spec get(String.t, String.t) :: Division.t
  def get(code, revision \\ Data.last_revision) do
    Division.build(code, Data.fetch(code, revision), revision)
  end

  @doc """
  Return batch of structs by list of codes.

  ## Example


      iex> GB2260.batch(["110000", "110100"])
      [
        %GB2260.Division{ code: "110000", name: "北京市", revision: "2014" },
        %GB2260.Division{ code: "110100", name: "市辖区", revision: "2014" }
      ]
      iex> GB2260.batch(["110000", "110100"], "2013")
      [
        %GB2260.Division{ code: "110000", name: "北京市", revision: "2013" },
        %GB2260.Division{ code: "110100", name: "市辖区", revision: "2013" }
      ]
  """
  @spec batch(list(String.t), String.t) :: list(Division.t)
  def batch(list, revision \\ Data.last_revision) do
    list |> Enum.map(fn(code)-> get(code, revision) end)
  end

  @doc """
  Return a list of provinces in `Division` data structure.
  """
  @spec provinces(String.t) :: [Division.t]
  def provinces(revision \\ Data.last_revision) do
    Division.batch_build(revision, fn({code, _name}) -> Regex.match?(~r/\d{2}0000/, code) end)
  end

  @doc """
  Return a list of prefecture level cities in `Division` data structure.
  """
  @spec prefectures(Division.t) :: [Division.t]
  def prefectures(division) do
    province_prefix = Data.province_prefix(division.code)
    regex = ~r/#{province_prefix}#{without_two_zeros}00/

    division.revision
      |> Division.batch_build(fn({code, _name}) -> Regex.match?(regex, code) end)
  end

  @doc """
  Return a list of counties in `Division` data structure.
  """
  @spec counties(Division.t) :: [Division.t]
  def counties(division) do
    regex = if is_province?(division) do
              province_prefix = Data.province_prefix(division.code)
              ~r/#{province_prefix}#{without_two_zeros}#{without_two_zeros}/
            else
              prefecture_prefix = Data.prefecture_prefix(division.code)
              ~r/#{prefecture_prefix}#{without_two_zeros}/
            end

    division.revision
      |> Division.batch_build(fn({code, _name}) -> Regex.match?(regex, code) end)
  end

  @doc """
  Return province of specific struct.
  """
  @spec province(Division.t) :: Division.t
  def province(division) do
    code = Data.province_code(division.code)

    name = Data.fetch(code, division.revision)
    Division.build(code, name, division.revision)
  end

  @doc """
  Return prefecture of specific struct.
  """
  @spec prefecture(Division.t) :: Division.t | nil
  def prefecture(division) do
    if is_province?(division) do
      nil
    else
      code = Data.prefecture_code(division.code)

      name = Data.fetch(code, division.revision)
      Division.build(code, name, division.revision)
    end
  end

  @doc """
  Return county of specific struct.
  """
  @spec county(Division.t) :: Division.t | nil
  def county(division) do
    if is_county?(division), do: division
  end

  @doc """
  Return true if the struct is province.
  """
  @spec is_province?(Division.t) :: boolean
  def is_province?(division) do
    Data.is_province?(division.code)
  end

  @doc """
  Return true if the struct is prefecture.
  """
  @spec is_prefecture?(Division.t) :: boolean
  def is_prefecture?(division) do
    Data.is_prefecture?(division.code)
  end

  @doc """
  Return true if the struct is county.
  """
  @spec is_county?(Division.t) :: boolean
  def is_county?(division) do
    Data.is_county?(division.code)
  end

  @doc false
  defp without_two_zeros do
    "([1-9]{2}|[0-9][1-9]|[1-9][0-9])"
  end
end
