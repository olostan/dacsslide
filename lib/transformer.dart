// Copyright (c) 2015, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


import 'package:barback/barback.dart';
import 'package:dacsslide/scss_transformer.dart';

import 'dart:async';

class CSSLib_Tranform extends Transformer {
  String copyright = "Copyright (c) 2016, Valentyn Shybanov (olostan).\n";

  CSSLib_Tranform.asPlugin();

  Future<bool> isPrimary(AssetId id) async => id.extension == '.scss';

  Future apply(Transform transform) async {
    //transform.logger.info("Starting processing");
    var content = await transform.primaryInput.readAsString();
    //var id = transform.primaryInput.id.changeExtension('.css');
    var id = transform.primaryInput.id;
    var result = transformCSSLide(content);
    transform.addOutput(new Asset.fromString(id,result));
  }
}