
class _SymbolState {

  Map<String,num> state = {};
  Map<String,String> outCache = {};

  var standartMods = <String,List<String>>{
    'move':['x','y'],
    'rotate':['+rx','+ry','+rz'],
    'rotateX':['+rx'],
    'scale':['+sx','+sy','+sz'],
    'up':['-y'],'down':['+y'],
    'left':['-x'],'right':['+x'],
    'delay':['delay'],
    'opacity':['opacity']
  };

  void transform(String modifier) {
    var op = modifier.indexOf("(");
    var cl = modifier.indexOf(")");
    var modName =op>0?modifier.substring(0,op):modifier;
    var arguments = op>0?modifier.substring(op+1,cl).split(","):[];
    List<String> modArgs = standartMods[modName];
    if (modArgs!=null) {
      for(var idx =0;idx<arguments.length;idx++) {
        __doOp(modArgs[idx],arguments[idx]);
      }
    } else {
      switch(modName) {
        case 'show':_doShow();break;
        case 'hide':_doHide();break;
        default:throw "Unknown modifier '$modifier'";
      }
    }
  }

  __doOp(String field, String nv) {
    int mult=1;
    bool relative = false;
    if (field[0]=='-') {
      mult = -1;field = field.substring(1);relative = true;
    } else if (field[0]=='+') {
      field = field.substring(1);relative = true;
    }
    num numNV;
    /*
    if (nv[0]=="+") {
      numNV =  num.parse(nv.substring(1)); relative = true;
    } else if (nv[0]=="-") {
      numNV =  num.parse(nv.substring(1)); relative = true; mult *= -1;
    } else */ numNV = num.parse(nv);

    var v = state[field];
    if (relative) v = (v==null?0:v)+numNV*mult;
    else v = numNV*mult;
    state[field] = v;
  }

  _doShow() {
    state['opacity'] =1;
  }
  _doHide() {
    state['opacity']=0;
  }
}

class _Css {
  _SymbolState symbol;

  _Css(this.symbol);

  List<String> transforms = [];

  String call() {
    return
      _doOpacity()+
          _doTransforms()+
          _doTransitionDelay();
  }
  String _doOpacity() {
    var opacity = symbol.state['opacity'];
    if (opacity==null) return "";
    var newOpacity = "opacity:${opacity};";
    if (newOpacity==symbol.outCache["opacity"]) return "";
    return symbol.outCache["opacity"] = newOpacity;
  }
  String _doTransitionDelay() {
    var delay = symbol.state['delay'];
    if (delay==null) return "";
    var newDelay = "transition-delay: ${delay}s;";
    if (newDelay==symbol.outCache["delay"]) return "";
    return symbol.outCache["delay"] = newDelay;
  }


  _addTransformAxis(String name, String axis, String pref,String suff) {
    var key = "$pref$axis";
    num v = symbol.state[key];
    if (v==null) return;
    var sV = "$v$suff";
    /*var cached = symbol.outCache["$name$key"];
    var sV = "$v$suff";
    if (cached==sV) return;
    print("Adding trasnform '$name', canched[$name$key]='$cached', new '$sV'");
    symbol.outCache["$name$key"]=sV;
    */
    transforms.add("$name${axis.toUpperCase()}($sV)");

  }

  _addTransform(String name, String pref,[String suff=""]) {
    _addTransformAxis(name,'x',pref,suff);
    _addTransformAxis(name,'y',pref,suff);
    _addTransformAxis(name,'z',pref,suff);

  }

  String _doTransforms() {
    _addTransform("translate","","px");
    _addTransform("rotate","r","deg");
    _addTransform("scale","s","");
    var newTransforms = transforms.join(" ");
    if (symbol.outCache['transforms'] == newTransforms||newTransforms=="") return "";
    symbol.outCache['transforms'] = newTransforms;
    return "transform:$newTransforms;";
  }
}
RegExp _symbRegExp = new RegExp(r'(#\w+):');
RegExp _symbInsideRegExp = new RegExp(r'(#\w+)\s*{((?:[^{]|\n)*?)::((\w+(\([^)]*?\))?\s*)+);((?:.|\n)*?)}');
//RegExp _symbInsideRegExp = new RegExp(r'(#\w+)\s*{((?:.|\n)*?)::((\w+(\([^)]*?\))?\s*)+);((?:.|\n)*?)}');

String transformCSSLide(String input) {
  var states = new Map<String,_SymbolState>();
  while(true) {
    var symbolMatch = _symbRegExp.firstMatch(input);
    var inlineMatch = _symbInsideRegExp.firstMatch(input);
    if (symbolMatch==null || (inlineMatch!=null && inlineMatch.start<symbolMatch.start)) {
      var newInput = input.replaceFirstMapped(_symbInsideRegExp, (match) {
        var symbol = match[1];
        var modifiers = match[3].split(" ")..removeWhere((s) => s==null||s=="");
        var state = states[symbol];
        if (state == null) states[symbol] = state = new _SymbolState();
        //print("inine mods: $symbol ${modifiers.join(' ')} ${state.state['x']} $input");
        modifiers.forEach(state.transform);
        return match[1]+" {"+match[2]+new _Css(state)()+match[6]+"}";
      });
      //print("is it end? ${newInput == input}, $input");
      if (newInput==input) return input;
      //input = newInput; return input;
      input = newInput;
    } else {
      var symbol = symbolMatch.group(1);
      var state = states[symbol];
      if (state == null) states[symbol] = state = new _SymbolState();
      var end = input.indexOf(";",symbolMatch.end);
      var modifiers = input.substring(symbolMatch.end,end).split(" ")..removeWhere((s) => s==null||s=="");
      modifiers.forEach(state.transform);
      input = input.replaceRange(symbolMatch.start, end+1,symbol+"{ "+new _Css(state)()+"}");
    }
  }

}