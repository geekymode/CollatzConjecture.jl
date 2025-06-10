# Fractals


## Zooming in

```@example FractalZoom
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()
width, height = 1000, 1000
    x_range = (-2.5, 2.5)
    y_range = (-2.5, 2.5)
    max_iterations = 8
 num = 77.0
maxIter = 25
zoomPlot, data1 = plot_collatz_zoom(num, 0.0, 1.0 / 500, 1.0 / 500, 1000, maxIter, complex_collatz, "n=$(num),max_iter=$(maxIter),stop_time($(num))=$(collatz_length(num))")
zoomPlot   
```