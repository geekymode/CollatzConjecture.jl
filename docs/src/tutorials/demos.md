# Collatz Sequences 

# Collatz sequence connectivity

```@example plotsConnect
using CollatzConjecture
test_sequences, shared_vertices = test_collatz_connectivity(10)
test_sequences
shared_vertices
```

# Stopping time


```@example StopTime
using CollatzConjecture
plot_stopping_times_scatter(5000)
```
## Fancy representation

```@example plotsTree
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()

# Create and display the visualization
fig = create_collatz_visualization(n=5000, print_numbers=true)
fig
```

## Twig like representation

```@example plotsTwig
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()
figX = collatz_graph_highlight_one(1000, vertex_size=10, highlight_size=20, label_fontsize=10)
figX[1]
```

# Statistics

# Distribution of the stopping time 

```@example StopTimeHist
using CollatzConjecture
    plot_stopping_times_histogram(100000)
```