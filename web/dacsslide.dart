library dacsslide.demo;

import 'package:angular/angular.dart';
import 'package:dacsslide/presentation.dart';

@MirrorsUsed(targets: const ['presentation'], override: '*')
import 'dart:mirrors';

main() => ngBootstrap(module:new PresentationModule());
