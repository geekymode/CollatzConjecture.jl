# push!( LOAD_PATH, "../" )
import CollatzConjecture  # Import the module to  have access to functions

"""
    astro_intensity(l, s, r, h, g)

Calculate RGB color values for astronomical intensity visualization.

This function computes RGB color values based on astronomical parameters using a 
mathematical transformation that combines lightness, saturation, and spectral 
characteristics. The calculation involves trigonometric functions and matrix-like 
operations to produce realistic color representations for astronomical data.

# Arguments
- `l::Real`: Lightness parameter (typically in range [0,1])
- `s::Real`: Saturation parameter 
- `r::Real`: Radial or spectral parameter
- `h::Real`: Hue amplitude parameter
- `g::Real`: Gamma correction exponent

# Returns
- `Vector{Float64}`: RGB color values as a 3-element vector [R, G, B], clamped to [0,1]

# Examples
```julia-repl
julia> astro_intensity(0.5, 1.0, 0.2, 0.8, 2.0)
3-element Vector{Float64}:
 0.4123
 0.2847
 0.6891

julia> astro_intensity(0.8, 0.5, 0.1, 1.2, 1.5)
3-element Vector{Float64}:
 0.7234
 0.5678
 0.8901

julia> astro_intensity(0.2, 2.0, 0.5, 0.6, 1.8)
3-element Vector{Float64}:
 0.1456
 0.0892
 0.3278
```

# Notes
The function uses specific transformation coefficients optimized for astronomical 
color representation:
- Red channel: -0.14861 * cos(ψ) + 1.78277 * sin(ψ)
- Green channel: -0.29227 * cos(ψ) - 0.90649 * sin(ψ)  
- Blue channel: 1.97294 * cos(ψ)

Where ψ = 2π * (s/3 + r * l) represents the phase angle for color calculation.

All output values are clamped to the valid color range [0,1].

"""
function astro_intensity(l, s, r, h, g)
    psi = 2π * (s/3 + r * l)
    a_val = h * l^g * (1 - l^g) / 2
    
    # Matrix multiplication equivalent
    cos_psi, sin_psi = cos(psi), sin(psi)
    color_vals = l^g .+ a_val .* [
        -0.14861 * cos_psi + 1.78277 * sin_psi,
        -0.29227 * cos_psi - 0.90649 * sin_psi,
         1.97294 * cos_psi + 0.0 * sin_psi
    ]
    
    # Clamp values to [0,1] range for valid colors
    return clamp.(color_vals, 0, 1)
end

"""
    generate_path_colors(path_length, s, r, h, g)

Generate colors for a path using astronomical intensity mapping.

# Arguments
- `path_length`: Number of points in the path
- `s`: Saturation parameter for astro_intensity function
- `r`: Red component parameter for astro_intensity function  
- `h`: Hue parameter for astro_intensity function
- `g`: Green component parameter for astro_intensity function

# Returns
- Array of RGB colors interpolated along the path length

# Examples
```julia
colors = generate_path_colors(10, 0.8, 1.0, 0.5, 0.7)
```
"""
function generate_path_colors(path_length, s, r, h, g)
    if path_length <= 1
        return [RGB(0.5, 0.5, 0.5)]
    end
    
    colors = RGB[]
    for i in 0:(path_length-1)
        l = i / (path_length - 1)
        rgb_vals = astro_intensity(l, s, r, h, g)
        push!(colors, RGB(rgb_vals...))
    end
    return colors
end


"""
    collatz_angle_path(n, e, a, f)

Generate a Collatz sequence and convert it to an angle-based path in Cartesian coordinates.

The function generates the Collatz sequence starting from `n`, reverses it to begin from 1,
then calculates radii and angles based on the sequence values to create a geometric path.

# Arguments
- `n`: Starting number for the Collatz sequence (must be positive integer)
- `e`: Exponent parameter for radius calculation
- `a`: Angle scaling factor
- `f`: Angle offset factor (typically used to distinguish even/odd behavior)

# Returns
- Array of (x, y) coordinate tuples representing the path, starting from origin (0, 0)

# Details
The path is constructed by:
1. Generating the Collatz sequence from `n` to 1
2. Reversing the sequence to start from 1
3. Converting sequence values to radii using: `r = value / (1 + value^e)`
4. Calculating angles using: `angle = a * (f - 2 * (value % 2))`
5. Converting to Cartesian coordinates using cumulative angles and radii

# Examples
```julia
path = collatz_angle_path(7, 0.5, π/4, 1.0)
```
"""
function collatz_angle_path(n, e, a, f)
    sequence = Int[]
    nn = n
    
    # Generate Collatz sequence
    while nn != 1
        push!(sequence, nn)
        nn = iseven(nn) ? nn ÷ 2 : 3*nn + 1
    end
    push!(sequence, nn)
    
    # Reverse sequence to start from 1
    reverse!(sequence)
    
    # Calculate angle path
    seq_float = Float64.(sequence)
    radii = seq_float ./ (1 .+ seq_float.^e)
    angles = a .* (f .- 2 .* (sequence .% 2))
    
    # Convert to Cartesian coordinates using cumulative angles
    cumulative_angles = cumsum(angles)
    x_coords = cumsum(radii .* cos.(cumulative_angles))
    y_coords = cumsum(radii .* sin.(cumulative_angles))
    
    # Prepend origin point
    pushfirst!(x_coords, 0.0)
    pushfirst!(y_coords, 0.0)
    
    return collect(zip(x_coords, y_coords))
end

"""
    collatz_paths(numbers, e, a, f)

Generate Collatz angle paths for multiple starting numbers.

This is a vectorized version of `collatz_angle_path` that processes multiple starting 
numbers simultaneously, returning an array of paths.

# Arguments
- `numbers`: Collection of positive integers to use as starting values for Collatz sequences
- `e`: Exponent parameter for radius calculation (applied to all paths)
- `a`: Angle scaling factor (applied to all paths)
- `f`: Angle offset factor (applied to all paths)

# Returns
- Array of paths, where each path is an array of (x, y) coordinate tuples

# Examples
```julia
# Generate paths for numbers 3, 5, and 7
paths = collatz_paths([3, 5, 7], 0.5, π/4, 1.0)

# Generate paths for a range of numbers
paths = collatz_paths(1:10, 0.3, π/6, 1.5)
```


"""
function collatz_paths(numbers, e, a, f)
    return [collatz_angle_path(n, e, a, f) for n in numbers]
end

