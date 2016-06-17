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
    #body = ["CACHE MANIFEST", cache_key(options[:cache])]
    body = ["CACHE MANIFEST"]

    body = options[:cache] ++ body
    if(options[:network] && options[:network] != []) do
      body = ["NETWORK:" | body]
      body = options[:network] ++ body
    end
    if(options[:fallback] && options[:fallback] != []) do
      body = ["FALLBACK:" | body]
      body = options[:fallback] ++ body
    end

    body
    |> Enum.reverse
    |> Enum.join("\n")
  end

  def cache_key(keys) do
    keys
    |> Enum.sort
    |> sha_for_file
    |> magic_comment
  end

  defp sha_for_file(file_name) do
    path = Path.join([__ENV__.file, '../test', file_name])
    IO.puts path
    case File.read(path) do
      { :ok, body } ->
        :crypto.hash(:sha256, body) |> Base.encode16
      { :error, _reason } -> ''
    end
  end

  defp magic_comment(text) do
    "# #{:crypto.hash(:sha256, text) |> Base.encode16}"
  end

end
