# Description #

This [ikiwiki](http://ikiwiki.info) plugin provides the "msc" ikiwiki directive.
This directive allows embedding [mscgen](http://www.mcternan.me.uk/mscgen/)
message sequence chart graphs in an ikiwiki page.

Here's an example of displaying an mscgen graph in ikiwiki.

    \[[!msc src="""
      arcgradient = 8;

      a [label="Client"],b [label="Server"];

      a=>b [label="data1"];
      a-xb [label="data2"];
      a=>b [label="data3"];
      a<=b [label="ack1, nack2"];
      a=>b [label="data2", arcskip="1"];
      |||;
      a<=b [label="ack3"];
      |||;
    """]]

This plugin uses the cpan Digest::SHA perl module.

This plugin borrows heavily from the graphviz ikiwiki plugin written by
Josh Triplett.

# Installation #

Install to a valid ikiwiki plugin place, e.g. "~/.ikiwiki/IkiWiki/Plugin/".