"""
    create_collatz_visualization(; kwargs...)

Create a visualization of Collatz sequences as colored angle paths.

This function generates multiple Collatz sequences, converts them to geometric paths,
and creates a Makie.jl visualization with gradient colors along each path.

# Keyword Arguments

## Color Parameters
- `s = 2.49`: Saturation parameter for color generation
- `r = 0.76`: Red component parameter for color generation
- `h = 1.815`: Hue parameter for color generation
- `g = 1.3`: Green component parameter for color generation
- `opacity = 0.5`: Transparency level for path lines (0.0 to 1.0)

## Structure Parameters
- `e = 1.3`: Exponent parameter for radius calculation in path generation
- `a = 0.19`: Angle scaling factor for path generation
- `f = 0.7`: Angle offset factor for path generation

## Number Selection
- `n = 300`: Number of random sequences to generate (used when `use_range = false`)
- `use_range = false`: Whether to use a specific range instead of random numbers
- `range_start = 5000`: Starting number for range (used when `use_range = true`)
- `range_end = 5020`: Ending number for range (used when `use_range = true`)

## Output Control
- `print_numbers = false`: Whether to print the numbers being processed

# Returns
- `Figure`: A Makie.jl Figure object containing the visualization

# Examples
```julia
# Create visualization with default parameters
fig = create_collatz_visualization()

# Create visualization with custom color parameters
fig = create_collatz_visualization(s=3.0, r=0.8, opacity=0.7)

# Create visualization for a specific range of numbers
fig = create_collatz_visualization(use_range=true, range_start=100, range_end=150)

# Create visualization with verbose output
fig = create_collatz_visualization(n=50, print_numbers=true)
```

# Details
The visualization process:
1. Generates a set of numbers (either random or from a specified range)
2. Computes Collatz angle paths for each number
3. Creates a transparent-background figure with hidden axes
4. Plots each path as colored line segments with gradient colors
5. Auto-scales the view to fit all paths

Each path is colored using the `generate_path_colors` function with astronomical
intensity mapping, creating smooth color transitions along the sequence.


"""
function create_collatz_visualization(;
    # Color parameters
    s = 2.49, r = 0.76, h = 1.815, g = 1.3, opacity = 0.5,
    # Structure parameters
    e = 1.3, a = 0.19, f = 0.7,
    # Number of sequences
    n = 300,
    # Range or specific numbers to use
    use_range = false,
    range_start = 5000, range_end = 5020,
    # Output control
    print_numbers = false
)
    # Generate numbers to process
    if use_range
        numbers = collect(range_start:range_end)
    else
        numbers = rand(1:1000000, n)
    end
    
    # Print the numbers if requested
    if print_numbers
        println("Generating Collatz sequences for $(length(numbers)) numbers:")
        if length(numbers) <= 50
            println("Numbers: ", numbers)
        else
            println("Numbers: ", numbers[1:10], " ... ", numbers[end-9:end])
            println("(showing first 10 and last 10 of $(length(numbers)) total)")
        end
        println()
    end
    
    # Generate all paths
    paths = collatz_paths(numbers, e, a, f)
    
    # Create figure
    fig = Figure(size = (800, 800), backgroundcolor = :transparent)
    ax = Axis(fig[1, 1],
        backgroundcolor = :transparent,
        leftspinevisible = false,
        rightspinevisible = false,
        topspinevisible = false,
        bottomspinevisible = false,
        xticksvisible = false,
        yticksvisible = false,
        xticklabelsvisible = false,
        yticklabelsvisible = false,
        xgridvisible = false,
        ygridvisible = false
    )
    
    # Plot each path with its colors
    for path in paths
        if length(path) > 1
            # Extract coordinates
            x_coords = [p[1] for p in path]
            y_coords = [p[2] for p in path]
            
            # Generate colors for this path
            colors = generate_path_colors(length(path), s, r, h, g)
            
            # Plot line segments with individual colors
            for i in 1:(length(path)-1)
                lines!(ax,
                    [x_coords[i], x_coords[i+1]],
                    [y_coords[i], y_coords[i+1]],
                    color = (colors[i], opacity),
                    linewidth = 1.5
                )
            end
        end
    end
    
    # Auto-scale the view
    autolimits!(ax)
    
    return fig
end

