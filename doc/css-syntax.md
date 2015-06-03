# CSS Extensions 

## How to use

DaCSSlide provide several extensions to CSS files (visual modifiers).

To use them you need to add DaCSSlide transformer to your `pubspec.yaml` file:

```yaml
transformers:
...
- dacsslide
...
```

> *Note 1:* If you want to use `csslib_transform`, `dacsslide` transfomer should be prior to it, otherwsie csslib tranformer
will raise errors because of invalid syntax.

> *Note 2:* Modifiers does not track CSS properties directly. So, for example, if you definer CSS trasnform directly in CSS 
like ``#a { transform: translateX(200px); }` using `.s2 { #a: up(20px); }` will produce `.s2 { #a { transform: translateX(-20px); } }` 
instead of `.s2 { #a { transform: translateX(180px); } }` as probably could be expected.

> *Note 3:* To have expected flow, you should define slides from up to down of the document. DaCSSlide does not detect slide
numbers during applying modifiers. It use order of appearance of modifiers.


## Syntax

### Visual modifiers

Visual modifiers are set of "functions" that define how visual appearance should change. 

Initially symbols are located in the center of the screen. You can change initial appearance by puting modifier(s) on symbol
without specifying slide number:

```css
#symbol: up(200)
```

If you need to put several modifiers you can put separate them with space:
```css
#symbol: up(200) rotate(30);
```

If modifier does not require parameter, you can skip it:
```css
#symbol: show;
```

### Stand-alone mode

If you using standard visual [modifiers](modifiers.md) is enough, you can use short version:
 
```css
#symbol_id: mod1 mod2(p) mod3(p1,p2)
```

for example
```css
#hello: show up(200);
```

### Inline mode

If you want to use both CSS styles and also DaCSSlide modifiers, you can embed modifiers into CSS rule by adding double 
column before them:
```css
#hello { font-size: 20px; ::up(200); }
```
or 
```css
.s10 { #hello { font-size: 30px; ::down(200) show; } }
```