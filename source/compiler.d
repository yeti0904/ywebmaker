import std.format;
import std.string;

string CompileToHTML(string[] lines) {
	string headCode;
	string bodyCode;

	bool inBold;
	bool inItalic;
	bool inUnderline;

	foreach (ref line ; lines) {
		foreach (i, ref ch ; line) {
			switch (ch) {
				case '*': { // bold
					if ((i != 0) && (line[i - 1] == '\\')) {
						bodyCode ~= '*';
						break;
					}

					inBold = !inBold;
					bodyCode ~= inBold? "<b>" : "</b>";
					break;
				}
				case '%': { // italic
					if ((i != 0) && (line[i - 1] == '\\')) {
						bodyCode ~= '%';
						break;
					}

					inItalic = !inItalic;
					bodyCode ~= inItalic? "<i>" : "</i>";
					break;
				}
				case '_': { // underline
					if ((i != 0) && (line[i - 1] == '\\')) {
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

		bodyCode ~= "<br>";
	}

	string html = format(`
<!DOCTYPE html>
<html><head><pre>%s</pre></head><body><pre>%s</pre></body></html>`,
	headCode, bodyCode);

	return html;
}
