// Copyright (c) 2016, Valentyn Shybanov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular/core.dart';
import "package:angular/src/platform/dom/events/event_manager.dart" show EventManager;
import "dart:html" show KeyboardEvent,window,HashChangeEvent,document, Event;

@Injectable() 
class SlideService {

  int _current = 1;
  int maxSlides = 0;
  bool commentsPresent = false;
  bool commentsShow = true;

  int get current => _current;
  void set current(int value) {
    if (_current!=value) {
      _current = value;
      window.location.hash = 's'+_current.toString();
    }
  }

  void next() {
    if (current<maxSlides) current++;
  }
  void prev() {
    if (current>1) current--;
  }

}

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
    template: '''<div [class]="slidesClassList">
<div class="controls">
        <span (click)="prevSlide()" title="Previous slide"> &larr; </span> {{slideService.current}} <span (click)="nextSlide()"> &rarr; </span>
        <span *ngIf="showComments" title="Show/Hide speaker's comments" *ngIf="slideService.commentsPresent" (click)="slideService.commentsShow = !slideService.commentsShow;">C</span>
</div>
<ng-content></ng-content></div>''',
    directives: const [SymbolComponent, NgIf],

    encapsulation: ViewEncapsulation.None
    )
class PresentationComponent implements OnDestroy, OnInit {

  bool showComments = true;

  @Input('slides') set slidesAttr(slides) => slideService.maxSlides = int.parse(slides);
  @Input('comments') set commentsAttr(String comments) => showComments  = comments.toLowerCase()=='true';

  String _cachedClass;
  int _cachedCurrentSlide;

  @HostBinding('class')
  String get slidesClassList {
    if (_cachedCurrentSlide==slideService.current) return _cachedClass;
    var result = "";
    for (var i=1;i<=slideService.current;i++) result+="s${i} ";
    _cachedClass = result;
    _cachedCurrentSlide = slideService.current;
    return _cachedClass;
  }

  ElementRef elRef;

  _onKeyUp(Event ev) {
    KeyboardEvent key = ev;
    //print("Key up ${key.which}");
    switch(key.which) {
      case 34:
      case 39:
      case 32:
        _zone.run(() {nextSlide();});
        break;
      case 33:
      case 37:
        _zone.run(() {prevSlide();});
        break;
    }
  }
  void _onHashChange(Event ev) {
    HashChangeEvent e = ev;
    _setCurrentFromUrl(e.newUrl);
  }

  NgZone _zone;

  SlideService slideService;

  PresentationComponent(EventManager evm,this.elRef, this.slideService, this._zone) {

    document.addEventListener('keyup', _onKeyUp);
    window.addEventListener('hashchange', _onHashChange);

  }
  void _setCurrentFromUrl(String e) {
    var parts = e.split('#');
    if (parts.length>1) {
      var p = parts[1];
      if (p[0]=='s') {
        var newCurrent = int.parse(p.substring(1));
        if (newCurrent!=slideService.current) 
          slideService.current = newCurrent;
        return;
      }
    }
    slideService.current = 1;
  }

  ngOnDestroy() {
    document.removeEventListener('keyup', _onKeyUp);
    document.removeEventListener('hashchange', _onHashChange);
  }
  ngOnInit() {
    _setCurrentFromUrl(window.location.toString());
  }

  nextSlide() {
    slideService.next();
  }
  prevSlide() {
    slideService.prev();
  }
}

@Component(    
    selector: 'comment',
    encapsulation: ViewEncapsulation.None,
    template:'<div [class]="slideService.commentsShow && slide==slideService.current?\'visible\':\'hidden\'"><ng-content></ng-content></div>'
) 
class CommentComponent {
  SlideService slideService;
  int slide;

  @Input('slide') void set slideAttr(String s) => slide = int.parse(s);

  CommentComponent(this.slideService) {
    this.slideService.commentsPresent = true;
  }
}