defmodule MviewPageTest do
  use ExUnit.Case
  alias Mview.Page

  @dirs [["/one", "One"], ["/two", "Two"], ["/three", "Three"]]

  test "finds correct tab" do
    tab = "Two"
    [dir, label] = Page.find_active_tab(@dirs, tab)
    assert dir == "/two"
    assert label == "Two"
    tab = "One"
    [dir, label] = Page.find_active_tab(@dirs, tab)
    assert dir == "/one"
    assert label == "One"
  end

#  @tag :pending
  test "builds correct active tab" do
    # dparams = %{dirs: [], sort: "", tab: ""}
    # label = ["Two"]
    # dirs = "foo"
    %Mview.Dirs{dirs: dirs, sort: sort, tab: label} = Mview.Dirs.init_dirs()
    page = Page.tab_page(%{dirs: dirs, sort: sort}, label)
    assert page =~ "<a class=\"nav-link active\" href=\"/tab/Journal\">Journal</a></li>"
  end
  

end

