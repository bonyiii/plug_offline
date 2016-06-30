defmodule Plug.PlugOfflineTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defp call(conn, opts) do
    Plug.PlugOffline.call(conn, opts)
  end

  test 'regular request' do
    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{private: %{hello: :world}}, :get, "/hello", nil)
    assert conn.method == "GET"
    assert conn.path_info == ["hello"]
    assert conn.private.hello == :world
  end

  test 'testing conn' do
    conn = conn(:get, "/foo") |> send_resp(200, "HELLO")
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "HELLO"
  end

  test 'only cache manifest set path provided, available asset files' do
    conn = conn(:get, "/cache.manifest")  |> call(%{
          at: "/cache.manifest",
          base_path: Path.join([Path.dirname(__ENV__.file), '/../']),
          cache: ["/assets/app.js"]}
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\n# AD935EF79291C23435C4FE7A00202CBE233A91B38048344F9C9CF0ECE0ABEF75\n/assets/app.js"
  end

  test 'only cache manifest set path provided, available asset files read only once at boot time' do
    Plug.PlugOffline.init(%{
          at: "/cache.manifest",
          cache_digest: true,
          base_path: Path.join([Path.dirname(__ENV__.file), '/../']),
          cache: ["/assets/app.js"]})

    conn = conn(:get, "/cache.manifest")  |> call(%{
          at: "/cache.manifest",
          cache_digest: true,
          base_path: Path.join([Path.dirname(__ENV__.file), '/../']),
          cache: ["/assets/app.js"]}
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\n# AD935EF79291C23435C4FE7A00202CBE233A91B38048344F9C9CF0ECE0ABEF75\n/assets/app.js"
  end


  test 'cache manifest and network are set' do
    conn = conn(:get, "/cache.manifest")  |> call(%{
          at: "/cache.manifest",
          cache: ["/js/bundle.js"],
          network: ["/api"]}
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\n# E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855\n/js/bundle.js\nNETWORK:\n/api"
  end

  test 'cache manifest and network and fallback are set' do
    conn = conn(:get, "/cache.manifest")  |> call(%{
          at: "/cache.manifest",
          cache: ["/js/bundle.js"],
          network: ["/api"],
          fallback: ["images/large images/offline.png"]}
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\n# E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855\n/js/bundle.js\nNETWORK:\n/api\nFALLBACK:\nimages/large images/offline.png"
  end

  test 'cache manifest and network and fallback are set and offline assets is in use and rendering inline' do
    conn = conn(:get, "/cache.manifest")  |> call(%{
          at: "/cache.manifest",
          offline_asset: true,
          inline: true,
          cache: ["/js/bundle.js"],
          network: ["/api"],
          fallback: ["images/large images/offline.png"]}
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\n# E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855\nNETWORK:\n/api\nFALLBACK:\nimages/large images/offline.png"
  end

  test 'cache manifest and network and fallback are set and offline assets is in use and rendering not inline' do
    conn = conn(:get, "/cache.manifest")  |> call(%{
          at: "/cache.manifest",
          offline_asset: true,
          cache: ["/js/bundle.js"],
          network: ["/api"],
          fallback: ["images/large images/offline.png"]}
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\n# E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855\n/js/bundle.js\nNETWORK:\n/api\nFALLBACK:\nimages/large images/offline.png"
  end

  test 'only network set, cache manifest is missing' do
    assert_raise(ArgumentError, fn ->
      conn(:get, "/cache.manifest")  |> call(%{
            at: "/cache.manifest",
            network: ["js/app"]}
      )
    end)
  end

end
