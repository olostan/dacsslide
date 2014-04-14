library dacsslide;

import 'package:angular/angular.dart';
import 'dart:html' as dom;
import 'symbol.dart';
import "dart:async";

@NgComponent(
    selector: 'presentation',
    templateUrl: 'packages/dacsslide/presentation.html',
    cssUrl: 'packages/dacsslide/presentation.css',
    publishAs: 'presentation',
    applyAuthorStyles: true,
    visibility: NgDirective.CHILDREN_VISIBILITY
)
class Presentation implements NgAttachAware, NgDetachAware {
  int _slides;
  
  @NgAttr('slides')
  set slides(String value) {
    const noSlidedException = "Presentation should have 'slides' attribute with maximum ammount of slides";
    if (value==null) throw noSlidedException;
    _slides = int.parse(value, onError: (_) => throw noSlidedException);
  }
  dom.Element _element;
  int current = 0;
  List<PresentationSymbol> symbols = new List();
  Presentation(this._element); 
  
  void add(PresentationSymbol symbol) => symbols.add(symbol);
  
  List<StreamSubscription> _subscriptions = new List();
  
  void attach() {
    //print("Attached. $_slides ${symbols.length}");
    _subscriptions.add(dom.window.onResize.listen(_repositionSymbols));
    _subscriptions.add(dom.window.onKeyUp.listen(_keyPressed));
    _subscriptions.add(dom.window.onHashChange.listen(_setSlideFromHash));
    // without this delay, Symbol return 0 width so unable to center; 
    new Future.delayed(new Duration(milliseconds: 150), () {
      

      _repositionSymbols(null);
      symbols.forEach((s) => s.enter());
      if (dom.window.location.hash!="")
        _setSlideFromHash(null);
      else
        setSlide(1);
      _element.classes.remove("hidden");
 
    });
  
  }
  void _repositionSymbols(e) {
    int middleW =  dom.window.innerWidth ~/2;
    int middleH = dom.window.innerHeight ~/2;
    symbols.forEach( (s) => s.center(middleW, middleH));    
  }
  
  void setSlide(int n){
    if (n>_slides || n<1) return;
    while(current!=n) {
      if (current>n) {
        _element.classes.remove("s$current");
        current--;
      } else {
        current++;
        _element.classes.add("s$current");
      }
    }
    dom.window.location.hash = "#$current";
  }
  void next() => setSlide(current+1);
  void prev() => setSlide(current-1);
  
  void _keyPressed(dom.KeyboardEvent e) {
    //dom.window.console.log(e.keyCode);
    if (e.keyCode==39 || e.keyCode==32 || e.keyCode==34) next();
    if (e.keyCode==37 || e.keyCode==33) prev();
  }
  
  void detach() => _subscriptions.forEach((s) => s.cancel());
  
  void _setSlideFromHash(dom.Event e) {
    var newSlide = int.parse(dom.window.location.hash.substring(1));
    if (newSlide != current) setSlide(newSlide);    
  }
  
}

class PresentationModule extends Module {
  PresentationModule() {
    type(Presentation);
    type(PresentationSymbol);
  }
}