defmodule DwikiTest do
  use ExUnit.Case
  use Plug.Test

  doctest Dwiki

  @opts Dwiki.Router.init([pages_dir: "/Users/dean/wrk/elixir/dwiki/test/pages"])

  test "plug root" do
    conn = conn(:get, "/", "")
      |> Dwiki.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "index.md"
  end

  @tag :skip
  test "plug returns 404" do
    conn = conn(:get, "/missing", "")
      |> Dwiki.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
