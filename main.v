import os

fn main() {
	dir_names := os.ls(".")?
	if !("pubspec.yaml" in dir_names) {
		panic("Seems like that's not a flutter/dart project!")
	}

	pages := os.ls("./lib/pages") or {
		panic("No pages dir found!")
	}

	for p in pages {
		println(p)
	}
}