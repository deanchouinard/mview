# Test file
This a test file in the Journal directory.

* bullet list
  * indented
* this is a list that is on multiple lines; the formatting
seems to get messed up
  * this is a second level and now lets
see when it goes on second line

## A Table

| Keyword | Definition |
| --- | --- |
| aa ddd | dkjlkjlk dlkdj |
| eee fkfk | d;sklk;dfks;kd df;ld; dl|


<br>

```
This is code
another line of code
```

> a blockquote
> sometime these don't look good
> really a css problem, work on the css?

A line to test the GFM line breaks
this should be on a new line

How about some indents
    hello
    by

At the end

> should be a quote
> another line of quote

### Internal Links
[[Technical/tech.md]]

[[Technical/xxxx.md]]
Link does not exist.

[[notes/note.md]]
This link will fail until *notes* dir is added into the `dirs` map. Recall that since the *notes*
dir is not initially scanned it doesn't get into the `dirs` map until it is clicked.

Noticed a problem displaying links in the search results:
<http://www.catmountain.com/test>

How about a line on a line with text: <http://www.catmountain.com/test>
Without brackets: http://www.catmountain.com/test
End of file

<img src="/images/3.jpg" alt="drawing" width="200"/>

[freelance](/docs/FreelancerQuickStart.pdf)

![test](/images/3.jpg)

Trying a footnote [^1]

[^1]: This is the footnote

### Test syntax highlighting
~~~elixir 
defmodule Mview.Router do
  use Plug.Router
  plug Plug.Logger
 
  plug Plug.Static, at: "/images", from: "images/"
  plug Plug.Static, at: "/docs", from: "docs/"

  plug :load_session
end
~~~

Test "[[" on a line by itself. The link opening characters should be
there.

