# Changelog

##0.3.0-beta

Upgraded to Angular 5.0 and using dartdevc.

##0.2.1 

Added speaker comments support. Just add
```
<comment slide="1">Some comment</comment>
```

##0.2.0

Added possibility to change units. put anywhere
```
/* dacsslide.units = vmax */
```
All transform operators will use that units.

*BREAKING CHANGE* Now if modifier has several parameters but was called with less, it will use last specified parameter (previously it used X-axis). E.g. `scale(2)` will produce `scaleX(2) scaleY(2)` and not just `scaleX(2)` like before. Same for `rotate`. Please add axis modifier to have previous behavior.  

*BREAKING CHANGE* `scale` modifier now accept 2 parameters (`X` and `Y`). If you need scaling on Z-axis, you can use `scaleZ`.


##0.1.3

Switched to Angular 4.

##0.1.2

Adding event listeners directly, not through EventManager. DDC friendly. 

##0.1.1

Angular 2. 

## 0.0.15

- Added support of additional parameters in URL hash (Appended by `&`). Could be used by other plugins, like remote controller.

## 0.0.14

- Tracking symbols by default. Symbols can be not auto-centralized by setting `fixed=true` on symbol.

## 0.0.12

- Aded "track" property to track symbol's width/height.

## 0.0.11

- Aded inline syntax. Added `opacity` function.

## 0.0.10

- Aded `delay` functions. Removed relative modifier for `move`. Added documentation for functions.

## 0.0.9

- Added shortened relative modifiers (`up`, `down`, `left`, `right`) and tests 

## 0.0.8

- Added DACSSlie extension to SCSS syntax

## 0.0.7

- Added CSSLib transform so now it is possible to use nested CSS rules and other features provided by CSSLib

