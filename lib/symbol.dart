import 'package:angular/angular.dart';
import 'dart:html' as dom;
import 'presentation.dart';
import 'dart:async';

@Decorator(
    selector: 'symbol'
)
class PresentationSymbol implements DetachAware {
  dom.Element element;
  Presentation presentation;
  PresentationSymbol(this.element, this.presentation) {
    presentation.add(this);
    this.element.style.position = "absolute";
  }
  Timer _timer;

  @NgAttr('track')
  void set track(String track) {
    if (track!=null) {
      _timer = new Timer.periodic(new Duration(milliseconds:250),_rePosition);
    }
  }
  int lastCx, lastCy, lastWidth, lastHeight;

  center(int cx, int cy) {
      //dom.window.console.log(element);
      //print("w:${element.clientWidth}");;
    lastCx = cx;lastCy =cy;
    element.style.left = "${cx-element.clientWidth/2}px";
    element.style.top = "${cy-element.clientHeight/2}px";
  }
  void _rePosition(_) {
    if (element.clientWidth!=lastWidth || element.clientHeight!=lastHeight)
      center(lastCx, lastCy);
  }
  enter() {
    element.classes.add("animated");
  }

  @override
  void detach() {
    if (_timer!=null) _timer.cancel();
  }
}
