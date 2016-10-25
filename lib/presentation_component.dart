// Copyright (c) 2016, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import "package:angular2/src/platform/browser_common.dart" show document;
import "package:angular2/src/platform/dom/events/event_manager.dart" show EventManager;
import "dart:html" show KeyboardEvent,window,HashChangeEvent,document;



@Component(
    selector: 'symbol',
    template:'<div [id]="name"><ng-content></ng-content></div>'
)
class SymbolComponent {
  @Input('name') String name;
}

@Component(
    selector: 'presentation',
    styleUrls: const ['presentation_component.css'],
    template: '''<div [attr.class]="slidesClassList">
<div class="controls">
        <span (click)="prevSlide()"> &larr; </span> {{current}} <span (click)="nextSlide()"> &rarr; </span>
</div>
<ng-content></ng-content></div>''',
    directives: const [SymbolComponent],
    )
class PresentationComponent implements OnDestroy,OnInit {

  int _current = 1;
  int get current => _current;
  void set current(int value) {
    if (_current!=value) {
      _current = value;
      window.location.hash = 's'+_current.toString();
    }
  }

  int maxSlides =0;

  @Input('slides') set slidesAttr(slides) => maxSlides = int.parse(slides);

  @HostBinding('attr.class')
  String get slidesClassList {
    var sb = new StringBuffer();
    for (var i=1;i<=current;i++) sb.write("s${i} ");
    return sb.toString();
  }

  Function unRegister;
  ElementRef elRef;
  Renderer renderer;

  PresentationComponent(this.renderer,EventManager evm,this.elRef) {
    // TODO: rewrite it using @HostListener()
    this.unRegister = evm.addEventListener(document,'keyup', (KeyboardEvent key)  {
      //print("Key up ${key.which}");
      //window.console.debug(key);
      switch(key.which) {
        case 34:
        case 39:
        case 32:
          nextSlide();
          break;
        case 33:
        case 37:
          prevSlide();
          break;
      }
    });


    evm.addEventListener(window, 'hashchange', (HashChangeEvent e) {
      _setCurrentFromUrl(e.newUrl);
//      window.console.debug(newUrl);
    });

  }
  void _setCurrentFromUrl(String e) {
    var parts = e.split('#');
    if (parts.length>1) {
      var p = parts[1];
      if (p[0]=='s') {
        var newCurrent = int.parse(p.substring(1));
        if (newCurrent!=current) current = newCurrent;
      }
    }
  }

  ngOnDestroy() {
    unRegister();
  }
  ngOnInit() {
    _setCurrentFromUrl(window.location.toString());
  }

  nextSlide() {
    if (current<maxSlides) current++;
    this.renderer.setElementClass(this.elRef.nativeElement,'s'+current.toString(),false);
  }
  prevSlide() {
    if (current>1) current--;
    this.renderer.setElementClass(this.elRef.nativeElement,'s'+current.toString(),false);

  }

}
