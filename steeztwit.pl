#!/usr/bin/perl /home/james/Projects/twitbot/steeztwit.pl
use strict;
use warnings;
use Net::Twitter::Lite::WithAPIv1_1;
use Try::Tiny;

sub tweet{
  my ($text) = @_;
  unless ($ENV{TWITTER_CONSUMER_KEY}
          && $ENV{TWITTER_CONSUMER_SECRET}
          && $ENV{TWITTER_ACCESS_SECRET}
          && $ENV{TWITTER_ACCESS_TOKEN}){
    die 'Twitter ENV not configured';
  }

  # build tweet, max 140 chars
  my $tweet;
  if (length("$text") < 140){
    $tweet = "$text";
  }
  else{
    $tweet = substr($text, 0, 139);
  }

  try{
    my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
      access_token_secret => $ENV{TWITTER_ACCESS_SECRET},
      consumer_secret     => $ENV{TWITTER_CONSUMER_SECRET},
      access_token        => $ENV{TWITTER_ACCESS_TOKEN},
      consumer_key        => $ENV{TWITTER_CONSUMER_KEY},
      user_agent          => 'SteezBotExample',
      ssl => 1);
    $twitter->update($tweet);
  } catch{
    die join(' ', "Error tweeting $text", $_->code, $_->message, $_->error);
  };
}

# Send it
my $text = substr(join(" ", @ARGV), 15, 139);
tweet($text);
print("\nsent :^)\n");