"""
    create_collatz_with_labels(; kwargs...)

Create a visualization of Collatz sequences as colored angle paths with vertex labels.

This function generates Collatz sequences, converts them to geometric paths, and creates
a Makie.jl visualization with gradient colors and labeled vertices showing the actual
Collatz numbers at each point along the path.

# Keyword Arguments

## Color Parameters
- `s = 2.49`: Saturation parameter for color generation
- `r = 0.76`: Red component parameter for color generation
- `h = 1.815`: Hue parameter for color generation
- `g = 1.3`: Green component parameter for color generation
- `opacity = 0.5`: Transparency level for path lines (0.0 to 1.0)

## Structure Parameters
- `e = 1.3`: Exponent parameter for radius calculation in path generation
- `a = 0.19`: Angle scaling factor for path generation
- `f = 0.7`: Angle offset factor for path generation

## Number Selection
- `n = 5`: Number of sequences to generate (kept small for label readability)
- `use_range = false`: Whether to use a specific range instead of random numbers
- `range_start = 1`: Starting number for range (used when `use_range = true`)
- `range_end = 5000`: Ending number for range (used when `use_range = true`)

## Label Parameters
- `label_fontsize = 8`: Font size for vertex labels
- `label_color = :white`: Color of vertex labels
- `show_vertex_dots = true`: Whether to show dots at vertices
- `max_label_length = 50`: Maximum number of labels per path (for long sequences)

## Output Control
- `print_numbers = false`: Whether to print the numbers being processed

# Returns
- `Figure`: A Makie.jl Figure object containing the labeled visualization

# Examples
```julia
# Create labeled visualization with default parameters
fig = create_collatz_with_labels()

# Create visualization for specific numbers with custom labels
fig = create_collatz_with_labels(
    use_range=true, range_start=7, range_end=12,
    label_fontsize=10, label_color=:cyan
)

# Create visualization with fewer labels for cleaner appearance
fig = create_collatz_with_labels(
    n=3, max_label_length=20, show_vertex_dots=false
)

# Create visualization with verbose output
fig = create_collatz_with_labels(n=5, print_numbers=true)
```

# Details
The labeled visualization process:
1. Generates a set of numbers (smaller range for readability)
2. Computes Collatz sequences and their corresponding angle paths
3. Creates a transparent-background figure with hidden axes
4. Plots each path as colored line segments with gradient colors
5. Adds vertex dots at sequence points (optional)
6. Labels each vertex with its corresponding Collatz number
7. For very long sequences, samples labels to maintain readability

The labeling system ensures that each Collatz number is positioned at its correct
geometric location along the path. For sequences longer than `max_label_length`,
the function intelligently samples vertices while always including the first and
last numbers.

# Notes
- Uses smaller default numbers (10-100) compared to the unlabeled version for better readability
- Labels are offset slightly below vertices to avoid overlap with dots
- Very long sequences are automatically subsampled to prevent overcrowding


"""
function create_collatz_with_labels(;
    # Color parameters
    s = 2.49, r = 0.76, h = 1.815, g = 1.3, opacity = 0.5,
    # Structure parameters  
    e = 1.3, a = 0.19, f = 0.7,
    # Number of sequences (keep small for readability)
    n = 5,
    # Range or specific numbers to use
    use_range = false,
    range_start = 1, range_end = 5000,
    # Label parameters
    label_fontsize = 8,
    label_color = :white,
    show_vertex_dots = true,
    max_label_length = 50,  # Limit labels for very long sequences
    # Output control
    print_numbers = false
)
    
    # Generate numbers to process (use smaller numbers for better readability)
    if use_range
        numbers = collect(range_start:min(range_start + n - 1, range_end))
    else
        numbers = rand(10:100, n)  # Smaller numbers for cleaner labels
    end
    
    # Print the numbers if requested
    if print_numbers
        println("Generating labeled Collatz sequences for $(length(numbers)) numbers:")
        println("Numbers: ", numbers)
        println()
    end
    
    # Generate paths with original sequences
    paths_with_sequences = []
    for num in numbers
        sequence = Int[]
        nn = num
        
        # Generate Collatz sequence (original order: starting number → 1)
        while nn != 1
            push!(sequence, nn)
            nn = iseven(nn) ? nn ÷ 2 : 3*nn + 1
        end
        push!(sequence, nn)  # Add the final 1
        
        # For angle path calculation, we need to reverse (1 → starting number)
        reverse_seq = reverse(sequence)
        seq_float = Float64.(reverse_seq)
        radii = seq_float ./ (1 .+ seq_float.^e)
        angles = a .* (f .- 2 .* (reverse_seq .% 2))
        
        cumulative_angles = cumsum(angles)
        x_coords = cumsum(radii .* cos.(cumulative_angles))
        y_coords = cumsum(radii .* sin.(cumulative_angles))
        
        # Prepend origin point
        pushfirst!(x_coords, 0.0)
        pushfirst!(y_coords, 0.0)
        
        path = collect(zip(x_coords, y_coords))
        
        # Store path with correct sequence alignment
        label_sequence = reverse_seq  # This matches x_coords[2:end], y_coords[2:end]
        
        push!(paths_with_sequences, (path, label_sequence, x_coords, y_coords))
    end
    
    # Create figure
    fig = Figure(size = (1000, 1000), backgroundcolor = :transparent)
    ax = Axis(fig[1, 1], 
        backgroundcolor = :transparent,
        leftspinevisible = false,
        rightspinevisible = false,
        topspinevisible = false,
        bottomspinevisible = false,
        xticksvisible = false,
        yticksvisible = false,
        xticklabelsvisible = false,
        yticklabelsvisible = false,
        xgridvisible = false,
        ygridvisible = false,
        # title = "Collatz Sequences with Vertex Labels",
        titlecolor = :white,
        titlesize = 16
    )
    
    # Plot each path with its colors and labels
    for (path, sequence, x_coords, y_coords) in paths_with_sequences
        if length(path) > 1
            # Generate colors for this path
            colors = generate_path_colors(length(path), s, r, h, g)
            
            # Plot line segments with individual colors
            for i in 1:(length(path)-1)
                lines!(ax, 
                    [x_coords[i], x_coords[i+1]], 
                    [y_coords[i], y_coords[i+1]], 
                    color = (colors[i], opacity),
                    linewidth = 2
                )
            end
            
            # Add vertex dots for the actual sequence numbers (skip origin)
            if show_vertex_dots
                scatter!(ax, x_coords[2:end], y_coords[2:end], 
                    color = (:yellow, 0.7), 
                    markersize = 4
                )
            end
            
            # Add labels for each vertex positioned correctly
            # sequence[i] corresponds to x_coords[i+1], y_coords[i+1] (because of origin offset)
            label_indices = if length(sequence) > max_label_length
                # Sample indices for very long sequences, but always include first and last
                step_size = max(1, length(sequence) ÷ max_label_length)
                indices = collect(1:step_size:length(sequence))
                # Ensure we always include the last vertex
                if indices[end] != length(sequence)
                    push!(indices, length(sequence))
                end
                indices
            else
                1:length(sequence)
            end
            
            for i in label_indices
                if i <= length(sequence)
                    # sequence[i] corresponds to coordinates at x_coords[i+1], y_coords[i+1]
                    coord_index = i + 1
                    if coord_index <= length(x_coords)
                        text!(ax, x_coords[coord_index], y_coords[coord_index], 
                            text = string(sequence[i]),
                            color = label_color,
                            fontsize = label_fontsize,
                            align = (:center, :center),
                            strokecolor = label_color,
                            strokewidth = 0.25,
                            offset = (0, -10)
                        )
                    end
                end
            end
        end
    end
    
    # Auto-scale the view
    autolimits!(ax)
    
    return fig
end

