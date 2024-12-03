use Test2::V0 -no_srand => 1;
use Data::Section::Writer;

is(
  Data::Section::Writer->new,
  object {
    prop isa => 'Data::Section::Writer';
    call perl_filename => object {
      prop isa => 'Path::Tiny';
      call stringify => __FILE__;
    };
    call render_section => "__DATA__\n";
  },
  'defaults',
);

is(
  Data::Section::Writer->new( perl_filename => 'Foo/Bar.pm' ),
  object {
    prop isa => 'Data::Section::Writer';
    call perl_filename => object {
      prop isa => 'Path::Tiny';
      call stringify => 'Foo/Bar.pm';
    };
    call render_section => "__DATA__\n";
  },
  'upgrade perl_filename',
);

is(
  Data::Section::Writer->new,
  object {
    prop isa => 'Data::Section::Writer';
    call [add_file => 'foo.txt', "Foo Bar Baz"] => object {
      prop isa => 'Data::Section::Writer';
    };
    call [add_file => 'bar.bin', "Foo Bar Baz", 'base64'] => object {
      prop isa => 'Data::Section::Writer';
    };
    call render_section => "__DATA__\n\n" .
                           "\@\@ bar.bin (base64)\n" .
                           "Rm9vIEJhciBCYXo=\n\n" .
                           "\@\@ foo.txt\n" .
                           "Foo Bar Baz\n";
  },
  'add_section_file',
);

done_testing;


