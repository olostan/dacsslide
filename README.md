DaCSSlide [![Build Status](https://drone.io/github.com/olostan/dacsslide/status.png)](https://drone.io/github.com/olostan/dacsslide/latest)
===============

Port of [JaCSS](https://github.com/olostan/jacss) - tiny "framework" for building pure CSS3-animation based presentations. 

Demo
====

http://slides.olostan.name/dartFlight/dartflightslides.html


Example
========

Example could be found in `web` folder. 

In HTML file you need to speicfy "symbols":

```
<presentation slides="8" class="hidden">
      <symbol id="hello">
        Hello {{world}}
      </symbol>
      <symbol id="center">
        Center
      </symbol>
</presentation>
```

And in CSS file you need to specify behaviour: 
```
#center {
  opacity:0;
}
.s2  #hello {
  -webkit-transform:translateY(200px)
}
.s2  #center {
  background-color:red;
  opacity:1;
}
.s3  #hello {
  -webkit-transform:translateY(200px) translateX(400px)
}
...
```

Where `.sN <symbol-id>` means behaviour for slide (keyframe) `N` of symbol `<symbol-id>`
