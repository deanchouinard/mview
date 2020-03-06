defmodule Mview.Convert do

  def as_html!(page_path) do

    # System.cmd("pandoc", ["-niHdskip", "#{stext}" | Path.wildcard("#{path}/*")]) do

    #    :os.cmd('echo \"#{source}\" | pandoc')

    {contents, _} = System.cmd("pandoc", [page_path, "-f", "gfm+hard_line_breaks", "-t", "html"])
    contents = String.replace(contents, ~r/\[\[(.+)\]\]/, 
      "<a href='http://penguin.linux.test:4000/page/\\1' target='_blank'>\\1</a>")
  end

end
