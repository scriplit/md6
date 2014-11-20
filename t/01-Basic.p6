use v6;
use Test;

use Markdown;

{
	# Paragraph
	my $text = "Hello!";
	ok md_to_html($text) ~~ m/'<p>Hello!</p>'/, "Simple paragraph";

}

{
	# Title (1)
	my $text = "Title\n-----";
	my $out = md_to_html($text);
	say $out;
	ok $out ~~ m/'<h1>Title</h1>'/, "Title (1)";
}


done;
