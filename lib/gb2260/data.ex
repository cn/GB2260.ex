defmodule GB2260.Data do
  @moduledoc """
  The Elixir implementation for looking up the Chinese administrative divisions.
  """

  use GenServer

  def data_path do
    Path.join(Application.app_dir(:gb2260, "priv"), "data")
  end

  @doc """
  Return all revisions
  """
  @spec revisions :: [String.t]
  def revisions do
    "#{data_path}/revisions.json"
    |> File.read!
    |> Poison.Parser.parse!
    |> Map.fetch!("revisions")
    |> Enum.map(fn(revision) -> String.slice(revision, 0..3) end)
  end

  @doc """
  Return last revision
  """
  @spec last_revision :: String.t
  def last_revision do
    revisions
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort
    |> List.last
    |> to_string
  end

  @spec data(String.t) :: map
  def data(revision) do
    GenServer.call(__MODULE__, {:data, revision})
  end

  @doc """
  Return region name
  """
  @spec fetch(String.t, String.t) :: String.t | nil
  def fetch(code, revision) do
    data(revision) |> Dict.get(code)
  end

  @spec file_paths() :: [String.t]
  def file_paths do
    {:ok, files} = File.ls(data_path)
    files
    |> Enum.filter(fn(file_name) -> String.match?(file_name, ~r/.*\.tsv/) end)
    |> Enum.map(fn(file_name) -> data_path <> "/" <> file_name end)
  end

  @doc false
  @spec is_province?(String.t) :: boolean
  def is_province?(code) do
    "#{province_prefix(code)}0000" == code
  end

  @doc false
  @spec is_prefecture?(String.t) :: boolean
  def is_prefecture?(code) do
    !is_province?(code) && "#{prefecture_prefix(code)}00" == code
  end

  @doc false
  @spec is_county?(String.t) :: boolean
  def is_county?(code) do
    !is_province?(code) && "#{prefecture_prefix(code)}00" != code
  end

  @doc false
  @spec province_prefix(String.t) :: String.t
  def province_prefix(code) do
    String.slice(code, 0..1)
  end

  @doc false
  @spec prefecture_prefix(String.t) :: String.t
  def prefecture_prefix(code) do
    String.slice(code, 0..3)
  end

  @doc false
  @spec province_code(String.t) :: String.t
  def province_code(code) do
    province_prefix(code) <> "0000"
  end

  @doc false
  @spec prefecture_code(String.t) :: String.t
  def prefecture_code(code) do
    prefecture_prefix(code) <> "00"
  end

  @spec fetch_data(String.t) :: map
  defp fetch_data(revision) do
    file_path = file_paths
                |> Enum.find(fn(path) -> Regex.match?(~r/#{revision}/, path) end)

    File.stream!(file_path)
      |> Enum.reduce(
        %{},
        fn(line, map) ->
          case line do
            "Source\tRevision\tCode\tName" ->
              map
            _ ->
              [_source, _revision, code, name] = String.split(line, "\t")

              Dict.put(map, code, String.strip(name))
          end
        end
      )
  end

  def start_link do
    GenServer.start_link(__MODULE__, revisions, name: __MODULE__)
  end

  # Callbacks
  def init(revisions) do
    data = revisions
            |> Enum.reduce(
              %{},
              fn(revision, map) -> Map.put(map, revision, fetch_data(revision)) end
            )

    {:ok, data}
  end

  def handle_call({:data, revision}, _from, data) do
    {:reply, Map.get(data, revision), data }
  end
end
