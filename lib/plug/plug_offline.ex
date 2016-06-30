defmodule Plug.PlugOffline do
  import Plug.Conn

  @spec init(map) :: map
  def init(%{cache_digest: true} = options) do
    %{options | digest: cache_key(options[:cache], options[:base_path])}
  end

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

  @spec cache_content(map) :: binary
  def cache_content(options) do
    digest = options[:digest] || cache_key(options[:cache], options[:base_path])
    ["CACHE MANIFEST", digest]
    |> cache(options)
    |> network(options)
    |> fallback(options)
    |> Enum.join("\n")
  end

  # When inline option present do not generate cache manifest entry for the assets file, though
  # the digest is still based on the content of all assets. Which make update possible when
  # assets changes
  @spec cache(list(binary), map) :: list(String.t)
  defp cache(body, %{offline_asset: true, inline: true}) do
    body
  end

  defp cache(body, opts) do
    body ++ opts[:cache]
  end

  # https://bordeltabernacle.github.io/2016/01/04/notes-on-elixir-pattern-matching-maps.html
  @spec network(list(String.t), map) :: list(String.t)
  defp network(body, %{network: network_opts}) do
    body ++ ["NETWORK:" | network_opts]
  end

  defp network(body, _opts) do
    body
  end

  @spec fallback(list(String.t), map) :: list(String.t)
  defp fallback(body, %{fallback: fallback_opts}) do
    body ++ ["FALLBACK:" | fallback_opts]
  end

  defp fallback(body, _opts) do
    body
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
      {:ok, body} ->
        :sha256 |> :crypto.hash(body) |> Base.encode16
      {:error, _reason} -> ''
    end
  end

  @spec magic_comment(String.t) :: String.t
  defp magic_comment(text) do
    "# #{:sha256 |> :crypto.hash(text) |> Base.encode16}"
  end
end