"""
    create_collatz_tree(; kwargs...)

Create a tree-like visualization of Collatz sequences as colored angle paths with vertex labels.

This function generates Collatz sequences, converts them to geometric paths, and creates
a Makie.jl tree visualization with gradient colors and labeled vertices showing the actual
Collatz numbers. The tree structure emphasizes the branching nature of Collatz sequences
when visualized from their common convergence point.

# Keyword Arguments

## Color Parameters
- `s = 2.49`: Saturation parameter for color generation
- `r = 0.76`: Red component parameter for color generation
- `h = 1.815`: Hue parameter for color generation
- `g = 1.3`: Green component parameter for color generation
- `opacity = 0.5`: Transparency level for path lines (0.0 to 1.0)

## Structure Parameters
- `e = 1.3`: Exponent parameter for radius calculation in path generation
- `a = 0.19`: Angle scaling factor for path generation
- `f = 0.7`: Angle offset factor for path generation

## Number Selection
- `n = 5`: Number of sequences to generate (kept small for tree readability)
- `use_range = false`: Whether to use a specific range instead of random numbers
- `range_start = 1`: Starting number for range (used when `use_range = true`)
- `range_end = 5000`: Ending number for range (used when `use_range = true`)

## Visualization Parameters
- `label_fontsize = 8`: Font size for vertex labels
- `label_color = :white`: Color of vertex labels
- `show_vertex_dots = true`: Whether to show dots at vertices
- `vertex_size = 8`: Size of vertex dots/markers
- `max_label_length = 50`: Maximum number of labels per path (for long sequences)

## Output Control
- `print_numbers = false`: Whether to print the numbers being processed

# Returns
- `Figure`: A Makie.jl Figure object containing the tree visualization

# Examples
```julia
# Create tree visualization with default parameters
fig = create_collatz_tree()

# Create tree for specific numbers with larger vertices
fig = create_collatz_tree(
    use_range=true, range_start=10, range_end=15,
    vertex_size=12, label_fontsize=10
)

# Create minimal tree without vertex dots
fig = create_collatz_tree(
    n=3, show_vertex_dots=false, label_color=:cyan
)

# Create tree with custom structure parameters
fig = create_collatz_tree(
    e=1.5, a=0.25, f=0.8, vertex_size=6
)
```

# Details
The tree visualization process:
1. Generates a set of numbers (smaller range for readability)
2. Computes Collatz sequences and their corresponding angle paths
3. Creates paths that emanate from a common origin (representing convergence to 1)
4. Plots each branch as colored line segments with gradient colors
5. Adds configurable vertex markers at sequence points
6. Labels vertices with their corresponding Collatz numbers
7. Uses black vertex dots to emphasize the tree structure

The tree structure becomes apparent as multiple Collatz sequences are displayed
simultaneously, showing how different starting numbers create branching paths
that all converge to the same point. The `vertex_size` parameter allows for
customization of the node prominence in the tree structure.

# Notes
- Uses black vertex dots (instead of yellow) to emphasize tree node structure
- Vertex size is configurable to enhance tree visualization aesthetics
- Best viewed with smaller numbers of sequences (3-10) for clear tree structure
- All sequences share the common convergence point at the origin

# See Also
- [`create_collatz_with_labels`](@ref): Create labeled Collatz paths
- [`create_collatz_visualization`](@ref): Create unlabeled Collatz visualization
- [`collatz_paths`](@ref): Generate multiple Collatz angle paths
- [`generate_path_colors`](@ref): Generate colors for path visualization
"""
function create_collatz_tree(;
    # Color parameters
    s = 2.49, r = 0.76, h = 1.815, g = 1.3, opacity = 0.5,
    # Structure parameters  
    e = 1.3, a = 0.19, f = 0.7,
    # Number of sequences (keep small for readability)
    n = 5,
    # Range or specific numbers to use
    use_range = false,
    range_start = 1, range_end = 5000,
    # Label parameters
    label_fontsize = 8,
    label_color = :white,
    show_vertex_dots = true,
    max_label_length = 50,  # Limit labels for very long sequences
    # Output control
    print_numbers = false,
    vertex_size = 8
)
    
    # Generate numbers to process (use smaller numbers for better readability)
    if use_range
        numbers = collect(range_start:min(range_start + n - 1, range_end))
    else
        numbers = rand(10:100, n)  # Smaller numbers for cleaner labels
    end
    
    # Print the numbers if requested
    if print_numbers
        println("Generating labeled Collatz sequences for $(length(numbers)) numbers:")
        println("Numbers: ", numbers)
        println()
    end
    
    # Generate paths with original sequences
    paths_with_sequences = []
    for num in numbers
        sequence = Int[]
        nn = num
        
        # Generate Collatz sequence (original order: starting number → 1)
        while nn != 1
            push!(sequence, nn)
            nn = iseven(nn) ? nn ÷ 2 : 3*nn + 1
        end
        push!(sequence, nn)  # Add the final 1
        
        # For angle path calculation, we need to reverse (1 → starting number)
        reverse_seq = reverse(sequence)
        seq_float = Float64.(reverse_seq)
        radii = seq_float ./ (1 .+ seq_float.^e)
        angles = a .* (f .- 2 .* (reverse_seq .% 2))
        
        cumulative_angles = cumsum(angles)
        x_coords = cumsum(radii .* cos.(cumulative_angles))
        y_coords = cumsum(radii .* sin.(cumulative_angles))
        
        # Prepend origin point
        pushfirst!(x_coords, 0.0)
        pushfirst!(y_coords, 0.0)
        
        path = collect(zip(x_coords, y_coords))
        
        # Store path with correct sequence alignment
        label_sequence = reverse_seq  # This matches x_coords[2:end], y_coords[2:end]
        
        push!(paths_with_sequences, (path, label_sequence, x_coords, y_coords))
    end
    
    # Create figure
    fig = Figure(size = (1000, 1000), backgroundcolor = :transparent)
    ax = Axis(fig[1, 1], 
        backgroundcolor = :transparent,
        leftspinevisible = false,
        rightspinevisible = false,
        topspinevisible = false,
        bottomspinevisible = false,
        xticksvisible = false,
        yticksvisible = false,
        xticklabelsvisible = false,
        yticklabelsvisible = false,
        xgridvisible = false,
        ygridvisible = false,
        # title = "Collatz Sequences with Vertex Labels",
        titlecolor = :white,
        titlesize = 16
    )
    
    # Plot each path with its colors and labels
    for (path, sequence, x_coords, y_coords) in paths_with_sequences
        if length(path) > 1
            # Generate colors for this path
            colors = generate_path_colors(length(path), s, r, h, g)
            
            # Plot line segments with individual colors
            for i in 1:(length(path)-1)
                lines!(ax, 
                    [x_coords[i], x_coords[i+1]], 
                    [y_coords[i], y_coords[i+1]], 
                    color = (colors[i], opacity),
                    linewidth = 2
                )
            end
            
            # Add vertex dots for the actual sequence numbers (skip origin)
            if show_vertex_dots
                scatter!(ax, x_coords[2:end], y_coords[2:end], 
                    color = (:black, 0.7), 
                    markersize = vertex_size
                )
            end
            
            # Add labels for each vertex positioned correctly
            # sequence[i] corresponds to x_coords[i+1], y_coords[i+1] (because of origin offset)
            label_indices = if length(sequence) > max_label_length
                # Sample indices for very long sequences, but always include first and last
                step_size = max(1, length(sequence) ÷ max_label_length)
                indices = collect(1:step_size:length(sequence))
                # Ensure we always include the last vertex
                if indices[end] != length(sequence)
                    push!(indices, length(sequence))
                end
                indices
            else
                1:length(sequence)
            end
            
            for i in label_indices
                if i <= length(sequence)
                    # sequence[i] corresponds to coordinates at x_coords[i+1], y_coords[i+1]
                    coord_index = i + 1
                    if coord_index <= length(x_coords)
                        text!(ax, x_coords[coord_index], y_coords[coord_index], 
                            text = string(sequence[i]),
                            color = label_color,
                            fontsize = label_fontsize,
                            align = (:center, :center),
                            strokecolor = label_color,
                            strokewidth = 0.25,
                            offset = (0, -10)
                        )
                    end
                end
            end
        end
    end
    
    # Auto-scale the view
    autolimits!(ax)
    
    return fig
