package MailQueue::Callback;
use strict;
use warnings;

use JSON;
use TheSchwartz::Job;
use MT::Mail;
use MT::TheSchwartz;

our $UNIQKEY_SIZE = 255;

*send = \&MT::Mail::send;

sub init_app {
    no warnings 'redefine';
    *MT::Mail::send = sub {
        my $job = TheSchwartz::Job->new();
        $job->funcname('MailQueue::Worker::SendMail');
        $job->priority(4);

        my @alpha = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
        my $uniqkey = join '', map $alpha[ rand @alpha ], 1 .. $UNIQKEY_SIZE;
        $job->uniqkey($uniqkey);

        shift @_;
        my $data = JSON::encode_json( \@_ );
        $job->arg($data);

        MT::TheSchwartz->insert($job);

        return 1;
    };
}

1;
