// Copyright (c) 2015-2018, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';
import 'package:dacsslide/pcss_builder.dart';

import 'dart:async';

Builder pcssBuilder(BuilderOptions options) =>
    new PCSSBuilder();

class PCSSBuilder extends Builder {

  Map<String, List<String>> get buildExtensions {
    return const {
      '.pcss': const ['.scss'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    var content = await buildStep.readAsString(buildStep.inputId);
    var result = transformCSSLide(content);
    var asset = buildStep.inputId.changeExtension(".scss");
    return buildStep.writeAsString(asset, result);
  }
}

PostProcessBuilder pcssSourceCleanup(BuilderOptions options) =>
    new FileDeletingBuilder(['.pcss'],
        isEnabled: (options.config['enabled'] as bool) ?? false);
