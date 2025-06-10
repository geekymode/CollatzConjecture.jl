# Fractals

```@example FractalPlot
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()
    width, height = 1000, 1000
    x_range = (-2.5, 2.5)
    y_range = (-2.5, 2.5)
    max_iterations = 8
    julia_data_main = generate_complex_collatz_julia(width, height, x_range, y_range,
    complex_collatz, max_iterations)
plot_collatz_julia(julia_data_main, x_range, y_range,
    "Complex Collatz Julia Set",
    "T(z) = ¼(2 + 7z - (2 + 5z)cos(πz))",
    "plot_complex_collatz_main.png",
    (1200, 1000))
```

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