module main

import os
import nedpals.vargs
import internals

fn print_help() {
	println("It's gettin a little flunky in here!")
	println("Welcome to Flunky a smol Flutter wrapper that adds automatic fluro router generation as the new cool kid of the block.\n")
	println("Cause it basically is a wrapper FLunky supports all flutter commands that you are used to. The only Flunky specific commands are:")
	println("  help | h              : displays this help message")
	println("  version | v           : displays Flunky version")
	println("  flunk                 : only generate router file and don't execute flutter run afterwards")
	println("  {subdir1 subdir2 ...} : add subdirectories that should be ignored by the generator; per default 'widgets' and 'components' subdirs are ignored")
	exit(0)
}

fn main() {
	mut args := vargs.new(os.args, 1)
	args.parse()

	match args.command {
		"help", "h" { print_help() }
		"version", "v" { println("v1.1.2") exit(0) }
		else {
			// subdirs interpreted as command
			args.unknown << args.command
			args.command = ""
		}
	}

	// add flutter run
	if args.command == "" {
		args.command = "run"
	}

	// add default ignore subdirs
	args.unknown << ["widgets", "components"]

	dir_entries := os.ls(".")?
	if !("pubspec.yaml" in dir_entries) {
		panic("Seems like that's not a flutter/dart project!")
	}

	package_name := os.read_lines("./pubspec.yaml")?[0].replace("name: ", "")

	tokens := internals.tokenize_dir("./lib/pages")
	internals.build_router(tokens, package_name, args.unknown)?
	os.execute("dart format ./lib/router.dart")

	if args.command != "flunk" && !("flunk" in args.unknown) { // also exec flutter
		os.execvp("flutter", args.join_valid())?
	}
}