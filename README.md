<img src="assets/flunky_logo.svg" alt="drawing" width="120"/>

# flunky
A simple flutter wrapper that generates a [fluro](https://pub.dev/packages/fluro) router spec file from pages directory entries.

## Project structure
In order to correctly parse your project flunky needs a specific project structure.
Projects should be arranged like this:

- lib  
  - other code
  - pages
    - page.dart
    - subdir
      - _paramOne.dart
      - subpage.dart

From this structure flunky generates the following spec file as lib/router.dart:

```dart
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:project_name/pages/page.dart';
import 'package:project_name/pages/subdir/_paramOne.dart';
import 'package:project_name/pages/subdir/subpage.dart';

class ProjectNameRouter {
    static final ProjectNameRouter _instance = ProjectNameRouter._internal();
    factory ProjectNameRouter() => _instance;
    static final router = FluroRouter();

    ProjectNameRouter._internal() {
        router.define(
            "/page",
            handler: Handler(
                handlerFunc: (context, params) {
                    // assuming the Widget in /page.dart is called Page
                    return Page();
                }
            )
        );
        router.define(
            "/subdir/:paramOne",
            handler: Handler(
                handlerFunc: (context, params) {
                    // assuming the Widget in /subDir/paramOne.dart is called ParamOneWidget
                    return ParamOneWidget(params["paramOne"][0]);
                }
            )
        );
        router.define(
            "/subdir/subPage",
            handler: Handler(
                handlerFunc: (context, params) {
                    // assuming the Widget in /subdir/subPage.dart is called SubPageWidget
                    // and SubPageArgs class exists
                    return SubPageWidget(context.settings.arguments as SubPageArgs);
                }
            )
        );
    }
}
```

## Usage

### router spec only
Exec `flunky flunk` in project root.

### router spec and flutter run
Exec `flunky` in project root.

## Configurations
Handy launch configurations are given for VSCode and Android Studio in their respective config directories (`.vscode` / `.run`).

## Options
```
help | h              : displays this help message
version | v           : displays Flunky version
flunk                 : only generate router file and don't execute flutter run afterwards
{subdir1 subdir2 ...} : add subdirectories that should be ignored by the generator; per default 'widgets' and 'components' subdirs are ignored
```
