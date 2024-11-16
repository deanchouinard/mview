# mview
A Markdown Viewer

Mview displays and searches Markdown files. Run Mview in a directory and it
will display a tab listing all the files in each subdirectory. Click a file
name to display its Markdown formatted contents.

You can also search through the contents of files in a subdirectory. Mview will
display a list of all files with content that matches the search. Clicking on a
match will display the file.

I use Mview every day. I keep most of my writing in small Markdown formatted
text files located in several topical subdirectories. With Mview I can easily
view and search my files.

I started this project as a way to learn Plug. Along the way I not only
learned about Plug but also came to appreciate the capabilities and
conveniences of Phoenix.


## Usage
1. Clone the project
2. Build the escript
3. Copy the mview executable to the directory containing your writing
subdirectories.
4. ./mview
5. Browse to localhost:4100

### Mix Task
A mix task to build and copy mview: ``mix mview.wrt``

### Linking
You can link to another file with the `[[TechNotes/nerves.md]]` syntax.
Note that you must specify the relative directory path from the parent directory.

### Note about directory structure
Mview expects to be run in a parent directory with subdirectories containing your
Markdown files. It does not display the contents of the parent directory other than
building a tab listing your files for each subdirectory.

### Running in Development Mode and Tests
To run in development mode use `mix run --no-halt`. Browse to `localhost:4000`
to view the sample pages.
To run tests use `mix test`.
A set of sample pages is kept in the `pages` directory. Both tests and development mode
use these pages to exercise features.

# Archive

Lists files from a directory. Clicking a link will display the file. Searching
displays matches and clicking a match will display the file.

Almost like a wiki except cannot edit the file. File editing is done with
another program such as a text editor or Markdown editor.

I built this for my own use. I have a lot of Markdown files and this makes it
easy to search and view their formatted representation.

Aside from my motivation to view my Markdown files, I also wanted to
experiment with Plug. So, a lot of what you see here are my explorations
in Plug.

