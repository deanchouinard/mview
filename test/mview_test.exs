defmodule MviewTest do
  use ExUnit.Case
  use Plug.Test

  doctest Mview

  # @opts Mview.Router.init([pages_dir: "/Users/dean/wrk/elixir/dwiki/test/pages"])
  @opts Mview.Router.init(dirs:
  [["/home/deanchouinard/wrk/elixir/mview/test/test_data","Journal"]])

  test "plug root" do
    conn = conn(:get, "/", "")
      |> Mview.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "test.md"
  end

  @tag :skip
  test "plug returns 404" do
    conn = conn(:get, "/missing", "")
      |> Mview.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
