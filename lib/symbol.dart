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

  @NgOneWayOneTime('fixed') bool fixed=false;

  int lastCx, lastCy, lastWidth, lastHeight;

  center(int cx, int cy) {
    if (fixed) return;
      //dom.window.console.log(element);
      //print("w:${element.clientWidth}");;
    lastCx = cx;lastCy =cy;
    element.style.left = "${(cx-element.clientWidth/2).round()}px";
    element.style.top = "${(cy-element.clientHeight/2).round()}px";
  }
  void _rePosition(_) {
    if (element.clientWidth!=lastWidth || element.clientHeight!=lastHeight) {
      center(lastCx, lastCy);
      lastWidth = element.clientWidth;
      lastHeight = element.clientHeight;
    }
  }
  enter() {
    element.classes.add("animated");
    print("Fixed: ${this.fixed}");
    if (!this.fixed)
      _timer = new Timer.periodic(new Duration(milliseconds:250),_rePosition);
  }

  @override
  void detach() {
    if (_timer!=null) _timer.cancel();
  }
}
