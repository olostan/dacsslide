library dacsslide;

import 'package:angular/angular.dart';
import 'dart:html' as dom;
import 'symbol.dart';
import "dart:async";

@Component(
    selector:'comment',
    template:'<content></content>',
    cssUrl: 'packages/dacsslide/comment.css'
)
class Comment implements AttachAware, DetachAware{
  PresentationService _service;
  dom.Element _element;
  Comment(this._service, this._element);
  
  @NgOneWayOneTime('slide')
  int slide;
  
  StreamSubscription _subscription;
  StreamSubscription _enabledSubscription;
  
  @override
  void attach() {
    _subscription = _service.onSlide.stream.listen((nSlide) => visible = nSlide==slide);
    _enabledSubscription = _service.commentsMode.stream.listen((mode) => enabled = mode);    
    _service.hasComments = true;
  }
  
  bool _visible = false;
  bool _enabled = true;
  
  set visible(bool visible) {
    if (_visible==visible) return;
    if (_enabled) {
      if (_visible && !visible) _element.classes.remove('visible');
      else _element.classes.add('visible');
    }
    _visible = visible;
  }
  set enabled(bool enabled) {
    _enabled = enabled;
    if (!enabled && _visible) _element.classes.remove('visible');
    else if (_visible) _element.classes.add('visible');
  }

  @override
  void detach() {
    _subscription.cancel();
    _enabledSubscription.cancel();
  }
}

@Component(
    selector: 'presentation',
    templateUrl: 'packages/dacsslide/presentation.html',
//    cssUrl: 'packages/dacsslide/presentation.css',
    publishAs: 'presentation',
    useShadowDom: false,
    visibility: Visibility.CHILDREN
)
class Presentation implements AttachAware, DetachAware {
  int _slides;
  PresentationService _service;
  
  @NgAttr('slides')
  set slides(String value) {
    const noSlidesException = "Presentation should have 'slides' attribute with maximum ammount of slides";
    if (value==null) throw noSlidesException;
    _slides = int.parse(value, onError: (_) => throw noSlidesException);
  }
  
  dom.Element _element;
  
  @NgTwoWay('slide')
  int current = 0;
  
  List<PresentationSymbol> symbols = new List();
  
  Presentation(this._element,this._service); 
  
  void add(PresentationSymbol symbol) => symbols.add(symbol);
  
  List<StreamSubscription> _subscriptions = new List();
  
  void attach() {
    //print("Attached. $_slides ${symbols.length}");
    //_service.attachPresentation(this);
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
    _service.commentsMode.add(_comments); 
  }
  void _repositionSymbols(e) {
    int middleW =  dom.window.innerWidth ~/2;
    int middleH = dom.window.innerHeight ~/2;
    symbols.forEach( (s) => s.center(middleW, middleH));    
  }
  
  void setSlide(int n){
    if (n>_slides || n<1) return;
    if (current==null) current = 0;
    while(current!=n) {
      if (current>n) {
        _removeClass("s$current");
        current--;
      } else {
        current++;
        _addClass("s$current");
      }
    }
    _service.onSlide.add(current);
    dom.window.location.hash = "#$current";
  }
  void next() => setSlide(current+1);
  void prev() => setSlide(current-1);
  
  bool _comments = true;
  
  get comments => _comments;
  set comments(value) {
    _comments = value;
    _service.commentsMode.add(_comments);
  }
  
  get hasComments => _service.hasComments;
  
  void _keyPressed(dom.KeyboardEvent e) {
    //dom.window.console.log(e.keyCode);
    if (e.keyCode==39 || e.keyCode==32 || e.keyCode==34) next();
    if (e.keyCode==37 || e.keyCode==33) prev();
  }
  
  void detach() {
    _subscriptions.forEach((s) => s.cancel());
  }
  
  void _setSlideFromHash(dom.Event e) {
    var newSlide = int.parse(dom.window.location.hash.substring(1));
    if (newSlide != current) setSlide(newSlide);    
  }
  
  void _addClass(String className) => _service.elements.forEach((el) => el.classes.add(className));
  void _removeClass(String className) => _service.elements.forEach((el) => el.classes.remove(className));
  
}

@Injectable()
class PresentationService {
  final _elements = new List<dom.Element>();
  
  final StreamController<int> onSlide = new StreamController<int>.broadcast();
    
  void register(dom.Element element) => _elements.add(element);
  void unRegister(dom.Element element) => _elements.remove(element);
  
  bool hasComments;
  final StreamController<bool> commentsMode = new StreamController<bool>.broadcast();

  
  Iterable<dom.Element> get elements => _elements;
  
  /*void addClass(String className) => _elements.forEach((el) => el.classes.add(className));
  void removeClass(String className) => _elements.forEach((el) => el.classes.remove(className));
  */
  
  /*void attachPresentation(Presentation newPresentation) {
    
    newPresentation.onEnterSlide.stream.pipe(_EnterSlide);
    newPresentation.onLeaveSlide.stream.pipe(_EnterSlide);    
  }*/
}

@Decorator(selector: '[presentation-classes]')
class PresentationClasses implements AttachAware, DetachAware {
  dom.Element _element;
  PresentationService _service;
  
  PresentationClasses(this._element,this._service);
  
  @override
  void attach() => _service.register(_element);

  @override
  void detach() => _service.unRegister(_element);
}

class PresentationModule extends Module {
  PresentationModule() {
    bind(Presentation);
    bind(PresentationSymbol);
    bind(PresentationService);
    bind(PresentationClasses);
    bind(Comment);

  }
}