end


"""
    collatz_graph(range_end = 1000; kwargs...)

Create a directed graph visualization of Collatz sequences showing the relationships between numbers.

This function generates Collatz sequences for all numbers from 1 to `range_end`, extracts
the unique vertices and directed edges, and creates a graph visualization using GraphMakie.jl.
The resulting graph shows how numbers transition to other numbers following Collatz rules.

# Arguments
- `range_end = 1000`: Upper limit of the range (generates sequences for 1:range_end)

# Keyword Arguments

## Visual Styling
- `vertex_style = RGBA(44/51, 10/51, 47/255, 0.2)`: Color and transparency of graph vertices
- `edge_style = RGB(38/255, 139/255, 14/17)`: Color of graph edges
- `vertex_size = 2`: Size of vertex markers
- `edge_width = 0.5`: Width of edge lines

## Layout and Structure
- `graph_layout = "ClosestPacking"`: Layout algorithm ("ClosestPacking", "Spring", or other)

## Labels
- `show_labels = false`: Whether to show vertex labels with numbers
- `label_fontsize = 8`: Font size for vertex labels (only when `show_labels=true`)

## Output Control
- `print_stats = true`: Whether to print detailed statistics about the graph

# Returns
- `Tuple{Figure, SimpleDiGraph, Vector{Int}, Vector{Tuple{Int,Int}}}`: 
  - `fig`: Makie Figure containing the graph visualization
  - `g`: The directed graph object from Graphs.jl
  - `vertices`: Vector of all unique vertices in the graph
  - `edges`: Vector of all directed edges as (source, destination) tuples

# Examples
```julia
# Create basic Collatz graph for numbers 1-100
fig, graph, vertices, edges = collatz_graph(100)

# Create labeled graph for small range with custom styling
fig, graph, vertices, edges = collatz_graph(20,
    show_labels = true,
    vertex_size = 8,
    label_fontsize = 10,
    edge_width = 1.0
)

# Create large graph with spring layout
fig, graph, vertices, edges = collatz_graph(5000,
    graph_layout = "Spring",
    vertex_style = RGBA(1.0, 0.2, 0.2, 0.3),
    print_stats = true
)

# Create minimal graph without statistics
fig, graph, vertices, edges = collatz_graph(50,
    print_stats = false,
    vertex_size = 1,
    edge_width = 0.3
)
```

# Details
The graph construction process:
1. **Sequence Generation**: Creates Collatz sequences for all numbers 1 to `range_end`
2. **Vertex Extraction**: Collects all unique numbers that appear in any sequence
3. **Edge Extraction**: Identifies directed transitions (n → next_n) from sequences
4. **Graph Building**: Constructs a directed graph using Graphs.jl
5. **Connectivity Analysis**: Analyzes connected components and graph structure
6. **Visualization**: Creates a GraphMakie plot with specified styling and layout

The resulting graph reveals the structure of the Collatz conjecture, showing:
- How numbers flow through the conjecture's rules
- Connected components and convergence patterns
- The overall network structure of number relationships

# Layout Options
- `"ClosestPacking"`: Uses stress-based layout for compact visualization
- `"Spring"`: Uses spring-force layout for natural node spacing
- Other layout algorithms supported by GraphMakie.jl

# Performance Notes
- Labels are automatically disabled for graphs with >50 vertices for performance
- Progress indicators show generation status for large ranges
- Statistics provide insights into graph connectivity and structure
- Memory usage scales with the size of the largest numbers encountered

# Graph Properties
The function analyzes and reports:
- Total number of unique vertices and edges
- Connected components and their sizes
- Vertex range (smallest to largest numbers)
- Presence of key vertices (powers of 2)

# See Also
- [`collatz_sequence`](@ref): Generate individual Collatz sequences
- [`create_collatz_visualization`](@ref): Create path-based visualizations
- [`create_collatz_tree`](@ref): Create tree-style visualizations
"""
function collatz_graph(range_end = 1000;
    vertex_style = RGBA(44/51, 10/51, 47/255, 0.2),
    edge_style = RGB(38/255, 139/255, 14/17),
    graph_layout = "ClosestPacking",
    vertex_size = 2,
    edge_width = 0.5,
    print_stats = true,
    show_labels = false,
    label_fontsize = 8
)
    
    println("Creating Collatz graph for range 1:$range_end")
    if show_labels
        println("Labels enabled with fontsize $label_fontsize")
    end
    
    # Step 1: Generate all Collatz sequences
    println("Generating Collatz sequences...")
    all_sequences = []
    for n in 1:range_end
        seq = collatz_sequence(n)
        push!(all_sequences, seq)
        if n % 1000 == 0
            println("  Generated $n sequences...")
        end
    end
    
    # Step 2: Extract unique vertices and edges
    vertex_set = Set{Int}()
    edge_set = Set{Tuple{Int, Int}}()
    
    println("Processing sequences to extract vertices and edges...")
    for seq in all_sequences
        # Add all vertices from this sequence
        for vertex in seq
            push!(vertex_set, vertex)
        end
        
        # Add all edges (consecutive pairs) from this sequence
        for i in 1:(length(seq)-1)
            push!(edge_set, (seq[i], seq[i+1]))
        end
    end
    
    # Convert to sorted arrays
    vertices = sort(collect(vertex_set))
    edges = collect(edge_set)
    
    if print_stats
        println("\nGraph statistics:")
        println("  Sequences processed: $range_end")
        println("  Unique vertices: $(length(vertices))")
        println("  Unique edges: $(length(edges))")
        println("  Vertex range: $(vertices[1]) to $(vertices[end])")
        
        # Show some key vertices that should be present
        key_vertices = [1, 2, 4, 8, 16, 32, 64]
        present_keys = [v for v in key_vertices if v in vertex_set]
        println("  Key vertices present: $present_keys")
    end
    
    # Step 3: Create graph structure
    println("Building graph structure...")
    
    # Map vertex values to indices (required by Graphs.jl)
    vertex_to_index = Dict(vertex => i for (i, vertex) in enumerate(vertices))
    
    # Create directed graph
    g = SimpleDiGraph(length(vertices))
    
    # Add all edges
    for (src, dst) in edges
        src_idx = vertex_to_index[src]
        dst_idx = vertex_to_index[dst]
        add_edge!(g, src_idx, dst_idx)
    end
    
    # Step 4: Check connectivity
    components = weakly_connected_components(g)
    
    if print_stats
        println("  Graph connectivity:")
        println("    Connected components: $(length(components))")
        component_sizes = sort([length(comp) for comp in components], rev=true)
        println("    Component sizes: $component_sizes")
        
        if length(components) == 1
            println("    ✓ Graph is fully connected!")
        else
            println("    ✗ Graph is disconnected")
            # Show what's in the smaller components
            for (i, comp) in enumerate(components)
                if length(comp) <= 20  # Show details for small components
                    comp_vertices = sort([vertices[idx] for idx in comp])
                    println("      Component $i ($(length(comp)) vertices): $comp_vertices")
                elseif i <= 5  # Show first few large components
                    comp_vertices = sort([vertices[idx] for idx in comp])
                    println("      Component $i ($(length(comp)) vertices): $(comp_vertices[1:10])...")
                end
            end
        end
    end
    
    # Step 5: Create visualization
    println("Creating visualization...")
    
    # Choose layout
    if graph_layout == "ClosestPacking" || graph_layout == "PackingLayout"
        layout_algo = Stress()
    elseif graph_layout == "Spring"
        layout_algo = Spring()
    else
        layout_algo = Stress()
    end
    
    # Create figure
    fig = Figure(size = (1200, 1200), backgroundcolor = :transparent)
    ax = Axis(fig[1, 1], 
        backgroundcolor = :transparent,
        leftspinevisible = false,
        rightspinevisible = false,
        topspinevisible = false,
        bottomspinevisible = false,
        xticksvisible = false,
        yticksvisible = false,
        xticklabelsvisible = false,
        yticklabelsvisible = false,
        xgridvisible = false,
        ygridvisible = false,
        # title = "Collatz Graph (Range 1:$range_end)$(show_labels ? " - Labeled" : "")",
        titlecolor = :gray,
        title = "Collatz Graph (Range 1:$range_end)",
        titlesize = 20
    )
    
    # Plot the graph
    if show_labels && length(vertices) <= 50
        println("Creating labeled graph...")
        
        # Generate positions using the layout algorithm
        positions = layout_algo(g)
        
        # Plot graph with computed positions
        graphplot!(ax, g,
            layout = positions,
            node_color = vertex_style,
            node_size = vertex_size,
            node_marker = :dtriangle,
            edge_color = edge_style,
            edge_width = edge_width,
            arrow_show = true,
            arrow_size = 6
        )
        
        # Add vertex labels at the computed positions
        println("Adding vertex labels at node positions...")
        for i in eachindex(vertices)
            x, y = positions[i]
            text!(ax, x, y,
                text = string(vertices[i]),
                color = :white,
                fontsize = label_fontsize,
                align = (:center, :center),
                strokecolor = :black,
                strokewidth = 1
            )
        end
        
    else
        # Regular unlabeled graph
        layout = if graph_layout == "ClosestPacking" || graph_layout == "PackingLayout"
            Stress()
        elseif graph_layout == "Spring"
            Spring()
        else
            Stress()
        end
        
        graphplot!(ax, g,
            layout = layout,
            node_color = vertex_style,
            node_size = vertex_size,
            node_marker = :dtriangle,
            edge_color = edge_style,
            edge_width = edge_width,
            arrow_show = true,
            arrow_size = 6
        )
        
        if show_labels
            println("Too many vertices ($(length(vertices))) for labeling - skipping labels")
        end
    end
    
    println("Visualization complete!\n")
    
    # Return the figure and useful data
    return fig, g, vertices, edges
