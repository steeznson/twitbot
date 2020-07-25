#!/usr/bin/perl /home/james/programs/twitbot/steeztwit.pl
use utf8;
use open ':encoding(utf8)';
use strict;
use warnings;
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

my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
  access_token_secret => $ENV{TWITTER_ACCESS_SECRET},
  consumer_secret     => $ENV{TWITTER_CONSUMER_SECRET},
  access_token        => $ENV{TWITTER_ACCESS_TOKEN},
  consumer_key        => $ENV{TWITTER_CONSUMER_KEY},
  user_agent          => 'SteezBot',
  ssl => 1);

sub tweet{
  my ($text) = shift;
  # build tweet, max 240 chars
  my $tweet;
  if (length("$text") < 240){
    $tweet = "$text";
  }
  else{
    $tweet = substr($text, 0, 239);
  }
  try{
    $twitter->update($tweet);
  } catch{
    die join(' ', "Error tweeting $text", $_->code, $_->message, $_->error);
  };
}

my $to_tweet;
if (scalar @ARGV > 1){
    $to_tweet = substr(@ARGV, 15, 254);
}

if ($to_tweet){
    print 'TWEETED: '.$to_tweet."\n";
    #tweet($to_tweet);
} else {
    print "~~Timeline~~\n";
    eval {
        my $statuses = $twitter->home_timeline({ count => 5 });
        for my $status ( @$statuses ) {
            print "$status->{created_at} <$status->{user}{screen_name}> $status->{text}\n";
        }
    };
    print "~~Mentions~~\n";
    eval {
        my $mentions = $twitter->({ mentions => 5 });
        for my $mention ( @$mentions ) {
            print "$mention->{created_at} <$mention->{user}{screen_name}> $mention->{text}\n";
        }
    }
}
