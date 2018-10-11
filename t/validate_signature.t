#!/usr/bin/perl
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Test::Exception;

use LINE::Bot::API;

my $json = <<JSON;
{
  "events": [
    {
      "replyToken": "00000000000000000000000000000000",
      "type": "message",
      "timestamp": 1539273157200,
      "source": {
        "type": "user",
        "userId": "Udeadbeefdeadbeefdeadbeefdeadbeef"
      },
      "message": {
        "id": "100001",
        "type": "text",
        "text": "Hello, world"
      }
    },
    {
      "replyToken": "ffffffffffffffffffffffffffffffff",
      "type": "message",
      "timestamp": 1539273157200,
      "source": {
        "type": "user",
        "userId": "Udeadbeefdeadbeefdeadbeefdeadbeef"
      },
      "message": {
        "id": "100002",
        "type": "sticker",
        "packageId": "1",
        "stickerId": "1"
      }
    }
  ]
}
JSON

my $bot = LINE::Bot::API->new(
  channel_secret       => '4065415af4324c402286d732539ccc79',
  channel_access_token => 'tbUh6CQnHgZjh5oNbqQl5m2U/+5LBhfqZ+OCwIL4NtTz72pTym6EKKWTXUPEAf5yMDrj/BcGBbvojewktdQ/03xeiYI2+NDVGoYEy7zhoXhEh0SdMQ45vQkvUriGCK4VlRlFMazOoWUzRg0q/pz3XwdB04t89/1O/w1cDnyilFU='
);

ok($bot->validate_signature($json, '/BmZra24sAw16Zt6Dmu21ernw3NuBqeYVWs3w09F6BU='));

done_testing();
