import 'package:angular2/core.dart';
import "dart:async" show Future, Completer;
import "dart:html";
import "package:http/browser_client.dart";
import "dart:convert" show HtmlEscape;
import "dart:js" show context;

@Injectable()
class SampleService {
  Completer _loaded = new Completer();
  final BrowserClient _http;

  SampleService(this._http) {
    var script = new ScriptElement();
    script.src = 'packages/slides_ng2high/prettify/prettify.js';
    script.type = 'text/javascript';
    script.onLoad.listen((event) {
      _loaded.complete();
    });
    document.body.append(script);

    var css = new LinkElement();
    css.href = 'packages/slides_ng2high/prettify/sons-of-obsidian.css';
    css.type = 'text/css';
    css.rel = 'stylesheet';
    document.head.append(css);
  }

  Future ensureLoaded() => _loaded.future;

  getSample(String url) async {
    final response = await _http.get(url);
    if (response.statusCode!=200) throw new Exception("Error loading ${url}: ${response.statusCode}");
    return response.body;
  }
}


@Directive(selector: '[sample]')
class SampleDirective implements OnInit {
  static final HtmlEscape sanitizer = const HtmlEscape();

  SampleService _prettifyService;

  @Input('sample') String url;
  @Input('name') String name;

  Renderer _renderer;
  ViewContainerRef _viewContainer;

  SampleDirective(this._prettifyService, this._renderer, this._viewContainer) {
  }

  ngOnInit() async {
    final sample = await _prettifyService.getSample(url);
    final sanitiedSample = sanitizer.convert(sample);
    var type = 'html';
    var extensionIdx = url.lastIndexOf('.');
    if (extensionIdx>-1) {
      type = url.substring(extensionIdx);
    }
    // hack for dart samples:
    if (type == "daart") type = "dart";
    await _prettifyService.ensureLoaded();
    final prettifiedSample =  context.callMethod('prettyPrintOne', [sanitiedSample,type]);
    final wrappedSample = '<pre id=${name} class="prettyprint">$prettifiedSample</pre>';
    this._renderer.setElementProperty(this._viewContainer.element.nativeElement,'innerHTML',wrappedSample);


  }
}
