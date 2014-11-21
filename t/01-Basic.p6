use v6;
use Test;

use Markdown;

{
	# Paragraph
	my $text = "Hello!";
	my $out = md_to_html($text);
	is $out, "<p>Hello!</p>\n", "Simple paragraph";

}

{
	# Title (1)
	my $text = "Title\n=====";
	my $out = md_to_html($text);
	is $out, "<h1>Title</h1>\n", "Title (1)";
}

{
	# Title (2)
	my $text = "Title2\n----";
	my $out = md_to_html($text);
	is $out, "<h2>Title2</h2>\n", "Title (2)";
}

{
	# Title (3)
	my $text = "### Title3";
	my $out = md_to_html($text);
	is $out, "<h3>Title3</h3>\n", "Title (3)";
}

{
	# hash in the middle
	my $txt = "Text with # in the middle";
	my $out = md_to_html($txt);
	is $out, "<p>" ~ $txt ~ "</p>\n", "Hash in the middle";
}

{
	# Ampersand replacement
	my $txt = "AT&T";
	my $out = md_to_html($txt);
	is $out, "<p>AT&amp;T</p>\n", "Ampersand replacement";
}

{
	# Clean ampersand
	my $txt = "AT&amp;T";
	my $out = md_to_html($txt);
	is $out, "<p>AT&amp;T</p>\n", "Clean ampersand";
}

{	# Embedded HTML
	my $txt = "Title\n---\n\n";
	my $html = "<table><tr><td></td></tr></table>\n";
	my $out = md_to_html($txt ~ $html);
	is $out, "<h2>Title</h2>\n\n" ~ $html, "Embedded HTML";
}

{
	# No ampersand replacement in embedded HTML
	my $txt = "Title\n---\n\n";
	my $html = "<table><tr><td>AT\&T</td></tr></table>\n";
	my $out = md_to_html($txt ~ $html);
	is $out, "<h2>Title</h2>\n\n" ~ $html, "No & mod in embedded HTML";
}

{
	# Bold
	my $txt = "less and **more**";
	my $html = "<p>less and <strong>more</strong></p>\n";
	my $out = md_to_html($txt);
	is $out, $html, "Strong tag";
}

{
	# Italic
	my $txt = "this and *that*";
	my $html = "<p>this and <em>that</em></p>\n";
	my $out = md_to_html($txt);
	is $out, $html, "Em tag";
}

{
	# Code
	my $txt = "this and `42`";
	my $html = "<p>this and <code>42</code></p>\n";
	my $out = md_to_html($txt);
	is $out, $html, "Code tag";
}

{
	# table in a table
	my $txt = "Title\n---\n\n";
	my $html = "<table><tr><td><table></table></td></tr></table>\n";
	my $out = md_to_html($txt ~ $html);
	is $out, "<h2>Title</h2>\n" ~ "\n" ~ $html,
	   "Embedded HTML: table in a table";
}

{
	# less than
	my $txt = "1 < 2";
	my $html = "<p>1 &lt; 2</p>\n";
	my $out = md_to_html($txt);
	is $out, "$html", "Less than";
}

{
	# Original 1a
	my $txt = q:to"END";
		AT&T has an ampersand in their name.
		
		AT&amp;T is another way to write it.
		
		This & that.
		
		4 < 5.
		
		6 > 5.
		END

	my $html = q:to"END";
		<p>AT&amp;T has an ampersand in their name.</p>
		
		<p>AT&amp;T is another way to write it.</p>
		
		<p>This &amp; that.</p>
		
		<p>4 &lt; 5.</p>
		
		<p>6 > 5.</p>
		END

	my $out = md_to_html($txt);
	is $out, $html, "Original 1a!";
}



done;
