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

This class is an interface for updating the `__DATA__` section of your Perl module or script programmatically
for it to work with one of the many modules that allows for multiple files in a `__DATA__` section, such as
[Data::Section](https://metacpan.org/pod/Data::Section), [Data::Section::Simple](https://metacpan.org/pod/Data::Section::Simple) or [Mojo::Loader](https://metacpan.org/pod/Mojo::Loader).

# ATTRIBUTES

## perl\_filename

The name of the Perl source file.  If not provided then the source for the caller will be used. 

# METHODS

## add\_file

```
$writer->add_file($text_filename, $content);
$writer->add_file($binary_filename, $content, 'base64');
```

Add a file.  Binary files can be encoded using `base64`.  Such binaries files are
only supported by [Mojo::Loader](https://metacpan.org/pod/Mojo::Loader) at the moment.

## render\_section

```perl
my $perl = $writer->render_section;
```

Returns the `__DATA__` section.

## update\_file

```
$writer->update_file;
```

Update the existing Perl source file, OR create a new Perl source file with just the `__DATA__` section.

# CAVEATS

Added text files will get an added trailing new line if they do not already have
them.  This is a requirement of the format used by the data section modules.

For binary files (base64 encoded) this isn't relevant.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
