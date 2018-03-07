move load_sort out of plug pipeline
evaluate tests
a lot of refactoring to do

rather than have a config file that sets the tabs, read any subdirs of the
current director and use them as tabs. Look for a .mview_tab.txt file in
each subdir for the tab description

move any HTML building functions into their own module

