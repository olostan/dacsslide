import 'package:angular/angular.dart';
import 'dart:html' as dom;
import 'presentation.dart';

@Decorator(
    selector: 'symbol'
)
class PresentationSymbol {
  dom.Element element;
  Presentation presentation;
  PresentationSymbol(this.element, this.presentation) {
    presentation.add(this);
    this.element.style.position = "absolute";
  }
  center(int cx, int cy) {
      //dom.window.console.log(element);
      //print("w:${element.clientWidth}");;
      element.style.left = "${cx-element.clientWidth/2}px";
      element.style.top = "${cy-element.clientHeight/2}px";
  }
  enter() {
    element.classes.add("animated");
  }
}