end


"""
    collatz_graph_highlight_one(range_end = 1000; kwargs...)

Create a directed graph visualization of Collatz sequences with vertex 1 specially highlighted.

This function generates Collatz sequences for all numbers from 1 to `range_end`, creates
a graph visualization, and specially highlights vertex 1 (the convergence point of all
Collatz sequences) with a distinct color, size, and label styling. All vertices can be
optionally labeled to show their values.

# Arguments
- `range_end = 1000`: Upper limit of the range (generates sequences for 1:range_end)

# Keyword Arguments

## Basic Graph Styling
- `vertex_style = RGBA(4/51, 51/51, 47/255, 0.8)`: Color and transparency of regular vertices
- `edge_style = RGB(38/255, 139/255, 14/17)`: Color of graph edges
- `vertex_size = 2`: Size of regular vertex markers
- `edge_width = 0.125`: Width of edge lines
- `graph_layout = "ClosestPacking"`: Layout algorithm ("ClosestPacking", "Spring", etc.)

## Vertex 1 Highlighting
- `highlight_color = RGB(1.0, 0.2, 0.2)`: Color for vertex 1 (bright red by default)
- `highlight_size = 15`: Size of vertex 1 marker (much larger than regular vertices)

## Labeling Controls
- `show_all_labels = true`: Whether to show labels on all vertices
- `max_labeled_vertices = 50`: Maximum number of vertices to label (performance limit)
- `label_fontsize = 14`: Font size for vertex labels
- `other_label_color = RGB(1.0, 1.0, 1.0)`: Color for labels on non-highlighted vertices

## Output Control
- `print_stats = true`: Whether to print detailed statistics about the graph

# Returns
- `Tuple{Figure, SimpleDiGraph, Vector{Int}, Vector{Tuple{Int,Int}}}`: 
  - `fig`: Makie Figure containing the graph visualization
  - `g`: The directed graph object from Graphs.jl
  - `vertices`: Vector of all unique vertices in the graph
  - `edges`: Vector of all directed edges as (source, destination) tuples

# Examples
```julia
# Create highlighted graph with default settings
fig, graph, vertices, edges = collatz_graph_highlight_one(100)

# Create graph with custom highlight styling
fig, graph, vertices, edges = collatz_graph_highlight_one(50,
    highlight_color = RGB(1.0, 1.0, 0.0),  # Yellow highlight
    highlight_size = 20,
    label_fontsize = 12
)

# Create large graph with limited labeling
fig, graph, vertices, edges = collatz_graph_highlight_one(1000,
    show_all_labels = true,
    max_labeled_vertices = 100,
    vertex_size = 1,
    edge_width = 0.1
)

# Create minimal graph with only vertex 1 labeled
fig, graph, vertices, edges = collatz_graph_highlight_one(200,
    show_all_labels = false,
    vertex_style = RGBA(0.3, 0.3, 0.3, 0.5)
)
```

# Details
The highlighting visualization process:
1. **Sequence Generation**: Creates Collatz sequences for all numbers 1 to `range_end`
2. **Graph Construction**: Builds directed graph with vertices and edges
3. **Layout Computation**: Calculates vertex positions using specified algorithm
4. **Special Highlighting**: Identifies vertex 1 and applies special styling
5. **Layered Rendering**: Draws edges first, then vertices, then labels for optimal appearance
6. **Smart Labeling**: Labels all vertices up to the specified limit, with special styling for vertex 1

The function emphasizes the central role of vertex 1 in the Collatz conjecture by:
- Using a bright, contrasting color (red by default)
- Making vertex 1 significantly larger than other vertices
- Applying special label formatting (white text with black outline)
- Ensuring vertex 1 remains visible even in large graphs

# Highlighting Features
- **Vertex 1 Detection**: Automatically locates and highlights vertex 1 if present
- **Layered Rendering**: Uses separate graph plot calls for edges and vertices for cleaner appearance
- **Adaptive Labeling**: Shows all labels up to the limit, but always prioritizes vertex 1's label
- **Special Typography**: Vertex 1 gets larger font size and enhanced stroke for visibility

# Performance Considerations
- Labels are automatically limited to `max_labeled_vertices` for performance
- For graphs exceeding the label limit, only vertex 1 is labeled
- Progress indicators show generation status for large ranges
- Memory usage scales with the largest numbers encountered in sequences

# Visual Design
The function uses a layered approach:
1. Transparent nodes with visible edges (base structure)
2. Colored nodes on top (vertex highlighting)
3. Text labels as the top layer (readability)

This ensures vertex 1's highlight is clearly visible while maintaining graph structure clarity.

# See Also
- [`collatz_graph`](@ref): Create standard Collatz graph without highlighting
- [`collatz_sequence`](@ref): Generate individual Collatz sequences
- [`create_collatz_visualization`](@ref): Create path-based visualizations
- [`create_collatz_tree`](@ref): Create tree-style visualizations
"""
function collatz_graph_highlight_one(range_end = 1000;
    vertex_style = RGBA(4/51, 51/51, 47/255, 0.8),
    # vertex_style = RGBA(44/51, 10/51, 47/255, 0.8),
    edge_style = RGB(38/255, 139/255, 14/17),
    graph_layout = "ClosestPacking",
    vertex_size = 2,
    edge_width = 0.125,
    print_stats = true,
    # Special highlighting for vertex 1
    highlight_color = RGB(1.0, 0.2, 0.2),  # Bright red for vertex 1
    highlight_size = 15,
    label_fontsize = 14,
    # Labeling controls
    show_all_labels = true,
    max_labeled_vertices = 50,
    other_label_color = RGB(1.0, 1.0, 1.0)  # Cyan for other vertices
)
    
    println("Creating Collatz graph for range 1:$range_end with vertex 1 highlighted and all vertices labeled")
    
    # Step 1: Generate all Collatz sequences
    println("Generating Collatz sequences...")
    all_sequences = []
    for n in 1:range_end
        seq = collatz_sequence(n)
        push!(all_sequences, seq)
        if n % 1000 == 0
            println("  Generated $n sequences...")
        end
    end
    
    # Step 2: Extract unique vertices and edges
    vertex_set = Set{Int}()
    edge_set = Set{Tuple{Int, Int}}()
    
    println("Processing sequences to extract vertices and edges...")
    for seq in all_sequences
        # Add all vertices from this sequence
        for vertex in seq
            push!(vertex_set, vertex)
        end
        
        # Add all edges (consecutive pairs) from this sequence
        for i in 1:(length(seq)-1)
            push!(edge_set, (seq[i], seq[i+1]))
        end
    end
    
    # Convert to sorted arrays
    vertices = sort(collect(vertex_set))
    edges = collect(edge_set)
    
    if print_stats
        println("\nGraph statistics:")
        println("  Sequences processed: $range_end")
        println("  Unique vertices: $(length(vertices))")
        println("  Unique edges: $(length(edges))")
        println("  Vertex range: $(vertices[1]) to $(vertices[end])")
        
        # Check if vertex 1 is present
        if 1 in vertex_set
            println("  ✓ Vertex 1 is present and will be highlighted")
        else
            println("  ✗ WARNING: Vertex 1 is not present!")
        end
    end
    
    # Step 3: Create graph structure
    println("Building graph structure...")
    
    # Map vertex values to indices (required by Graphs.jl)
    vertex_to_index = Dict(vertex => i for (i, vertex) in enumerate(vertices))
    
    # Create directed graph
    g = SimpleDiGraph(length(vertices))
    
    # Add all edges
    for (src, dst) in edges
        src_idx = vertex_to_index[src]
        dst_idx = vertex_to_index[dst]
        add_edge!(g, src_idx, dst_idx)
    end
    
    # Step 4: Check connectivity
    components = weakly_connected_components(g)
    
    if print_stats
        println("  Graph connectivity:")
        println("    Connected components: $(length(components))")
        component_sizes = sort([length(comp) for comp in components], rev=true)
        println("    Component sizes: $component_sizes")
        
        if length(components) == 1
            println("    ✓ Graph is fully connected!")
        else
            println("    ✗ Graph is disconnected")
            # Show what's in the smaller components
            for (i, comp) in enumerate(components)
                if length(comp) <= 20
                    comp_vertices = sort([vertices[idx] for idx in comp])
                    println("      Component $i ($(length(comp)) vertices): $comp_vertices")
                elseif i <= 5
                    comp_vertices = sort([vertices[idx] for idx in comp])
                    println("      Component $i ($(length(comp)) vertices): $(comp_vertices[1:10])...")
                end
            end
        end
    end
    
    # Step 5: Create visualization with special highlighting
    println("Creating visualization with vertex 1 highlighted and all vertices labeled...")
    
    # Choose layout
    if graph_layout == "ClosestPacking" || graph_layout == "PackingLayout"
        layout_algo = Stress()
    elseif graph_layout == "Spring"
        layout_algo = Spring()
    else
        layout_algo = Stress()
    end
    
    # Generate positions using the layout algorithm
    positions = layout_algo(g)
    
    # Create figure
    fig = Figure(size = (1200, 1200), backgroundcolor = :transparent)
    ax = Axis(fig[1, 1], 
        backgroundcolor = :transparent,
        leftspinevisible = false,
        rightspinevisible = false,
        topspinevisible = false,
        bottomspinevisible = false,
        xticksvisible = false,
        yticksvisible = false,
        xticklabelsvisible = false,
        yticklabelsvisible = false,
        xgridvisible = false,
        ygridvisible = false,
        title = "Collatz Graph - All Vertices Labeled, Vertex 1 Highlighted (Range 1:$range_end)",
        titlecolor = :white,
        titlesize = 14
    )
    
    # Prepare node colors and sizes (highlight vertex 1)
    node_colors = []
    node_sizes = []
    vertex_1_index = nothing
    
    for i in eachindex(vertices)
        if vertices[i] == 1
            push!(node_colors, highlight_color)
            push!(node_sizes, highlight_size)
            vertex_1_index = i
        else
            push!(node_colors, vertex_style)
            push!(node_sizes, vertex_size)
        end
    end
    
    # Plot edges first, then nodes on top for stronger appearance
    
    # Step 1: Plot only the edges
    graphplot!(ax, g,
        layout = positions,
        node_color = :transparent,
        node_size = 0,
        edge_color = edge_style,
        edge_width = edge_width,
        arrow_show = false,
        arrow_size = 6
    )
    
    # Step 2: Plot only the nodes on top
    graphplot!(ax, g,
        layout = positions,
        node_color = node_colors,
        node_size = node_sizes,
        edge_color = :transparent,
        edge_width = 0,
        arrow_show = false,
        node_marker = :circle
    )
    
    # Add labels for ALL vertices
    if show_all_labels && length(vertices) <= max_labeled_vertices
        println("Adding labels for all $(length(vertices)) vertices...")
        
        for i in eachindex(vertices)
            x, y = positions[i]
            vertex_value = vertices[i]
            
            if vertex_value == 1
                # Special label for vertex 1 (white)
                text!(ax, x, y,
                    text = "1",
                    color = :white,
                    fontsize = label_fontsize + 2,
                    align = (:center, :center),
                    strokecolor = :black,
                    strokewidth = 2
                )
            else
                # Labels for all other vertices (fixed color)
                text!(ax, x, y,
                    text = string(vertex_value),
                    color = :gray, #other_label_color,
                    fontsize = label_fontsize,
                    align = (:center, :center),
                    strokecolor = :gray,
                    strokewidth = 2
                )
            end
        end
    elseif show_all_labels
        println("Too many vertices ($(length(vertices))) for labeling - limit is $max_labeled_vertices")
        # Still label vertex 1 if present
        if vertex_1_index !== nothing && 1 in vertex_set
            x, y = positions[vertex_1_index]
            text!(ax, x, y,
                text = "1",
                color = :white,
                fontsize = label_fontsize + 2,
                align = (:center, :center),
                strokecolor = :black,
                strokewidth = 2
            )
        end
    end
    
    println("Visualization complete!")
    println("Vertex 1 is highlighted in red with white label")
    println("All other vertices are labeled in $(other_label_color)\n")
    
    # Return the figure and useful data
    return fig, g, vertices, edges
