use warnings;
use 5.020;
use true;
use experimental qw( signatures );

package Data::Section::Pluggable::Role::FormatContentPlugin {

    # ABSTRACT: Plugin role for Data::Section::Writer

    use Role::Tiny;
    requires 'extensions';
    requires 'format_content';

}
