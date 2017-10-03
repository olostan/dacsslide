// Copyright (c) 2016, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/core.dart';
import "package:angular/src/platform/dom/events/event_manager.dart" show EventManager;
import "dart:html" show KeyboardEvent,window,HashChangeEvent,document, Event;


@Component(
    selector: 'symbol',
    encapsulation: ViewEncapsulation.None,

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
    encapsulation: ViewEncapsulation.None
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

  ElementRef elRef;

  _onKeyUp(Event ev) {
    KeyboardEvent key = ev;
    //print("Key up ${key.which}");
    switch(key.which) {
      case 34:
      case 39:
      case 32:
        _zone.run(nextSlide);
        break;
      case 33:
      case 37:
        _zone.run(prevSlide);
        break;
    }
  }
  void _onHashChange(Event ev) {
    HashChangeEvent e = ev;
    _setCurrentFromUrl(e.newUrl);
  }

  NgZone _zone;

  PresentationComponent(EventManager evm,this.elRef) {

    this._zone = evm.getZone();
    document.addEventListener('keyup', _onKeyUp);
    window.addEventListener('hashchange', _onHashChange);

  }
  void _setCurrentFromUrl(String e) {
    var parts = e.split('#');
    if (parts.length>1) {
      var p = parts[1];
      if (p[0]=='s') {
        var newCurrent = int.parse(p.substring(1));
        if (newCurrent!=current) _zone.run( () => current = newCurrent);
      }
    }
  }

  ngOnDestroy() {
    document.removeEventListener('keyup', _onKeyUp);
    document.removeEventListener('hashchange', _onHashChange);
  }
  ngOnInit() {
    _setCurrentFromUrl(window.location.toString());
  }

  nextSlide() {
    if (current<maxSlides) current++;
  }
  prevSlide() {
    if (current>1) current--;
  }

}
