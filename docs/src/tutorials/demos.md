# Collatz Sequences 

## Fancy representation

```@example plots
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()

# Create and display the visualization
fig = create_collatz_visualization(n=50, print_numbers=true)
fig
```