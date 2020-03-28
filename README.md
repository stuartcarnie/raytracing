# Ray Tracing: Weekend, Week and Life

This repository is the ongoing result of working my way through Peter Shirley's
wonderful series on learning [ray tracing][0].

To aid in understanding how this repository evolves, it is helpful to list 
my own personal goals:

* Learn something new that has always fascinated me.
* Explore authoring high performance Swift code. My approach has been
  scientific, by writing, profiling (Instruments) and improving. I 
  have made an effort to avoid reducing readability during this exercise.
* Utilize macOS frameworks, including Grand Central Dispatch, CoreGraphics, 
  simd, etc.


## Swift Package

As noted previously, the RayTracing package is intended for macOS, as it
intentionally leverages macOS frameworks in an effort to improve performance. 


## Weekend

The first target, `weekend`, is the result of working through the book
[Ray Tracing in One Weekend][1].



[0]: https://raytracing.github.io
[1]: https://raytracing.github.io/books/RayTracingInOneWeekend.html
