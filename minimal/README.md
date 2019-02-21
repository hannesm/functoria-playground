## minimal

minimizes storage-select

in the `let store`, the expression `p2 $ default_posix_clock` is used twice. This leads to an assertion failure in app/functoria_graph.ml on line 248.
