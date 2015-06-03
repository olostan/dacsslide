// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library transformer_test;

import 'package:test/test.dart';

import 'package:dacsslide/src/scss_transformer.dart';

testTransform(String src,String dst) {
  expect(transformCSSLide(src),equals(dst));
}
testEqualTransform(String src1,String src2) {
  var r1 = transformCSSLide(src1);
  var r2 = transformCSSLide(src2);
  expect(r1,equals(r2));
}

moveTests() {
  testTransform('''
#test: move(5,5);
.s1 { #test: move(+10,20);}
.s2 { #test: move(10,+25);}
.s3 { #test: up(20);}
.s4 { #test: down(50);}
.s5 { #test: left(200);}
.s6 { #test: right(22);}
''','''
#test{ transform:translateX(5px) translateY(5px);}
.s1 { #test{ transform:translateX(10px) translateY(20px);}}
.s2 { #test{ transform:translateX(10px) translateY(25px);}}
.s3 { #test{ transform:translateX(10px) translateY(5px);}}
.s4 { #test{ transform:translateX(10px) translateY(55px);}}
.s5 { #test{ transform:translateX(-190px) translateY(55px);}}
.s6 { #test{ transform:translateX(-168px) translateY(55px);}}
''');  
}

combTests() {
  testTransform('''
#test: move(5,5);
.s1 { #test: move(+10,20) show;}
.s2 { #test: hide; #another:show;}
.s3 { #test: show rotate(20);}
.s4 { #test: opacity(0.2) rotate(20);}
''','''
#test{ transform:translateX(5px) translateY(5px);}
.s1 { #test{ opacity:1;transform:translateX(10px) translateY(20px);}}
.s2 { #test{ opacity:0;} #another{ opacity:1;}}
.s3 { #test{ opacity:1;transform:translateX(10px) translateY(20px) rotateX(20deg);}}
.s4 { #test{ opacity:0.2;transform:translateX(10px) translateY(20px) rotateX(40deg);}}
''');
}

delayTests() {
  testTransform('''
#test: delay(1);
.s1 { #test: delay(0); }
.s2 { #test: delay(1.4) show; }
.s3 { #test: delay(+1.3); }
''','''
#test{ transition-delay: 1s;}
.s1 { #test{ transition-delay: 0s;} }
.s2 { #test{ opacity:1;transition-delay: 1.4s;} }
.s3 { #test{ transition-delay: 1.3s;} }
''');
}

inlineTests() {
  testTransform('''
#test { color:blue; ::move(20,20); }
.s1 { #test {
  color: green;
  ::left(50) show;
  }
}
.s2 { #test {
  color: blue;
  ::down(50) show;
  width:200;
  }
}
''','''
#test { color:blue; transform:translateX(20px) translateY(20px); }
.s1 { #test {
  color: green;
  opacity:1;transform:translateX(-30px) translateY(20px);
  }
}
.s2 { #test {
  color: blue;
  transform:translateX(-30px) translateY(70px);
  width:200;
  }
}
''');
}

inlineOrderTests() {
  testTransform('''
#nice: hide;
#test: move(20,20); }
.s1 { #test {
  color: green;
  ::left(50) show;
  }
}
.s2 { #test: down(50) hide; }
}
''','''
#nice{ opacity:0;}
#test{ transform:translateX(20px) translateY(20px);} }
.s1 { #test {
  color: green;
  opacity:1;transform:translateX(-30px) translateY(20px);
  }
}
.s2 { #test{ opacity:0;transform:translateX(-30px) translateY(70px);} }
}
''');
}


main() {
  test('Move tests', moveTests);
  test('Combination tests', combTests);
  test('Delay tests', delayTests);
  test('Inline tests', inlineTests);
  test('Inline order tests', inlineOrderTests);

}

