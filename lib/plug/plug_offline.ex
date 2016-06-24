defmodule Plug.PlugOffline do
  import Plug.Conn

  @spec init(map) :: map
  def init(options) do
    options
  end

  @spec call(map, map) :: map
  def call(conn, options) do
    if "/#{conn.path_info}" == options[:at] do
      conn
      |> put_resp_content_type("text/cache-manifest")
      |> send_resp(200, cache_content(options))
      |> halt
    else
      conn
    end
  end

  @spec cache_content(map) :: String.t
  def cache_content(options) do
    body = ["CACHE MANIFEST", cache_key(options[:cache], options[:base_path])]
    body = body ++ cache(options)
    body = body ++ network(options)
    body = body ++ fallback(options)

    body
    |> Enum.join("\n")
  end

  # When inline option present do not generate cache manifest entry for the assets file, though
  # the digest is still based on the content of all assets. Which make update possible when
  # assets changes
  defp cache(%{offline_asset: true, inline: true} = _opts) do
    []
  end

  defp cache(opts) do
    opts[:cache]
  end

  # https://bordeltabernacle.github.io/2016/01/04/notes-on-elixir-pattern-matching-maps.html
  defp network(%{network: _network} = opts) do
    ["NETWORK:" | opts[:network]]
  end

  defp network(_opts) do
    []
  end

  defp fallback(%{fallback: _fallback} = opts) do
    ["FALLBACK:" | opts[:fallback]]
  end

  defp fallback(_opts) do
    []
  end

  @spec cache_key(nil, String.t) :: String.t
  defp cache_key(nil, _path) do
    ''
  end

  @spec cache_key(list(String.t), String.t) :: String.t
  defp cache_key(keys, base_path) do
    keys
    |> Enum.sort
    |> Enum.map(&digest_file(&1, base_path))
    |> Enum.join
    |> magic_comment
  end

  @spec digest_file(String.t, nil) :: String.t
  defp digest_file(file_name, nil) do
    read_file(file_name)
  end

  @spec digest_file(String.t, String.t) :: String.t
  defp digest_file(file_name, base_path) do
    read_file(Path.join([base_path, file_name]))
  end

  @spec read_file(String.t) :: String.t
  defp read_file(file) do
    case File.read(file) do
      { :ok, body } ->
        :crypto.hash(:sha256, body) |> Base.encode16
      { :error, _reason } -> ''
    end
  end

  @spec magic_comment(String.t) :: String.t
  defp magic_comment(text) do
    "# #{:crypto.hash(:sha256, text) |> Base.encode16}"
  end
end
