#!/usr/bin/perl /home/james/programs/twitbot/steeztwit.pl
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
my $posttweet;
my $user;
my $search;

GetOptions(
    "posttweet=s" => \$posttweet, # string
    "user=s" => \$user, # string
    "search=s" => \$search, # string
    "mentions" => \$mentions, # bool
    "timeline" => \$timeline # bool
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
    if (!(length($posttweet) < 240)){
        $posttweet = substr($posttweet, 0, 239);
    }
    try{
        $twitter->update($posttweet);
    } catch{
        die join(' ',
                 "Error tweeting $posttweet",
                 $_->code,
                 $_->message,
                 $_->error);
    };
}

if ($posttweet){
    print 'TWEETED: '.$posttweet."\n";
    tweet($posttweet);
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

if ($user){
    eval {
        my $statuses = $twitter->
            user_timeline({ count => 5, screen_name => $user });
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

if ($search){
    eval {
        my $searchresults = $twitter->search($search);
        for my $res ( @{$searchresults->{statuses}} ) {
            print "$res->{text}\n";
        }
    }
}
