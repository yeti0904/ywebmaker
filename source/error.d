import std.stdio;
import core.stdc.stdlib;

void ErrorBegin(string fname, size_t line, size_t col) {
	version (Windows) {
		stderr.writef("%s:%d:%d: error: ", fname, line + 1, col + 1);
	}
	else {
		stderr.writef("\x1b[1m%s:%d:%d: \x1b[31merror:\x1b[0m ", fname, line + 1, col + 1);
	}
}

void ErrorEnd(size_t lineNum, string lineContents) {
	stderr.writefln("  %d | %s", lineNum, lineContents);
	exit(1);
}

void ExpectedDigitError(string fname, size_t line, size_t col, string lineS, char ch) {
	ErrorBegin(fname, line, col);
	stderr.writefln("Expected digit, got '%c'", ch);
	ErrorEnd(line, lineS);
}

void ErrorUnknownStatement(string fname, size_t line, size_t col, string lineS, string st) {
	ErrorBegin(fname, line, col);
	stderr.writefln("Unknown statement: '%s'", st);
	ErrorEnd(line, lineS);
}

void ErrorNotEnoughArguments(string fname, size_t line, size_t col, string lineS, size_t req) {
	ErrorBegin(fname, line, col);
	stderr.writefln("Not enough arguments, required %d", req);
	ErrorEnd(line, lineS);
}
