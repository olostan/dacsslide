# List of supported functions

| Function | Meaning | Relative/Absolute |
|----------|---------|----------|
| `move(x,y)` | Move symbol to the location `x,y` pixels, number is always absolute | Absolute |
| `rotate(rx[,ry[,rz]])` | Rotate symbol on `rx` degrees on X axis, `ry` degrees on Y axis, and `rz` degrees on Z | Relative |
| `scale(sx[,sy[,sz]])` | Scale symbol to `sx`. If sy is set to `sx,sy`. If 'sz' - `sz` | Relative |
| `up(a)` | Move symbol `a` pixes up| Relative |
| `down(a)` | Move symbol `a` pixes down| Relative |
| `left(a)` | Move symbol `a` pixes left| Relative |
| `right(a)` | Move symbol `a` pixes right| Relative |
| `delay(a)` | Delay animation on `a` seconds| Absolute |
| `opacity(a)` | Set opacity to `a` | Absolute |
| `show` | Shows symbol |  |
| `hide` | Hides symbol |  |