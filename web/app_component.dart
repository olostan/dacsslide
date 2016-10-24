// Copyright (c) 2016, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:dacsslide/presentation_component.dart';
import 'package:dacsslide/sample_directive.dart';


@Component(
    selector: 'my-app',
    styleUrls: const ['app_component.css'],
    templateUrl: 'app_component.html',
    encapsulation: ViewEncapsulation.None,
    directives: const [PresentationComponent, SymbolComponent,SampleDirective],
    providers: const [SampleService])
class AppComponent {
}
