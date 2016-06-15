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

  def cache_key do
    "# #{:os.system_time(:seconds)}"
  end
end
