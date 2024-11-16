defmodule Dwiki.DRouter do
  import Plug.Conn

  def init(options), do: options

  def call(conn, opts) do
    IO.inspect opts
    route(conn.method, conn.path_info, conn)
  end

  def route("GET", [], conn) do
    conn
      |> send_resp(200, "hello")
  end

  def route(_method, _path, conn) do
    conn
      |> send_resp(404, "not found")
  end

end

