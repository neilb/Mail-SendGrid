package Mail::SendGrid::Bounce;
# ABSTRACT: data object that holds information about a SendGrid bounce
use strict;
use warnings;

use Mouse 0.94;

has 'email'     => (is => 'ro', isa => 'Str');
has 'created'   => (is => 'ro', isa => 'Str');
has 'status'    => (is => 'ro', isa => 'Str');
has 'reason'    => (is => 'ro', isa => 'Str');

our $VERSION = '0.01';


1;

=head1 SYNOPSIS

    use Mail::SendGrid::Bounce;

    $bounce = Mail::SendGrid::Bounce(
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

Not sure.

=method reason

The reason why the message bounced; typically this is the reason returned
by the remote MTA.

=head1 SEE ALSO

=over 4

=item SendGrid API documentation

L<http://docs.sendgrid.com/documentation/api/web-api/webapibounces/>

=back

