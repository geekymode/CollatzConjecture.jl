# Collatz Fractals
The traditional Collatz function uses a simple rule. If a number is even, divide it by 2. If a number is odd, multiply it by 3 and add 1. The Collatz conjecture becomes even more fascinating when extended to complex numbers, where the iteration creates fractal boundaries between convergent and divergent regions. These complex dynamics offer a glimpse into the profound mathematical depths of this elegantly simple problem.


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


## Convergence near integer points

```@example grid9
using CollatzConjecture
# Define 9 center points
centers_x = [5.0, 597.0, 23.0, 11.0, 100.0, 49.0, 141.0, 6.0, 7.0]
centers_y = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.0, -0.0, -0.0]

# Progressive zoom levels - getting smaller (more zoomed in)
zoom_widths = [1.0/10, 1/20, 1/100, 1/20, 0.04, 1/200, 1/200, 1/20, 1/40]
zoom_heights = [1.0/10, 1/20, 1/100, 1/20, 0.04, 1/200, 1/200, 1/20, 1/40]

# Different iterations for each subplot
max_iters = [25, 27, 20, 25, 25, 26, 25, 26, 25]
# Create grid plot
grid_fig, grid_data = plot_collatz_zoom_grid(
    centers_x, centers_y,
    zoom_widths, zoom_heights,
    300, max_iters,
    complex_collatz,
    ""
)
# save("assets/collatz_grid_3x3.png", grid_fig)
grid_fig

```

## Close in view

```@example gridZoom
using CollatzConjecture
# Define 9 center points
centers_x = [5.0, 597.0, 23.0, 11.0, 100.0, 49.0, 141.0, 6.0, 7.0]
centers_y = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.0, -0.0, -0.0]

# Progressive zoom levels - getting smaller (more zoomed in)
zoom_widths = [1.0/10, 1/20, 1/100, 1/20, 0.04, 1/200, 1/200, 1/20, 1/40]
zoom_heights = [1.0/10, 1/20, 1/100, 1/20, 0.04, 1/200, 1/200, 1/20, 1/40]

# Different iterations for each subplot
max_iters = [25, 27, 20, 25, 25, 26, 25, 26, 25]
grid_fig_zoom, grid_data_zoom = plot_collatz_zoom_grid(
    centers_x, centers_y,
    zoom_widths ./10, zoom_heights ./10,
    300, max_iters,
    complex_collatz,
    ""
)
grid_fig_zoom
```
