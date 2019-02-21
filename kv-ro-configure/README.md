## kv-ro-configure

This is an example where at configuration time the name of a subdirectory to be crunched should be passed.

At the moment, the mirage tool embeds a slightly different version of `crunch`, which is a function expecting a directory (as string). Now, this leads to a bunch of unikernels having hardcoded path names, which is sometimes desirable to have dynamic (at compile time).

It is unclear to me:
(a) how to retrieve the directory name for the "name" method
(b) how to retrieve the directory name within the build method
