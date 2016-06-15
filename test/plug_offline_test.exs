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

  test 'wat' do
    conn = conn(:get, "/foo") |> send_resp(200, "HELLO")
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "HELLO"
  end

  test 'only cache manifest set' do
    conn = conn(:get, "/cache.manifest")  |> call(
      at: "/cache.manifest",
      cache: ["js/app.js", "js/bundle.js"]
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\njs/bundle.js\njs/app.js"
  end

  test 'cache manifest and network are set' do
    conn = conn(:get, "/cache.manifest")  |> call(
      at: "/cache.manifest",
      cache: ["js/bundle.js"],
      network: ["/api"]
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\njs/bundle.js\nNETWORK:\n/api"
  end

  test 'cache manifest and network and fallback are set' do
    conn = conn(:get, "/cache.manifest")  |> call(
      at: "/cache.manifest",
      cache: ["js/bundle.js"],
      network: ["/api"],
      fallback: ["images/large images/offline.png"]
    )
    { status, _headers, body } = sent_resp(conn)

    assert status == 200
    assert body == "CACHE MANIFEST\njs/bundle.js\nNETWORK:\n/api\nFALLBACK:\nimages/large images/offline.png"
  end

  test 'only network set cache manifest is missing' do
    assert_raise(ArgumentError, fn ->
      conn = conn(:get, "/cache.manifest")  |> call(
        at: "/cache.manifest",
        network: ["js/app"]
      )
    end)
  end

end
