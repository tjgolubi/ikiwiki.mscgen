#!/usr/bin/perl
# mscgen plugin for ikiwiki: render mscgen source as an image.
# Terry Golubiewski
# Derived from graphviz plugin by Josh Triplett.
package IkiWiki::Plugin::mscgen;

use warnings;
use strict;
use IkiWiki 3.00;
use IPC::Open2;

sub import {
	hook(type => "getsetup", id => "mscgen", call => \&getsetup);
	hook(type => "preprocess", id => "msc", call => \&graph);
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => undef,
			section => "widget",
		},
}

sub render_graph (\%) {
	my %params = %{(shift)};

	my $src = "msc {\n";
	$src .= $params{src};
	$src .= "\n}\n";

	# Use the sha1 of the mscgen code as part of its filename.
	eval q{use Digest::SHA};
	error($@) if $@;
	my $dest=$params{page}."/msc-".
		IkiWiki::possibly_foolish_untaint(Digest::SHA::sha1_hex($src)).
		".png";
	will_render($params{page}, $dest);

	if (! -e "$config{destdir}/$dest") {
		my $pid;
		my $sigpipe=0;
		$SIG{PIPE}=sub { $sigpipe=1 };
		$pid=open2(*IN, *OUT, 'mscgen', '-Tpng', '-i-', '-o-');

		# open2 doesn't respect "use open ':utf8'"
		binmode (OUT, ':utf8');

		print OUT $src;
		close OUT;

		my $png;
		{
			local $/ = undef;
			$png = <IN>;
		}
		close IN;

		waitpid $pid, 0;
		$SIG{PIPE}="DEFAULT";
		error gettext("failed to run mscgen") if $sigpipe;

		if (! $params{preview}) {
			writefile($dest, $config{destdir}, $png, 1);
		}
		else {
			# in preview mode, embed the image in a data uri
			# to avoid temp file clutter
			eval q{use MIME::Base64};
			error($@) if $@;
			return "<img src=\"data:image/png;base64,".
				encode_base64($png)."\" />";
		}
	}

	return "<img src=\"".urlto($dest, $params{destpage})."\" />\n";
}

sub graph (@) {
	my %params=@_;
	$params{src} = "" unless defined $params{src};
	return render_graph(%params);
}

1
