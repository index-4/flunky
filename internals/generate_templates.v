module internals

import os

pub fn generate_template(template_name string) {
	match template_name {
		"help" { generate_help() }
		"notFound" { generate_not_found() or { panic("Failed to generate notFound Handler; $err") } }
		else {
			println("Requested template not found :(")
		}
	}
}

fn generate_help() {
	println("Currently available templates:")
	println("  help - prints that message")
	println("  notFound - generates a more sophisticated notFound handler in /lib")
}

fn generate_not_found() ? {
	not_found_template := "import 'package:fluro/fluro.dart';import 'package:flutter/material.dart';class TestHandler extends Handler { @override get handlerFunc => (context, params) {return Scaffold(body: Center(child: Text(\"Route not found!\"),),);};}"
	os.write_file("./lib/notFound.dart", not_found_template)?
	os.execute("dart format ./lib/notFound.dart")
}