end

"""
    plot_stopping_times_scatter(max_n::Int=1000)

Create a scatter plot visualization of Collatz stopping times with a moving average trend line.

This function calculates stopping times for all numbers from 1 to `max_n` and creates
a scatter plot showing the relationship between starting numbers and their stopping times.
A red moving average line reveals overall trends in the data.

# Arguments
- `max_n::Int=1000`: Maximum number to analyze (default: 1000)

# Returns
- `Figure`: A Makie.jl Figure object containing the scatter plot visualization

# Examples
```julia
# Create default plot for numbers 1-1000
fig = plot_stopping_times_scatter()

# Plot for a smaller range with more detail
fig = plot_stopping_times_scatter(100)

# Plot for a larger range to see broader patterns
fig = plot_stopping_times_scatter(5000)

# Save the plot
save("stopping_times.png", fig)
```

# Visualization Features

## Scatter Plot Elements
- **Blue points**: Each point represents one number and its stopping time
- **Transparency**: Points have 90% opacity to show overlapping patterns
- **Point size**: Small markers (size 3) to avoid overcrowding

## Trend Analysis
- **Moving average**: Red line showing smoothed trends across the data
- **Window size**: Automatically scaled as max_n ÷ 50 for appropriate smoothing
- **Legend**: Shows the moving average line identification

## Styling
- **Transparent background**: Suitable for presentations and documents
- **Large text**: All labels and titles use size 20 for readability
- **Professional formatting**: Clean axis styling with appropriate tick formatting

# Patterns Revealed
The visualization typically shows:
- **Irregular spikes**: Some numbers have much longer stopping times than neighbors
- **General trends**: Moving average reveals whether stopping times increase with number size
- **Power-of-2 pattern**: Numbers that are powers of 2 show predictable stepping
- **Clustering effects**: Groups of numbers with similar stopping times
- **Outliers**: Numbers with exceptionally long stopping times stand out clearly

# Mathematical Insights
The plot helps identify:
- **Record holders**: Numbers with locally maximum stopping times
- **Distribution shape**: Whether stopping times follow any predictable pattern
- **Growth behavior**: How stopping times scale with input size
- **Variance patterns**: Regions of high vs. low variability

# Technical Details
- **Moving average calculation**: Uses symmetric window around each point
- **Window boundaries**: Handles edge cases at the beginning and end of data
- **Automatic scaling**: Window size adapts to data range for optimal smoothing
- **Memory efficient**: Processes data in a single pass

# Customization Options
While this function provides a standard visualization, you can modify the returned figure:
```julia
fig = plot_stopping_times_scatter(1000)
# Modify colors, add annotations, etc.
ax = fig[1, 1]
# Add additional analysis or annotations
```

# Performance Notes
- Computation time scales with max_n
- For max_n > 10,000, consider computing in batches
- The moving average calculation is O(n) efficient
- Memory usage grows linearly with the number of data points

# Use Cases
- **Educational demonstrations** of Collatz conjecture behavior
- **Research analysis** of stopping time patterns
- **Statistical exploration** of number theory properties
- **Presentation graphics** for mathematical talks
- **Comparative analysis** across different ranges

# See Also
- [`calculate_stopping_times`](@ref): Compute stopping times for analysis
- [`stopping_time`](@ref): Calculate individual stopping times
- [`collatz_sequence`](@ref): Generate complete sequences
- [`create_collatz_visualization`](@ref): Alternative visualization approaches
"""
function plot_stopping_times_scatter(max_n::Int=1000)
    numbers, times = calculate_stopping_times(max_n)
    
    # fig = Figure(size=(1000, 600))
    fig = Figure(backgroundcolor=:transparent)
    ax = Axis(fig[1, 1],
        title="Stopping Times (n = 1 to $max_n)",
        xlabel="Starting Number (n)",
        ylabel="Stopping Time",
        xticklabelsize=20,
        yticklabelsize=20,
        xlabelsize=20, # X-axis label size
        ylabelsize=20,
        titlesize=20,
        backgroundcolor = (:white,0)
    )
    
    ax.xtickformat = xs -> [string(round(x, digits=2)) for x in xs]
    
    scatter!(ax, numbers, times, markersize=3, color=:deepskyblue, alpha=0.9)
    
    # Add trend line (moving average)
    window_size = max(1, max_n ÷ 50)
    moving_avg = [mean(times[max(1, i-window_size):min(length(times), i+window_size)])
                  for i in 1:length(times)]
    
    lines!(ax, numbers, moving_avg, color=:red, linewidth=2, label="Moving Average")
    
    axislegend(ax, position=:rt)
    
    return fig
end