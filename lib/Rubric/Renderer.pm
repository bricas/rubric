use strict;
use warnings;
package Rubric::Renderer;
our $VERSION = '0.143';

=head1 NAME

Rubric::Renderer - the rendering interface for Rubric

=head1 VERSION

version 0.143

=head1 DESCRIPTION

Rubric::Renderer provides a simple interface for rendering entries, entry sets,
and other things collected by Rubric::WebApp.

=cut

use Carp;
use File::ShareDir;
use File::Spec;
use HTML::Widget::Factory;
use Rubric;
use Rubric::Config;
use Template;
use Template::Filters;

=head1 METHODS

=head2 register_type($type => \%arg)

This method registers a format type by providing a little data needed to render
to it.  The hashref of arguments must include C<content_type>, used to set the
MIME type of the returned ouput; and C<extension>, used to find the primary
template.

This method returns a Template object, which is registered as the renderer for
this type.  This return value may change in the future.

=cut

my %renderer;

sub register_type {
  my ($class, $type, $arg) = @_;
  $renderer{$type} = $arg;
  $renderer{$type}{renderer} = Template->new({
    PROCESS      => ("template.$arg->{extension}"),
    INCLUDE_PATH => [
      Rubric::Config->template_path,
      File::Spec->catdir(File::ShareDir::dist_dir('Rubric'), 'templates'),
    ],
  });
}

__PACKAGE__->register_type(@$_) for (
  [ html => { content_type => 'text/html; charset="utf-8"', extension => 'html' } ],
  [ rss  => { content_type => 'application/rss+xml', extension => 'rss'  } ],
  [ txt  => { content_type => 'text/plain',          extension => 'txt'  } ],
  [ api  => { content_type => 'text/xml',            extension => 'api'  } ],
);

=head2 process($template, $type, \%stash)

This method renders the named template using the registered renderer for the
given type, using the passed stash variables.

The type must be rendered with Rubric::Renderer before this method is called.

In list context, this method returns the content type and output document as a
two-element list.  In scalar context, it returns the output document.

=cut

my $xml_escape = sub {
  for (shift) {
    s/&/&amp;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    s/"/&quot;/g;
    s/'/&apos;/g;
    return $_;
  }
};

sub process { 
  my ($class, $template, $type, $stash) = @_;
  return unless $renderer{$type};

  $stash->{xml_escape} = $xml_escape;
  $stash->{version}    = $Rubric::VERSION;
  $stash->{widget}     = HTML::Widget::Factory->new;
  # 2007-05-07
  # XXX: we only should create one factory per request, tops -- rjbs,

  $template .= '.' . $renderer{$type}{extension};
  $renderer{$type}{renderer}->process($template, $stash, \(my $output))
    or die "Couldn't render template: " . $renderer{$type}{renderer}->error;

  die "template produced no content" unless $output;

  return wantarray
    ? ($renderer{$type}{content_type}, $output)
    :  $output;
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
