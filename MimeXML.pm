package Apache::MimeXML;

use strict;
use vars qw($VERSION);
use Apache::Constants qw(:common);

$Apache::MimeXML::VERSION = '0.01';

my $feff = chr(0xFE) . chr(0xFF);

sub handler {
	my $r = shift;
	
	my $type = $r->dir_config('XMLMimeType') || 'application/xml';
	
	open(FH, $r->filename) or return DECLINED;
	binmode FH;
	my $firstline;
	sysread(FH, $firstline, 200); # Read 200 chars. This is a guestimate...
	
	if (substr($firstline, 0, 2) eq $feff) {
		# Probably utf-16
		if ($firstline =~ m/^$feff\x00<\x00\?\x00x\x00m\x00l/) {
			$r->content_type("$type; charset=utf-16");
			return OK;
		}
	}
	else {
		if ($firstline =~ m/^<\?xml(.*?)\?>/) {
			my $attribs = $1;
			if ($attribs =~ m/encoding\s*?=\s*?["'](.*?)["']/) {
				$r->content_type("$type; charset=$1");
			}
			else {
				# Assume utf-8
				$r->content_type("$type; charset=utf-8");
			}
			return OK;
		}
		return DECLINED;
	}
	return DECLINED;
}

1;
__END__

=head1 NAME

Apache::MimeXML - mod_perl mime encoding sniffer for XML files

=head1 SYNOPSIS

  PerlTypeHandler Apache::MimeXML

=head1 DESCRIPTION

An XML Content-Type sniffer. This module reads the encoding
attribute in the xml declaration and returns an appropriate
content-type heading. If no encoding declaration is found it
returns utf-8 or utf-16 depending on the specific encoding.

=head1 AUTHOR

Matt Sergeant matt@sergeant.org

=head1 LICENCE

This module is distributed under the same terms as perl itself

=cut
