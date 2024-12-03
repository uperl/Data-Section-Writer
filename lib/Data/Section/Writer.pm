use warnings;
use 5.020;
use experimental qw( postderef signatures );

package Data::Section::Writer {

  # ABSTRACT: Write __DATA__ section files for Data::Section, Data::Section::Simple or Mojo::Loader::data_section

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 perl_filename

=cut

  use Path::Tiny ();
  use Carp ();
  use Class::Tiny qw( perl_filename _files );
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
    $DB::single = 1;
    if(defined $data->[1] && $data->[1] eq 'base64') {
      $text .= encode_base64($data->[0]);
    } else {
      $text .= $data->[0];
    }
    return $text;
  }

=head2 render_section

=cut

  sub render_section ($self) {
    my $files = $self->_files;
    return "__DATA__\n" unless %$files;
    return join("\n",
      "__DATA__",
      "",
      (map { $self->_render_file($_, $files->{$_}) } sort keys $files->%*),
      ''
    );
  }

=head2 update_file

=cut

  sub update_file ($self) {
    my $perl;

    if(-f $self->perl_filename) {
      # read the file in, removing __DATA__ and everything after that
      # if there is no __DATA__ section then leave unchanged.
      $perl = $self->perl_filename->slurp_utf8 =~ s/(?<=\r?\n)__DATA__.*//sr;

      # Add a new line at the end if it doesn't already exist.
      $perl .= "\n" unless $perl =~ /\n\z/s;

    } else {
      $perl = '';
    }

    # re-write the perl with the 
    $self->perl_filename->spew_utf8(
      $perl . $self->render_section,
    );

    return $self;
  }

}

1;
