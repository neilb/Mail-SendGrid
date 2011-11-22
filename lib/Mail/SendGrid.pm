use strict;
use warnings;
package Mail::SendGrid;
# ABSTRACT: interface to SendGrid.com mail gateway APIs

use Mouse 0.94;
use HTTP::Tiny 0.013;
use XML::Simple 2.18;
use URI::Escape 3.30;
use Carp 1.20;

use Mail::SendGrid::Bounce;

has 'api_user'     => (is => 'ro', isa => 'Str', required => 1);
has 'api_key'      => (is => 'ro', isa => 'Str', required => 1);

my %bounce_params =
(
    days       => '\d+',
    start_date => '\d\d\d\d-\d\d-\d\d',
    end_date   => '\d\d\d\d-\d\d-\d\d',
    limit      => '\d+',
    offset     => '\d+',
    type       => 'hard|soft',
    email      => '\S+@\S+',
);

sub bounces
{
    my $self     = shift;
    my %opts     = @_;
    my $base_uri = 'https://sendgrid.com/api/bounces.get.xml';
    my %params   = (
                    api_user => $self->api_user,
                    api_key  => $self->api_key,
                    date     => 1,
                   );
    my $response;
    my $uri;
    my $data;
    my (@bounces, $bounce);

    foreach my $opt (keys %opts) {
        if (not exists($bounce_params{$opt})) {
            carp "Mail::SendGrid::bounces(): unknown parameter '$opt'";
            return ();
        }
        if ((not defined($opts{$opt})) || ($opts{$opt} !~ /^($bounce_params{$opt})$/)) {
            carp "Mail::SendGrid::bounces(): invalid value '$opts{$opt}' for parameter '$opt'";
            return ();
        }
        $params{$opt} = $opts{$opt};
    }

    $uri      = $base_uri.'?'.join('&', map { $_.'='.uri_escape($params{$_}) } keys %params);
    $response = HTTP::Tiny->new->get($uri);

    if ($response->{success})
    {
        $data = XMLin($response->{content},
                      SuppressEmpty => '', ForceArray => [ 'bounce' ]);
        if (ref($data) && exists($data->{'bounce'})) {
            foreach my $hashref (@{ $data->{'bounce'} })
            {
                $bounce = Mail::SendGrid::Bounce->new($hashref);
                push(@bounces, $bounce) if defined($bounce);
            }
        }
    }
    else
    {
        carp "bounces request failed\n",
             " status code = $response->{status}\n",
             " reason      = $response->{reason}\n";
    }
    return @bounces;
}

1;

=head1 SYNOPSIS

 use Mail::SendGrid;
 
 $sendgrid = Mail::SendGrid->new('api_user' => '...', 'api_key' => '...');
 print "Email to the following addresses bounced:\n";
 foreach my $bounce ($sendgrid->bounces)
 {
     print "\t", $bounce->email, "\n";
 }

=head1 DESCRIPTION

This module provides easy access to the APIs provided by sendgrid.com, a service for sending emails.
At the moment the module just provides the C<bounces()> method. Over time I'll add more of the
SendGrid API.

=method new

Takes two parameters, api_user and api_key, which were specified when you registered your account
with SendGrid. These are required.

=method bounces ( %params )

This requests bounces from SendGrid,
and returns a list of Mail::SendGrid::Bounce objects.
By default it will pull back all bounces, but you can use the following
parameters to constrain which bounces are returned:

=over 4

=item days => N

Number of days in the past for which to return bounces.
Today counts as the first day.

=item start_date => 'YYYY-MM-DD'

The start of the date range for which to retrieve bounces.
The date must be in ISO 8601 date format.

=item end_date => 'YYYY-MM-DD'

The end of the date range for which to retrieve bounces.
The date must be in ISO 8601 date format.

=item limit => N

The maximum number of bounces that should be returned.

=item offset => N

An offset into the list of bounces.

=item type => 'hard' | 'soft'

Limit the returns to either hard or soft bounces. A soft bounce is one which would have
a 4xx SMTP status code, a persistent transient failure. A hard bounce is one which would
have a 5xx SMTP status code, or a permanent failure.

=item email => 'email-address'

Only return bounces for the specified email address.

=back

For example, to get a list of all soft bounces over the last week, you would use:

  @bounces = $sendgrid->bounces(type => 'soft', days => 7);

=head1 SEE ALSO

=over 4

=item L<Mail::SendGrid::Bounce>

The class which defines the data objects returned by the bounces method.

=item SendGrid API documentation

L<http://docs.sendgrid.com/documentation/api/web-api/webapibounces/>

=back
