#!/usr/bin/perl /home/james/Projects/twitbot/steeztwit.pl
use utf8;
use open ':encoding(utf8)';
use strict;
use warnings;
use Getopt::Long;
use Net::Twitter::Lite::WithAPIv1_1;
use Try::Tiny;

# fix UTF-8 output
binmode(STDOUT, ":utf8");

# check for env vars
unless ($ENV{TWITTER_CONSUMER_KEY}
          && $ENV{TWITTER_CONSUMER_SECRET}
          && $ENV{TWITTER_ACCESS_SECRET}
          && $ENV{TWITTER_ACCESS_TOKEN}){
    die 'Twitter ENV not configured';
}

# parse cli args
my $timeline;
my $mentions;
my $sendtweet;

GetOptions(
    "sendtweet=s"       => \$sendtweet, # string
    "mentions"         => \$mentions, # bool
    "timeline"         => \$timeline # bool
);

# setup connection
my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
    access_token_secret => $ENV{TWITTER_ACCESS_SECRET},
    consumer_secret     => $ENV{TWITTER_CONSUMER_SECRET},
    access_token        => $ENV{TWITTER_ACCESS_TOKEN},
    consumer_key        => $ENV{TWITTER_CONSUMER_KEY},
    user_agent          => 'SteezBot',
    ssl => 1);

sub tweet{
    # clean tweet, max 240 chars
    if (!(length($sendtweet) < 240)){
        $sendtweet = substr($sendtweet, 0, 239);
    }
    try{
        $twitter->update($sendtweet);
    } catch{
        die join(' ',
                 "Error tweeting $sendtweet",
                 $_->code,
                 $_->message,
                 $_->error);
    };
}

if ($sendtweet){
    print 'TWEETED: '.$sendtweet."\n";
    tweet($sendtweet);
}

if ($timeline){
    eval {
        my $statuses = $twitter->home_timeline({ count => 5 });
        for my $status ( @$statuses ) {
            print("$status->{created_at} ".
                  "<$status->{user}{screen_name}> ".
                  "$status->{text}\n");
        }
    };
}

if ($mentions){
    eval {
        my $mentions = $twitter->mentions({ count => 5 });
        for my $mention ( @$mentions ) {
            print("$mention->{created_at} ".
                  "<$mention->{user}{screen_name}> ".
                  "$mention->{text}\n");
        }
    }
}
