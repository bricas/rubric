package Rubric::WebApp::URI;

=head1 NAME

Rubric::WebApp::URI - URIs for Rubric web requests

=head1 VERSION

 $Id$

=head1 DESCRIPTION

This module provides methods for generating the URIs for Rubric requests.

=cut

use strict;
use warnings;

use Rubric::Config;

=head1 METHODS

=head2 root

the URI for the root of the Rubric; taken from uri_root in config

=cut

sub root { Rubric::Config->uri_root }
	
=head2 stylesheet

the URI for the stylesheet

=cut

sub stylesheet { Rubric::Config->uri_root . '/style/rubric.css'; }

=head2 logout

URI to log out

=cut

sub logout { Rubric::Config->uri_root . '/logout' }

=head2 login

URI to form for log in

=cut

sub login { Rubric::Config->uri_root . '/login' }

=head2 reset_password

URI to reset user password

=cut

sub reset_password {
	my ($class, $arg) = @_;
	my $uri = Rubric::Config->uri_root . '/reset_password';
	if ($arg->{user} and defined $arg->{reset_code}) {
		$uri .= "/$arg->{user}/$arg->{reset_code}";
	}
	return $uri;
}

=head2 newuser

URI to form for new user registration form;  returns false if registration is
closed.

=cut

sub newuser {
	return if Rubric::Config->registration_closed;
	return Rubric::Config->uri_root . '/newuser';
}

=head2 entries(\%arg)

URI for entry listing; valid keys for C<%arg>:

 user - entries for one user
 tags - arrayref of tag names

=cut

sub entries {
	my ($class, $arg) = @_;
	$arg->{tags} ||= {};
  $arg->{tags} = { map { $_ => undef } @{$arg->{tags}} }
    if ref $arg->{tags} eq 'ARRAY';

	my $format = delete $arg->{format};

	my $uri = $class->root . '/entries';
	$uri .= "/user/$arg->{user}" if $arg->{user};
	$uri .= '/tags/' . join('+', keys %{$arg->{tags}}) if %{$arg->{tags}};
	for (qw(has_body has_link)) {
		$uri .= "/$_/" . ($arg->{$_} ? 1 : 0)
			if (defined $arg->{$_} and $arg->{$_} ne '');
	}
	$uri .= "/urimd5/$arg->{urimd5}" if $arg->{urimd5};
	$uri .= "?format=$format" if $format;
	return $uri;
}

=head2 entry($entry)

URI to view entry

=cut

sub entry {
	my ($class, $entry) = @_;
	return unless UNIVERSAL::isa($entry,  'Rubric::Entry');

	return Rubric::Config->uri_root . "/entry/" . $entry->id;
}


=head2 edit_entry($entry)

URI to edit entry

=cut

sub edit_entry {
	my ($class, $entry) = @_;
	return unless UNIVERSAL::isa($entry,  'Rubric::Entry');

	return Rubric::Config->uri_root . "/edit/" . $entry->id;
}

=head2 delete_entry($entry)

URI to delete entry

=cut

sub delete_entry {
	my ($class, $entry) = @_;
	return unless UNIVERSAL::isa($entry,  'Rubric::Entry');

	return Rubric::Config->uri_root . "/delete/" . $entry->id;
}

=head2 post_entry

URI for new entry form

=cut

sub post_entry { Rubric::Config->uri_root . "/post"; }

=head2 by_date

URI for by_date

=cut

sub by_date {
	my ($class) = @_;
  shift;
  my $year = shift;
  my $month = shift;
  my $uri = '/calendar';
  $uri .= "/$year" if ($year);
  $uri .= "/$month" if ($month);

	Rubric::Config->uri_root . $uri;
}



=head2 tag_cloud

URI for all tags / tag cloud

=cut

sub tag_cloud { 
	my ($class) = @_;
	Rubric::Config->uri_root . "/tag_cloud";
}

=head2 preferences

URI for preferences form

=cut


sub preferences { Rubric::Config->uri_root . "/preferences"; }

=head2 verify_user

URI for new entry form

=cut

sub verify_user {
	my ($class, $user) = @_;
	Rubric::Config->uri_root . "/verify/$user/" . $user->verification_code;
}

=head2 doc($doc_page)

URI for documentation page.

=cut

sub doc {
	my ($class, $doc_page) = @_;
	Rubric::Config->uri_root . "/doc/" . $doc_page;
}

=head1 TODO

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-rubric@rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org>. I will be notified, and
then you'll automatically be notified of progress on your bug as I make
changes.

=head1 COPYRIGHT

Copyright 2004 Ricardo SIGNES.  This program is free software;  you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
