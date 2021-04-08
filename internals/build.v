module internals

import os
import pcre

struct Route {
mut:
	path string [required]
	handler_recv string [required]
	string_param string
	class_param string
}

fn generate_router_define_str(route Route) []string {
	mut handler := ""
	if route.string_param != "" {
		handler = 'return ${route.handler_recv}(params["${route.string_param}"]![0]);'
	} else if route.class_param != "" {
		handler = "return ${route.handler_recv}(context.settings.arguments as ${route.class_param});"
	} else {
		handler = "return ${route.handler_recv}();"
	}
	return [
		"router.define(",
		'"${route.path}",',
		"handler: Handler(",
		"handlerFunc: (context, params) {",
		"$handler",
		"}",
		")",
		");"
	]
}

pub fn build_router(tokens [][]string, package_name string, dirs_to_ignore []string) ? {

	package_template := "import 'package:$package_name/pages/"
	mut router_template := [
		"import 'package:fluro/fluro.dart';",
	]

	// generate imports
	dependency_root: for token_list in tokens {
		mut path := package_template
		for token in token_list {
			if token.contains(".dart") {
				path = "$path$token"
				router_template << "$path';"
			} else if token in dirs_to_ignore {
				continue dependency_root
			} else {
				path = "$path$token/"
			}
		}
	}

	router_template << "// generated by flunky"
	router_template << "class ${package_name.capitalize()}Router {"
	router_template << "static final ${package_name.capitalize()}Router _instance = ${package_name.capitalize()}Router._internal();"
	router_template << "factory ${package_name.capitalize()}Router.init() => _instance;"
	router_template << "static final router = FluroRouter();"
	router_template << "${package_name.capitalize()}Router._internal() {"
	
	mut classname_re := pcre.new_regex(r"class (.*) extends .*Widget", 0)?
	mut args_classname_re := pcre.new_regex(r"class (.*Args)", 0)?

	// generate handlers
	handler_root: for token_list in tokens {
		mut route := Route{ path: "", handler_recv: "" }
		for token in token_list {
			if token.contains(".dart") {
				// receiver
				route_file := os.read_file("./lib/pages${route.path}/$token")?
				name := classname_re.match_str(route_file, 0, 0) or {
					panic("No widget found in $token!")
				}
				route.handler_recv = name.get(1)?

				// params
				sanitized_token := token.replace(".dart", "")
				if sanitized_token.starts_with("_") {
					route.string_param = sanitized_token.replace("_", "")
					route.path += "/:${route.string_param}"
				} else {
					if args_classname_m := args_classname_re.match_str(route_file, 0, 0) {
						args_classname := args_classname_m.get(1)?
						route.class_param = args_classname
					}
					route.path += "/$sanitized_token"
				}
			} else if token in dirs_to_ignore {
				continue handler_root
			} else {
				route.path += "/$token"
			}
		}
		router_template << generate_router_define_str(route)
	}

	router_template << "}"
	router_template << "}"

	os.write_file("./lib/router.dart", router_template.join("\n")) or {
		panic(err)
	}
}