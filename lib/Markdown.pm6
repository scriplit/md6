module Markdown;
#use Grammar::Tracer;

grammar MarkDown {
	token TOP { ^ <paragraph>* % [\n\n+] \n* $ }
	token paragraph { <header> | <html> | <mdblock> }
	token header { <h_setext> | <h_dashed> }
	token h_setext { <text> \n <underline>  }
	token underline { ('-' || '=')+ }
	token h_dashed { <dashes> \s+ <text>  }
	token dashes { ('#'+!) }
	token mdblock { <mdline>* % [\n <!before \n>] }
	token mdline { <spanseq>+ }
	token html { '<' 
                     (
		     || 'div'
	             || 'table'
		     || 'pre'
		     || 'p'
	             )
		     .+! '</' $0 '>' }
	token spanseq { <bold> | <italic> | <monospace> | <text> }
	token bold { '**' ~ '**' <text> }
	token italic { '*' ~ '*' <text> }
	token monospace { '`' ~ '`' <text> }
	token text { <char>+ }
	token char { <amp_dirty> | <lt_dirty> | <safechars> }
	token amp_dirty { '&' <!before \w+\;> }
	token lt_dirty  { '<' <!before \/? \w+ <-[>]>* '>' > }
	token safechars {
	                | <-[*`\n\#]>
			# | \n <before <-[\-\=]>>
			| '#' <!after ^>
		        }
}

class HTMLMaker {
	method safechars($/) {
		make ~$/;
	}
	method amp_dirty($/) {
		make '&amp;';
	}
	method lt_dirty($/) {
		make '&lt;';
	}
	method char($/) {
		make $/.values[0].ast;
	}
	method text($/) {
		make $/.values.[0].>>.ast.join;
	}
	method monospace($/) {
		make '<code>' ~ $<text>.ast ~ '</code>';
	}
	method bold($/) {
		make '<strong>' ~ $<text>.ast ~ '</strong>';
	}
	method italic($/) {
		make '<em>' ~ $<text>.ast ~ '</em>';
	}
	method spanseq($/) {
		make $/.values.[0].ast;
	}
	method html($/) {
		make ~$/ ~ "\n";
	}
	method mdline($/) {
		make $<spanseq>>>.ast.join;
	}
	method mdblock($/) {
		make '<p>' ~ $<mdline>>>.ast.join(" ")  ~ "</p>\n";
	}
	method h_setext($/) {
		if (~$<underline>).ord == '='.ord {
			make '<h1>' ~ $<text>.ast ~ "</h1>\n";
		}
		else {
			make '<h2>' ~ $<text>.ast ~ "</h2>\n";
		}
	}
	method h_dashed($/) {
		my $h = 'h' ~ $<dashes>.chars;
		make "<$h>" ~ $<text>.ast ~ "</$h>\n";
	}
	method header($/) {
		make $/.values.[0].ast;
	}
	method paragraph($/) {
		make $/.values.[0].ast;
	}
	method TOP($/) {
		make $<paragraph>>>.ast.join("\n");
	}
}

sub md_to_html (Cool $text) is export {
	my $m = HTMLMaker.new();
	my $p = MarkDown.parse($text, :actions($m));
	return $p.ast;
}

sub mdfile_to_htmlfile (Cool $pathmd, Cool $pathhtml) is export {
	my Str $text = slurp($pathmd);
	my $out = md_to_html($text);
	spurt $pathhtml, $out;
}
