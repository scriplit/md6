module Markdown;

grammar MarkDown {
	token TOP { ^ <paragraph>* % [\n\n+] \n* $ }
	token paragraph { <header> | <html> | <mdblock> }
	token header { <h_setext> | <h_dashed> }
	token h_setext { <text> \n <underline>  }
	token underline { ('-' || '=')+ }
	token h_dashed { <dashes> \s+ <text>  }
	token dashes { ('#'+!) }
	token mdblock { <spanseq>* }
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
	token char { <amp_dirty> | <safechars> }
	token amp_dirty { '&' <!before \w+\;> }
	token safechars { <-[*`\n]> }
}

class HTMLMaker {
	method safechars($/) {
		make ~$/;
	}
	method amp_dirty($/) {
		make '&amp;';
	}
	method char($/) {
		make $/.values[0].ast;
	}
	method text($/) {
		make $/.values.[0].>>.ast.join;
	}
	method monospace($/) {
		make '<code>' ~ $<text> ~ '</code>';
	}
	method bold($/) {
		make '<strong>' ~ $<text> ~ '</strong>';
	}
	method italic($/) {
		make '<em>' ~ $<text> ~ '</em>';
	}
	method spanseq($/) {
		make $/.values.[0].ast;
	}
	method html($/) {
		make ~$/ ~ "\n";
	}
	method mdblock($/) {
		make '<p>' ~ $<spanseq>>>.ast ~ "</p>\n";
	}
	method h_setext($/) {
		if (~$<underline>).ord == '='.ord {
			make '<h1>' ~ $<text> ~ "</h1>\n";
		}
		else {
			make '<h2>' ~ $<text> ~ "</h2>\n";
		}
	}
	method h_dashed($/) {
		my $h = 'h' ~ $<dashes>.chars;
		make "<$h>" ~ $<text> ~ "</$h>\n";
	}
	method header($/) {
		make $/.values.[0].ast;
	}
	method paragraph($/) {
		make $/.values.[0].ast ~ "\n";
	}
	method TOP($/) {
		make $<paragraph>>>.ast.join;
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