// Copyright (c) 2016, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

//import 'package:angular/platform/browser.dart';

//import 'app_component.dart';
import 'package:http/browser_client.dart';
import 'package:angular/angular.dart';
import 'package:http/http.dart';
import 'app_component.template.dart' as ng;
import 'main.template.dart' as self;

@GenerateInjector([
  const ClassProvider(Client, useClass: BrowserClient),
])
final InjectorFactory injector = self.injector$Injector;

main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
  /*bootstrap(AppComponent, const [
   const Provider(BrowserClient,
        useFactory: HttpClientBackendServiceFactory, deps: const [])
  ]);*/
}

