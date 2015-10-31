defmodule GB2260.Data do
  @data_path Path.join(__DIR__, "../../data")

  {:ok, files} = File.ls(@data_path)

  file_paths = files
                |> Enum.filter(fn(file_name) -> String.match?(file_name, ~r/GB2260-.*\.txt/) end)
                |> Enum.map(fn(file_name) -> @data_path <> "/" <> file_name end)


  # define last_revision method
  last_revision = Enum.reduce(
    file_paths, [], fn(file_path, revisions) ->
      case Regex.scan(~r/GB2260-(\d{4,6}).*txt$/, file_path) do
        [[_, revision]] ->
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

  @spec last_revision() :: non_neg_integer
  def last_revision do
    unquote(last_revision)
  end

  file_paths
    |> Enum.each(
      fn(file_path) ->
        case Regex.scan(~r/GB2260-(\d{4,6}).*txt$/, file_path) do
          [[_, revision]] ->
            revision = String.to_integer(revision)

            File.stream!(file_path)
              |> Enum.map(fn(line) -> String.split(line) end)
              |> Enum.reduce(
                %{ provinces: [], prefectures: [], counties: [] },
                fn([code, name], map) ->
                  unless String.length(code) == 6 do
                    raise "code: #{code} is invalid in #{file_path}"
                  end

                  def fetch(unquote(code), unquote(revision)) do
                    unquote(name)
                  end

                  map_update = fn(val) -> [code | val] end
                  cond do
                    "#{String.slice(code, 0..1)}0000" == code ->
                      def is_province?(unquote(code), unquote(revision)) do
                        true
                      end
                      Dict.update!(map, :provinces, map_update)

                    "#{String.slice(code, 0..3)}00" == code ->
                      def is_prefecture?(unquote(code), unquote(revision)) do
                        true
                      end

                      Dict.update!(map, :prefectures, map_update)

                    true ->
                      def is_county?(unquote(code), unquote(revision)) do
                        true
                      end
                      Dict.update!(map, :counties, map_update)
                  end
                end
              ) |> Enum.each(
                # define provinces/1, prefectures/1, counties/1
                fn({region, codes_list}) ->
                  def unquote(region)(unquote(revision)) do
                    unquote(codes_list)
                  end
                end
              )
          _ -> :none
        end
      end
    )

  def fetch(code, _revision) do
    "#{code} not found"
  end

  def is_province?(_code, _revision) do
    false
  end

  def is_prefecture?(_code, _revision) do
    false
  end

  def is_county?(_code, _revision) do
    false
  end
end
