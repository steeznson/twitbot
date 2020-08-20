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
my $count = 5;
my $timeline;
my $mentions;
my $posttweet;
my $user;
my $search;
my $help;

GetOptions(
    "count=i" => \$count, # int
    "posttweet=s" => \$posttweet, # string
    "user=s" => \$user, # string
    "search=s" => \$search, # string
    "mentions" => \$mentions, # bool
    "timeline" => \$timeline, # bool
    "help" => \$help # bool
);

# setup connection
my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
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
        $nt->update($posttweet);
    } catch{
        die join(' ',
                 "Error tweeting $posttweet",
                 $_->code,
                 $_->message,
                 $_->error);
    };
}

if ($help){
    print(
        "--count, -c : (int) specify number of tweets to fetch\n" .
        "--posttweet, -p : (str) post tweet\n" .
        "--user, -u : (str) search another user timeline\n" .
        "--search, -s : (str) search all recent tweets\n" .
        "--mentions, -m : see recent mentions\n" .
        "--timeline, -t : see my timeline\n" .
        "--help, -h : see help\n");
}

if ($posttweet){
    print 'TWEETED: '.$posttweet."\n";
    tweet($posttweet);
}

if ($timeline){
    eval {
        my $statuses = $nt->home_timeline({ count => $count, tweet_mode => "extended" });
        for my $status ( @$statuses ) {
            print("$status->{created_at} ".
                  "<$status->{user}{screen_name}> ".
                  "$status->{full_text}\n");
        }
    };
}

if ($user){
    eval {
        my $statuses = $nt->
            user_timeline({ count => $count, screen_name => $user, tweet_mode => "extended" });
        for my $status ( @$statuses ) {
            print("$status->{created_at} ".
                  "<$status->{user}{screen_name}> ".
                  "$status->{full_text}\n");
        }
    };
}

if ($mentions){
    eval {
        my $mentions = $nt->mentions({ count => $count, tweet_mode => "extended" });
        for my $mention ( @$mentions ) {
            print("$mention->{created_at} ".
                  "<$mention->{user}{screen_name}> ".
                  "$mention->{full_text}\n");
        }
    };
}

if ($search){
    eval {
        my $searchresults = $nt->search($search);
        for my $res ( @{$searchresults->{statuses}} ) {
            print "$res->{text}\n";
        }
    };
}
