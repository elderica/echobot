package Echobot::Util;
use Mojo::Base -strict;

use Exporter 'import';
our @EXPORT = qw|verify_line_signature|;
our @EXPORT_OK = qw|verify_line_signature|;

use Digest::SHA 'hmac_sha256';
use MIME::Base64 'encode_base64';
use Mojo::Util 'secure_compare';

sub verify_line_signature {
  my $channel_secret = shift;
  my $x_line_signature = shift;
  my $req_body = shift;

  my $signature = encode_base64(hmac_sha256($req_body, $channel_secret), '');

  secure_compare($x_line_signature, $signature)
}

1;