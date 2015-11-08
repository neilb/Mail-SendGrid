package Mail::SendGrid::Bounce;

# ABSTRACT: data object that holds information about a SendGrid bounce
use strict;
use warnings;

use 5.008;
use Moo 1.006;

has 'email'     => (is => 'ro', required => 1);
has 'created'   => (is => 'ro', required => 1);
has 'status'    => (is => 'ro', required => 1);
has 'reason'    => (is => 'ro', required => 1);

1;

=head1 SYNOPSIS

    use Mail::SendGrid::Bounce;

    $bounce = Mail::SendGrid::Bounce->new(
                        email   => '...',
                        created => '...',
                        status  => '...',
                        reason  => '...',
                       );

=head1 DESCRIPTION

This class defines a data object which is returned by the C<bounces()>
method in L<Mail::SendGrid>. Generally you won't instantiate this
module yourself.

=method email

The email address you tried sending to, which resulted in a bounce
back to SendGrid.

=method created

Date and time in ISO date format. I'm assuming this is the timestamp
for when the bounce was received back at SendGrid.

=method status

A string which identifies the type of bounce. At the moment my understanding is
that this will either be the string '4.0.0' for a soft bounce, and '5.0.0' for
a hard bounce. I'm trying to get confirmation or clarification from SendGrid.

=method reason

The reason why the message bounced; typically this is the reason returned
by the remote MTA. Sometimes the reason string will start with the SMTP response
code; I'm trying to find out from SendGrid in what situations that isn't true.

=head1 SEE ALSO

=over 4

=item SendGrid API documentation

L<http://docs.sendgrid.com/documentation/api/web-api/webapibounces/>

=back

