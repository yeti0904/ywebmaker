import std.conv;
import std.stdio;
import std.format;
import std.string;
import std.algorithm;
import error;

const coreCSS = `
h1, h2, h3, h4, h5, h6 {
	margin: 10px 0 10px 0;
}
`;

const codeBlockCSS = `
code {
    display: block;
    border-radius: 5px;
    background-color: darkslategray;
    color: lightgray;
    font-family: monospace;
    width: 100%;
    max-width: max-content;
    padding: 5px 10px 5px 10px;
}
`;

string CompileToHTML(string fname, string[] lines) {
	string headCode;
	string bodyCode;

	bool inBold = false;
	bool inItalic = false;
	bool inUnderline = false;

	bool inHeader = false;
	int  headerLvl;

	bool usesCodeBlock = false;

	foreach (i, ref line ; lines) {
		if (line.startsWith(".begin ")) {
			string statement = line[".begin ".length .. $];
		
			switch (statement) {
				case "code": {
					usesCodeBlock = true;
					bodyCode ~= "<pre><code>";
					break;
				}
				default: {
					ErrorUnknownStatement(fname, i, 0, line, statement);
				}
			}
			continue;
		}
		else if (line.startsWith(".end ")) {
			string statement = line[".end ".length .. $];
		
			switch (statement) {
				case "code": {
					bodyCode ~= "</code></pre>";
					break;
				}
				default: {
					ErrorUnknownStatement(fname, i, 0, line, statement);
				}
			}
			continue;
		}
		else if (line.startsWith(".split")) {
			bodyCode ~= "<hr>";
			continue;
		}
		else if (line.startsWith(".image ")) {
			bodyCode ~= "<img src='" ~ line[".image ".length .. $] ~ "'>";
			continue;
		}
		else if (line.startsWith(".link")) {
			auto parts = line.split(' ');

			if (parts.length != 3) {
				ErrorNotEnoughArguments(fname, i, 0, line, 2);
			}

			bodyCode ~= "<a href='" ~ parts[1] ~ "'>" ~ parts[2] ~ "</a>";
			continue;
		}
	
		for (size_t j = 0; j < line.length; ++j) {
			auto ch = line[j];
			switch (ch) {
				case '#': {
					if (j != 0) {
						bodyCode ~= ch;
						break;
					}

					inHeader  = true;
					headerLvl = 1;
					if ((line.length != 1) && (line[j + 1] != ' ')) {
						++ j;
						if (!isNumeric([line[j]])) {
							ExpectedDigitError(
								fname, i, j, line, line[j]
							);
						}

						string str = [line[j]];

						headerLvl = parse!int(str);
					}
					bodyCode ~= "<h" ~ text(headerLvl) ~ ">";
					break;
				}
				case '*': { // bold
					if ((j != 0) && (line[j - 1] == '\\')) {
						bodyCode ~= '*';
						break;
					}

					inBold = !inBold;
					bodyCode ~= inBold? "<b>" : "</b>";
					break;
				}
				case '%': { // italic
					if ((j != 0) && (line[j - 1] == '\\')) {
						bodyCode ~= '%';
						break;
					}

					inItalic = !inItalic;
					bodyCode ~= inItalic? "<i>" : "</i>";
					break;
				}
				case '_': { // underline
					if ((j != 0) && (line[j - 1] == '\\')) {
						bodyCode ~= '_';
						break;
					}

					inUnderline = !inUnderline;
					bodyCode ~= inUnderline? "<i>" : "</i>";
					break;
				}
				default: {
					bodyCode ~= ch;
					break;
				}
			}
		}

		if (inHeader) {
			bodyCode ~= "</h" ~ text(headerLvl) ~ ">";
			inHeader  = false;
		}
		else {
			//writefln("%d: %c", i, lines[i - 1][lines[i - 1].length - 1]);
			if ((line.length == 0) || (line[line.length - 1] != '\\')) {
				bodyCode ~= "<br>";
			}
			else {
				bodyCode = bodyCode[0 .. $ - 1]; // remove backslash
			}
		}
	}

	string html = format(`
<!DOCTYPE html>
<html><head><style>%s%s</style>%s</head><body>%s</body></html>`,
	coreCSS, usesCodeBlock? codeBlockCSS : "", headCode, bodyCode);

	return html;
}
