defmodule GB2260.Data do
  @moduledoc """
  The Elixir implementation for looking up the Chinese administrative divisions.
  """

  @data_path Path.join(__DIR__, "../../data")

  {:ok, files} = File.ls(@data_path)

  file_paths = files
                |> Enum.filter(fn(file_name) -> String.match?(file_name, ~r/GB2260-.*\.txt/) end)
                |> Enum.map(fn(file_name) -> @data_path <> "/" <> file_name end)

  parse_file = fn(revision, file_path) ->
    File.stream!(file_path)
      |> Enum.reduce(
        %{ provinces: [], prefectures: [], counties: [] },
        fn(line, map) ->
          [code, name] = String.split(line)

          def fetch(unquote(code), unquote(revision)), do: unquote(name)

          cond do
            "#{String.slice(code, 0..1)}0000" == code ->
              def is_province?(unquote(code), unquote(revision)), do: true
              Dict.update!(map, :provinces, fn(val) -> [code | val] end)

            "#{String.slice(code, 0..3)}00" == code ->
              def is_prefecture?(unquote(code), unquote(revision)), do: true
              Dict.update!(map, :prefectures, fn(val) -> [code | val] end)

            true ->
              def is_county?(unquote(code), unquote(revision)), do: true
              Dict.update!(map, :counties, fn(val) -> [code | val] end)
          end
        end
      ) |> Enum.each(
        # define provinces/1, prefectures/1, counties/1
        fn({region, codes_list}) ->
          def unquote(region)(unquote(revision)), do: unquote(codes_list)
        end
      )
  end

  last_revision = Enum.reduce(
    file_paths, [], fn(file_path, revisions) ->
      case Regex.scan(~r/GB2260-(\d{4,6}).*txt$/, file_path) do
        [[_, revision]] ->
          parse_file.(String.to_integer(revision), file_path)

          if String.length(revision) == 4 do
            [String.to_integer(revision) | revisions]
          else
            revision = String.slice(revision, 0..3)
            [String.to_integer(revision) | revisions]
          end
        _ ->
          revisions
      end
    end
  ) |> Enum.sort |> List.last

  @doc """
  Return last revision
  """
  @spec last_revision() :: non_neg_integer
  def last_revision do
    unquote(last_revision)
  end

  @doc """
  Return region name
  """
  @spec fetch(String.t, non_neg_integer) :: String.t | nil
  def fetch(_code, _revision) do
    nil
  end

  @doc false
  @spec is_province?(String.t, non_neg_integer) :: boolean
  def is_province?(_code, _revision) do
    false
  end

  @doc false
  @spec is_prefecture?(String.t, non_neg_integer) :: boolean
  def is_prefecture?(_code, _revision) do
    false
  end

  @doc false
  @spec is_county?(String.t, non_neg_integer) :: boolean
  def is_county?(_code, _revision) do
    false
  end
end
