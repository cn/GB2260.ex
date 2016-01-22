defmodule GB2260.Data do
  @moduledoc """
  The Elixir implementation for looking up the Chinese administrative divisions.
  """

  @data_path Path.join(__DIR__, "../../data")

  {:ok, files} = File.ls(@data_path)

  file_paths = files
                |> Enum.filter(fn(file_name) -> String.match?(file_name, ~r/.*\.tsv/) end)
                |> Enum.map(fn(file_name) -> @data_path <> "/" <> file_name end)

  parse_line = fn(revision, line, map) ->
    case line do
      "Source\tRevision\tCode\tName" ->
        map
      _ ->
        [_source, _revision, code, name] = String.split(line, "\t")

        def fetch(unquote(code), unquote(revision)) do
          unquote(String.strip(name))
        end

        cond do
          "#{String.slice(code, 0..1)}0000" == code ->
            def is_province?(unquote(code), unquote(revision)), do: true
            Dict.update!(map, :provinces, fn(value) -> [code | value] end)

          "#{String.slice(code, 0..3)}00" == code ->
            def is_prefecture?(unquote(code), unquote(revision)), do: true
            Dict.update!(map, :prefectures, fn(value) -> [code | value] end)

          true ->
            def is_county?(unquote(code), unquote(revision)), do: true
            Dict.update!(map, :counties, fn(value) -> [code | value] end)
        end
    end
  end

  parse_file = fn(revision, file_path) ->
    File.stream!(file_path)
      |> Enum.reduce(
        %{ provinces: [], prefectures: [], counties: [] },
        fn(line, map) ->
          parse_line.(revision, line, map)
        end
      ) |> Enum.each(
        # define provinces/1, prefectures/1, counties/1
        fn({region, codes_list}) ->
          def unquote(region)(unquote(revision)) do
            unquote(codes_list)
          end
        end
      )
  end

  revisions = Enum.reduce(
    file_paths, [], fn(file_path, revisions) ->
      case Regex.scan(~r/data\/(\d{4,6}).*tsv$/, file_path) do
        [[_, revision]] ->
          revision = revision |> String.slice(0..3) |> String.to_integer

          parse_file.(revision, file_path)

          [revision | revisions]
        _ ->
          revisions
      end
    end
  )

  @doc """
  Return all revisions
  """
  @spec all_revisions() :: [non_neg_integer]
  def all_revisions do
    unquote(revisions)
  end

  @doc """
  Return last revision
  """
  @spec last_revision() :: non_neg_integer
  def last_revision do
    unquote(revisions |> Enum.sort |> List.last)
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
