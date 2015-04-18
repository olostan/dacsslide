// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library transformer_test;

import 'package:unittest/unittest.dart';

import 'package:dacsslide/src/scss_transformer.dart';

testTransform(String src,String dst) {
  expect(transformCSSLide(src),equals(dst));
}

moveTests() {
  testTransform('''
#test: move(5,5);
.s1 { #test: move(+10,20);}
.s2 { #test: move(10,+20);}
.s3 { #test: up(20);}
.s4 { #test: down(50);}
.s5 { #test: left(200);}
.s6 { #test: right(22);}
''','''
#test{ transform:translateX(5px) translateY(5px);}
.s1 { #test{ transform:translateX(15px) translateY(20px);}}
.s2 { #test{ transform:translateX(10px) translateY(40px);}}
.s3 { #test{ transform:translateX(10px) translateY(20px);}}
.s4 { #test{ transform:translateX(10px) translateY(70px);}}
.s5 { #test{ transform:translateX(-190px) translateY(70px);}}
.s6 { #test{ transform:translateX(-168px) translateY(70px);}}
''');  
}

combTests() {
  testTransform('''
#test: move(5,5);
.s1 { #test: move(+10,20) show;}
.s2 { #test: hide; #another:show;}
.s3 { #test: show rotate(20);}
''','''
#test{ transform:translateX(5px) translateY(5px);}
.s1 { #test{ opacity:1;transform:translateX(15px) translateY(20px);}}
.s2 { #test{ opacity:0;} #another{ opacity:1;}}
.s3 { #test{ opacity:1;transform:translateX(15px) translateY(20px) rotateX(20deg);}}
''');  
}

main() {
  test('Move tests', moveTests);
  test('Combination tests', combTests);

}

