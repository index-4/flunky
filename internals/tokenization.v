module internals

import os

pub fn tokenize_dir(dir string) [][]string {
	mut tokens := [][]string{}
	mut dir_entries := os.walk_ext(dir, ".dart")

	// sanitize!
	for entry in dir_entries {
		tokens << entry.replace("./lib/pages", "").split("/").filter(it != "")
	}

	return tokens
}