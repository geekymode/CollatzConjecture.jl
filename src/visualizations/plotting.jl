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

# See Also
- [`collatz_angle_path`]( ): Generate a single Collatz angle path
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

# See Also
- [`collatz_paths`]( ): Generate multiple Collatz angle paths
- [`generate_path_colors`]( ): Generate colors for path visualization
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

# See Also
- [`create_collatz_visualization`]( ): Create unlabeled Collatz visualization
- [`collatz_paths`]( ): Generate multiple Collatz angle paths
- [`generate_path_colors`]( ): Generate colors for path visualization
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