module main

import os
import internals


fn main() {
	mut args := os.args[1..]

	dir_entries := os.ls(".")?
	if !("pubspec.yaml" in dir_entries) {
		panic("Seems like that's not a flutter/dart project!")
	}

	package_name := os.read_lines("./pubspec.yaml")?[0].replace("name: ", "")

	tokens := internals.tokenize_dir("./lib/pages")
	internals.build_router(tokens, package_name)?
	os.execute("dart format ./lib/router.dart")

	if !("flunk" in args) { // also exec flutter
		if args.len == 0 { // add default arg run
			args << "run"
		}
		os.execvp("flutter", args)?
	}
}