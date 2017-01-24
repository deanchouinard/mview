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


end

