use warnings;
use 5.020;
use experimental qw( signatures );
use stable qw( postderef );

package Data::Section::Writer {

  # ABSTRACT: Write __DATA__ section files for Data::Section, Data::Section::Simple or Mojo::Loader::data_section

=head1 SYNOPSIS

This code:

# EXAMPLE: examples/synopsis.pl

Will add this to the bottom of C<foo.pl>

# EXAMPLE: examples/foo.pl

(binary file truncated for readability)

=head1 DESCRIPTION

This class is an interface for updating the C<__DATA__> section of your Perl module or script programmatically
for it to work with one of the many modules that allows for multiple files in a C<__DATA__> section, such as
L<Data::Section>, L<Data::Section::Simple>, L<Data::Section::Pluggable> or L<Mojo::Loader>.

L<Data::Section> uses a different header format by default, but you can still use this module with it
if you set C<header_re> to C<qr/^@@ (.*)$/>.

=head1 ATTRIBUTES

=head2 perl_filename

The name of the Perl source file.  If not provided then the source for the caller will be used. 

=cut

  use Path::Tiny ();
  use Carp ();
  use Class::Tiny qw( perl_filename _files _same );
  use Ref::Util qw( is_blessed_ref );
  use MIME::Base64 qw(encode_base64);

  sub BUILD ($self, $) {

    # use the callers filename if not provided.
    unless(defined $self->perl_filename) {
      my(undef, $fn) = caller 2;
      $self->perl_filename($fn);
    }

    # upgrade to Path::Tiny if it is not already
    unless(is_blessed_ref $self->perl_filename && $self->isa('Path::Tiny')) {
      $self->perl_filename(Path::Tiny->new($self->perl_filename));
    }

    $self->_files({});

  }

=head1 METHODS

=head2 add_file

 $writer->add_file($text_filename, $content);
 $writer->add_file($binary_filename, $content, 'base64');

Add a file.  Binary files can be encoded using C<base64>.  Such binaries files are
only supported by L<Mojo::Loader> at the moment.

=cut

  sub add_file ($self, $filename, $content, $encoding=undef) {
    Carp::croak("Unknown encoding $encoding") if defined $encoding && $encoding ne 'base64';
    $self->_files->{"$filename"} = [ $content, $encoding ];
    return $self;
  }

  sub _render_file ($self, $filename, $data) {
    my $text = "@@ $filename";
    $text .= " (" . $data->[1] . ")" if defined $data->[1];
    $text .= "\n";
    if(defined $data->[1] && $data->[1] eq 'base64') {
      $text .= encode_base64($data->[0]);
    } else {
      $text .= $data->[0];
    }
    chomp $text;
    return $text;
  }

=head2 render_section

 my $perl = $writer->render_section;

Returns the C<__DATA__> section.

=cut

  sub render_section ($self) {
    my $files = $self->_files;
    return "__DATA__\n" unless %$files;
    return join("\n",
      "__DATA__",
      (map { $self->_render_file($_, $files->{$_}) } sort keys $files->%*),
      ''
    );
  }

=head2 update_file

 $writer->update_file;

Update the existing Perl source file, OR create a new Perl source file with just the C<__DATA__> section.

[version 0.02]

Starting with version 0.02, this method will not write to the file if the content won't change.

=cut

  sub update_file ($self) {
    my $perl;
    my $orig;

    if(-f $self->perl_filename) {
      $orig = $perl = $self->perl_filename->slurp_utf8;

      if($perl =~ /^__DATA__/) {
        $perl = '';
      } else {
        # read the file in, removing __DATA__ and everything after that
        # if there is no __DATA__ section then leave unchanged.
        $perl =~ s/(?<=\n)__DATA__.*//s;

        # Add a new line at the end if it doesn't already exist.
        $perl .= "\n" unless $perl =~ /\n\z/s;
      }

    } else {
      $perl = '';
    }

    $perl .= $self->render_section;

    if(defined $orig && $orig eq $perl) {
      $self->_same(1);
      return $self;
    } else {
      $self->_same(0);
    }

    # re-write the perl with the
    $self->perl_filename->spew_utf8($perl);

    return $self;
  }

=head2 unchanged

[version 0.02]

 my $bool = $self->unchanged;

Returns:

=over 4

=item `undef`

If </update_file> hasn't been called yet.

=item `0`

If the last call to </update_file> modified the file.

=item `1`

If the last call to </update_file> did not modify the file.

=back

=cut

  sub unchanged ($self) {
      return $self->_same;
  }

}

1;

=head1 CAVEATS

Added text files will get an added trailing new line if they do not already have
them.  This is a requirement of the format used by the data section modules.

For binary files (base64 encoded) the content returned by L<Mojo::Loader> should
be identical.

Not tested, and probably not working for Windows formatted text files, though
patches for this are welcome.

=head1 SEE ALSO

=over 4

=item L<Data::Section::Pluggable>

=back

=cut
