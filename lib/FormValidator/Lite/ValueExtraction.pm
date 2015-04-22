package FormValidator::Lite::ValueExtraction;
use strict;
use warnings;

sub determine_callback {
    my $q = shift;
    return
          UNIVERSAL::isa($q, 'CGI') ? \&cgi_cb
        : UNIVERSAL::isa($q, 'Dancer::Request') ? \&dancer_request_cb
        : UNIVERSAL::isa($q, 'Mojo::Message::Request') ? \&mojo_message_request_cb
        :   \&generic_request_cb;
}

sub cgi_cb {
    my ($q, $key) = @_;
    my @val = $q->multi_param($key);
    @val ? @val : undef;
}

sub dancer_request_cb {
    my ($q, $key) = @_;
    my $val = $q->params->{$key};
    ref($val) eq 'ARRAY' ? @$val : $val;
}

sub mojo_message_request_cb {
    my ($q, $key) = @_;
    my $val = $q->every_param($key);
    @$val ? @$val : undef;
}

sub generic_request_cb {
    my ($q, $key) = @_;
    defined $q->param($key) ? $q->param($key) : undef;
}

1;

__END__

=head1 NAME

FormValidator::Lite::ValueExtraction - to extract values associated with
a named parameter from query-like objects

=head1 SYNOPSIS

    my $cb = FormValidator::Lite::ValueExtraction::determine_callback($q);
    #=> Get a callback function to get params from given query-like object

    my @val = $cb->($q, 'name');
    #=> Get all values associated with a named parameter

=head1 DESCRIPTION

Since L<CGI> version 4.08, consistency between various frameworks and libraries
in retrieving multiple values from a named parameter is lost which we formerly
used C<$q-E<gt>param> for both list and scalar context.

This module determines an object and returns appropriate callback function
which returns possible values in list context.

=head1 FUNCTIONS

=head2 determine_callback($q)

Accepts a query-like object and returns one of callback functions listed below
which returns values in B<LIST> context from the given object.

A callback function returned from this function should be called as:

    my @val = $cb->($q, 'name');

and the function returns value(s) associated to specified parameter name,
or C<undef> if not any, in B<LIST> context.

=head2 cgi_cb($q, $name)

A function to be returned by C<determine_callback> when the given C<$q> object
is determined as a L<CGI> object.

=head2 dancer_request_cb($q, $name)

A function to be returned by C<determine_callback> when the given C<$q> object
is determined as a L<Dancer::Request> object.

=head2 mojo_message_request_cb($q, $name)

A function to be returned by C<determine_callback> when the given C<$q> object
is determined as a L<Mojo::Message::Request> object.

=head2 generic_request_cb($q, $name)

A function to be returned by C<determine_callback> when the given C<$q> object
does not match any of the above.

=head1 SEE ALSO

L<CGI>, L<Dancer::Request>, L<Mojo::Message::Request>, L<Plack::Request>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
