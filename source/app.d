import std.file;
import std.stdio;
import std.string;
import core.stdc.stdlib;
import html;

const appName    = "ywebmaker";
const appVersion = "v0.1.0";
const appAuthor  = "yeti0904";

void main(string[] args) {
	string outFile = "out.html";
	string inFile  = "";

	for (size_t i = 1; i < args.length; ++i) {
		auto arg = args[i];

		if (arg[0] == '-') {
			switch (arg) {
				case "-o":
				case "--out": {
					if (i == args.length - 1) {
						stderr.writeln("Given -o but not given file path");
						exit(1);
					}
					++ i;
					
					outFile = arg;
					break;
				}
				default: {
					stderr.writefln("Unrecognised parameter %s", arg);
					exit(1);
				}
			}
		}
		else {
			if (!inFile.empty()) {
				stderr.writeln("Error: given multiple input files");
				exit(1);
			}
			inFile = arg;
		}
	}

	if (inFile.empty()) {
		stderr.writeln("You need to pass an input filename");
		exit(1);
	}

	string ywmCode;
	try {
		ywmCode = readText(inFile);
	}
	catch (Throwable e) {
		stderr.writefln("Error opening file %s: %s", inFile, e.msg);
		exit(1);
	}

	std.file.write(outFile, CompileToHTML(inFile, ywmCode.splitLines()));
}
