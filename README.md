# Data::Section::Writer ![static](https://github.com/uperl/Data-Section-Writer/workflows/static/badge.svg) ![linux](https://github.com/uperl/Data-Section-Writer/workflows/linux/badge.svg)

Write \_\_DATA\_\_ section files for Data::Section, Data::Section::Simple or Mojo::Loader::data\_section

# SYNOPSIS

This code:

```perl
use strict;
use warnings;
use Data::Section::Writer;
use Path::Tiny qw( path );

Data::Section::Writer
  ->new( perl_filename => "foo.pl" )
  ->add_file( "hello.txt", "hello world" )
  ->add_file( "a.out", path("a.out")->slurp_raw, 'base64' )
  ->update_file;
```

Will add this to the bottom of `foo.pl`

```
__DATA__
@@ a.out (base64)
f0VMRgIBAQAAAAAAAAAAAAMAPgABAAAAQBAAAAAAAABAAAAAAAAAAGA2AAAAAAAAAAAAAEAAOAAN
AEAAHQAcAAYAAAAEAAAAQAAAAAAAAABAAAAAAAAAAEAAAAAAAAAA2AIAAAAAAADYAgAAAAAAAAgA
AAAAAAAAAwAAAAQAAAAYAwAAAAAAABgDAAAAAAAAGAMAAAAAAAAcAAAAAAAAABwAAAAAAAAAAQAA
...
@@ hello.txt
hello world
```

(binary file truncated for readability)

# DESCRIPTION

# ATTRIBUTES

## perl\_filename

# METHODS

## add\_file

## render\_section

## update\_file

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
