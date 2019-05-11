package Lingua::PlantUML::Encode;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(encode_p);

use 5.006;
use strict;
use warnings;

use Encode qw(encode);
use Compress::Zlib;
use MIME::Base64; 

=head1 NAME

Lingua::PlantUML::Encode - an implementation of a PlantUML Language Encoder in Perl

L<http://plantuml.com/text-encoding>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Lingua::PlantUML::Encode;

    my $encoded = encode_p(qq{
       Alice -> Bob: Authentication Request
       Bob --> Alice: Authentication Response
    }});

    print $encoded;
    # outputs 
    # Syp9J4vLqBLJSCfFib9mB2t9ICqhoKnEBCdCprC8IYqiJIqkuGBAAUW2rJY256DHLLoGdrUS2W00

=head1 EXPORT

The only Subroutine that this module exports is C<encode_p>

=head1 SUBROUTINES/METHODS

=head2 utf8_encode

Encoded in UTF-8

=cut

sub utf8_encode { 
  Encode::encode('UTF-8', $_[0], Encode::FB_CROAK) 
}

=head2 _compress_with_deflate

Compressed using Deflate algorithm

=cut

sub _compress_with_deflate {
  my $buffer;
  my $d = deflateInit(-WindowBits => $_[1]);
  $buffer = $d->deflate($_[0]);
  $buffer.= $d->flush();
  return $buffer;
}


=head encode6bit

Transform to String of characters that contains only digits, letters, underscore and minus character

=cut

sub encode6bit {
   my $b = $_[0];
	 if ($b < 10) {
	      return chr(48 + $b);
	 }
	 $b -= 10;
	 if ($b < 26) {
	      return chr(65 + $b);
	 }
	 $b -= 26;
	 if ($b < 26) {
	      return chr(97 + $b);
	 }
	 $b -= 26;
	 if ($b == 0) {
	      return '-';
	 }
	 if ($b == 1) {
	      return '_';
	 }
	 return '?';
}

=head append3bytes

Transform adjacent bytes

=cut

sub append3bytes {
   my ($c1, $c2, $c3, $c4, $r);
   my $b1 = $_[0];
   my $b2 = $_[1];
   my $b3 = $_[2];
	 $c1 = $b1 >> 2;
	 $c2 = (($b1 & 0x3) << 4) | ($b2 >> 4);
	 $c3 = (($b2 & 0xF) << 2) | ($b3 >> 6);
	 $c4 = $b3 & 0x3F;
	 $r = "";
	 $r .= encode6bit($c1 & 0x3F);
	 $r .= encode6bit($c2 & 0x3F);
	 $r .= encode6bit($c3 & 0x3F);
	 $r .= encode6bit($c4 & 0x3F);
	 return $r;
}

=head2 encode64

Reencoded in ASCII using a transformation close to base64

=cut

sub encode64 {
   my $c = $_[0];
	 my $str = "";
	 my $len = length $c;
   my $i;
	 for ($i = 0; $i < $len; $i+=3) {
	        if ($i+2==$len) {
	              $str .= append3bytes(ord(substr($c, $i, 1)), ord(substr($c, $i+1, 1)), 0);
	        } elsif ($i+1==$len) {
	              $str .= append3bytes(ord(substr($c, $i, 1)), 0, 0);
	        } else {
	              $str .= append3bytes(ord(substr($c, $i, 1)), ord(substr($c, $i+1, 1)),
	                  ord(substr($c, $i+2, 1)));
	        }
	 }
	 return $str;
}

=head2 encode_p

Encodes diagram text descriptions 

=cut

sub encode_p {
	 my $data = utf8_encode($_[0]);
	 my $compressed = _compress_with_deflate($data, 9);
	 return encode64($compressed);
}


=head1 AUTHOR

Rangana Sudesha Withanage, C<< <rwi at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lingua-plantuml-encode at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-PlantUML-Encode>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lingua::PlantUML::Encode


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-PlantUML-Encode>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Lingua-PlantUML-Encode>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Lingua-PlantUML-Encode>

=item * Search CPAN

L<https://metacpan.org/release/Lingua-PlantUML-Encode>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Rangana Sudesha Withanage.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

1; # End of Lingua::PlantUML::Encode
