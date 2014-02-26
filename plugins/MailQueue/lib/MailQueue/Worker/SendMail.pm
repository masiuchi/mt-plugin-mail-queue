package MailQueue::Worker::SendMail;
use strict;
use warnings;
use base qw( TheSchwartz::Worker );

use JSON;
use TheSchwartz::Job;
use MT;
use MailQueue::Callback;

sub work {
    my $class = shift;
    my TheSchwartz::Job $job = shift;

    my $arg = JSON::decode_json( $job->arg );
    MailQueue::Callback::send( 'MT::Mail', @$arg )
        or return $job->failed( 'Cannot send e-mail: ' . MT::Mail->errstr() );

    return $job->completed();
}

sub grab_for    {60}
sub max_retries {0}
sub retry_delay {60}

1;
