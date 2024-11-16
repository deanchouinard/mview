defmodule DwikiWeb.PageController do
  use DwikiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
