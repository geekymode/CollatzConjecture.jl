# using CairoMakie, Colors,FileIO

# Method 1: Direct function approach (simplest)
function plot_collatz_fractal_interactive(collatz_function::Function,
                                        x_range::Tuple{Float64, Float64},
                                        y_range::Tuple{Float64, Float64};
                                        title::String="Complex Collatz Julia Set",
                                        colormap=:viridis,
                                        alpha::Float64=0.99)
    
    # Create the function that InteractiveViz can call
    # Note: iheatmap expects function(x, y) that returns a scalar
    collatz_heatmap_func(x, y) = Float64(collatz_function(complex(x, y)))
    
    # Create interactive heatmap
    p = iheatmap(collatz_heatmap_func, 
                x_range[1], x_range[2], 
                y_range[1], y_range[2];
                colormap=colormap,
                alpha=alpha,
                overlay=true,
                axescolor=:white,
                cursor=true)
    
    return p
end


"""
The true complex Collatz map using the analytic continuation:
T(z) = (1/4) * (2 + 7z - (2 + 5z) * cos(π*z))

This is the proper analytic continuation of the Collatz function to the complex plane.
"""
function complex_collatz(z::ComplexF64)
    return 0.25 * (2 + 7*z - (2 + 5*z) * cos(π * z))
end

# 11. Möbius transformation based
# function mobius_collatz(z::ComplexF64)
    function mobius_collatz(z::ComplexF64)
    return (5*z + 1)/(2*z + 1) * (0.5 + 0.5 * cos(π * z)) + 
           z/2 * (0.5 - 0.5 * cos(π * z))
end

"""
Alternative formulation using the Riemann sphere approach:
T(z) = (1/2) * (z + 1 + (z - 1) * cos(π*z))
"""
function complex_collatz_alt(z::ComplexF64)
    return 0.5 * (z + 1 + (z - 1) * cos(π * z))
end

"""
Another common complex Collatz formulation:
T(z) = z/2 + (3z + 1)/4 * (1 - cos(π*z))
"""
function complex_collatz_hybrid(z::ComplexF64)
    return z/2 + (3*z + 1)/4 * (1 - cos(π * z))
end


"""
Generate the complex Collatz Julia set
"""
function generate_complex_collatz_julia(width::Int, height::Int, 
                                       x_range::Tuple{Float64, Float64}, 
                                       y_range::Tuple{Float64, Float64},
                                       map_function,
                                       max_iter::Int=100)
    
    julia_set = zeros(Int, height, width)
    
    x_step = (x_range[2] - x_range[1]) / width
    y_step = (y_range[2] - y_range[1]) / height
    
    println("Computing Julia set...")
    Threads.@threads for i in 1:height
        if i % 50 == 0
            println("Row $i/$height")
        end
        for j in 1:width
            x = x_range[1] + (j - 1) * x_step
            y = y_range[1] + (i - 1) * y_step
            z = ComplexF64(x, y)
            
            current_z = z
            iterations = 0
            escaped = false
			value = 0;
			value2 = 0;
			value3 = 0
            escape_color = 0
            
            for iter in 1:max_iter
                try
                    current_z = map_function(current_z)
                    iterations = iter
					value3 = iter
                    # escape_color = 0
                    # value2 = iter
                    # Check for escape
                    if abs(current_z) > 10000.0 || !isfinite(current_z)
                        escaped = true
						value = max_iter + 1
						value2 = 0;
						value3 = 1;
                        escape_color = iter
                        break
                    end
                    
                    # Check for convergence
                    if abs(current_z - 1.5) < 1e-6 || abs(current_z - 2) < 1e-6
                        iterations = max_iter + 1
						value = iter
						value2 = max_iter + 1
						value2 = iter
                        escape_color = iter # max_iter + 1
						value3 = iter # max_iter + 1
                        break
                    end
                catch
                    iterations = 1
                    escaped = true
					value3 = max_iter + 1
                    break
                end
            end
            
            # julia_set[i, j] = iterations
            julia_set[i, j] = escape_color
			# julia_set[i, j] = value
			# julia_set[i, j] = value3
			# julia_set[i, j] = ceil(log10(1.0 + value3))
        end
    end
    
    return julia_set
end

"""
Create enhanced colormap for the complex Collatz Julia set
"""
function create_complex_collatz_colormap()
    # Create a more sophisticated colormap
    n_colors = 256
    colors = Vector{RGB}(undef, n_colors)
    
    for i in 1:n_colors
        t = (i - 1) / (n_colors - 1)
        
        if t < 0.1
            # Black to dark blue for quick escape
            colors[i] = RGB(0, 0, t * 10)
        elseif t < 0.3
            # Dark blue to blue
            s = (t - 0.1) / 0.2
            colors[i] = RGB(0, s * 0.5, 1)
        elseif t < 0.5
            # Blue to cyan
            s = (t - 0.3) / 0.2
            colors[i] = RGB(0, 0.5 + s * 0.5, 1)
        elseif t < 0.7
            # Cyan to green
            s = (t - 0.5) / 0.2
            colors[i] = RGB(s * 0.5, 1, 1 - s * 0.5)
        elseif t < 0.85
            # Green to yellow
            s = (t - 0.7) / 0.15
            colors[i] = RGB(0.5 + s * 0.5, 1, 0.5 - s * 0.5)
        elseif t < 0.95
            # Yellow to red
            s = (t - 0.85) / 0.1
            colors[i] = RGB(1, 1 - s, 0)
        else
            # Red to white for convergent points
            s = (t - 0.95) / 0.05
            colors[i] = RGB(1, s, s)
        end
    end
    
    return colors
end

"""
Unified plotting function for Complex Collatz Julia sets
"""
function plot_collatz_fractal(julia_data::Matrix{Int}, 
                           x_range::Tuple{Float64, Float64}, 
                           y_range::Tuple{Float64, Float64},
                           title::String="Complex Collatz Julia Set",
                           subtitle::String="",
                           filename::String="collatz_julia.png",
                           fig_size::Tuple{Int, Int}=(1000, 800))
    
    # Create figure
    fig = Figure(size=fig_size,backgroundcolor=:transparent)
    
    # Custom colormap
    cmap = create_complex_collatz_colormap()
	cmap = :viridis
    
    # Create main axis
    ax = Axis(fig[1, 1], 
            #   title=isempty(subtitle) ? title : "$title\n$subtitle",
            #   xlabel="Real axis",
            #   ylabel="Imaginary axis",
            aspect=AxisAspect(3/4),
            xticksvisible = false,    # Hide tick marks
           xticklabelsvisible = false, # Hide tick labels
           yticksvisible = false,    # Hide tick marks
           yticklabelsvisible = false, # Hide tick labels
              titlesize=16)
    
    # Create the heatmap
    width, height = size(julia_data, 2), size(julia_data, 1)
    hm = heatmap!(ax,
        range(y_range[1], y_range[2], length=height),
        range(x_range[1], x_range[2], length=width),
        julia_data',
        colormap=cmap,
        alpha=0.99)
    
    # Add colorbar
    # Colorbar(fig[1, 2], hm, 
    #          label="Iterations to escape/converge",
    #          labelsize=12)
    
    # Set aspect ratio and grid
    ax.aspect = DataAspect()
    ax.xgridvisible = true
    ax.ygridvisible = true
    ax.xgridwidth = 0.5
    ax.ygridwidth = 0.5
    ax.xgridcolor = :gray
    ax.ygridcolor = :gray
    
    # Display and save
    display(fig)
    try
        save(filename, fig, px_per_unit=2)
        println("Saved: $filename")
    catch e
        # Fallback: save as PNG explicitly
        png_filename = replace(filename, r"\.[^.]*$" => ".png")
        CairoMakie.save(png_filename, fig, px_per_unit=2)
        println("Saved as PNG: $png_filename")
    end
    
    return fig
end

"""
Unified plotting function for Complex Collatz Julia sets
"""
function plot_collatz_julia(julia_data::Matrix{Int}, 
                           x_range::Tuple{Float64, Float64}, 
                           y_range::Tuple{Float64, Float64},
                           title::String="Complex Collatz Julia Set",
                           subtitle::String="",
                           filename::String="collatz_julia.png",
                           fig_size::Tuple{Int, Int}=(1000, 800))
    
    # Create figure
    fig = Figure(size=fig_size,backgroundcolor =:transparent)
    
    # Custom colormap
    cmap = create_complex_collatz_colormap()
	cmap = :viridis
    
    # Create main axis
    ax = Axis(fig[1, 1], 
              title=isempty(subtitle) ? title : "$title\n$subtitle",
              xlabel="Real axis",
              ylabel="Imaginary axis",
              titlesize=16)
    
    # Create the heatmap
    width, height = size(julia_data, 2), size(julia_data, 1)
    hm = heatmap!(ax, 
                  range(x_range[1], x_range[2], length=width),
                  range(y_range[1], y_range[2], length=height),
                  julia_data,
                  colormap=cmap,
                  alpha=0.99)
    
    # Add colorbar
    Colorbar(fig[1, 2], hm, 
             label="Iterations to escape/converge",
             labelsize=12)
    
    # Set aspect ratio and grid
    ax.aspect = DataAspect()
    ax.xgridvisible = true
    ax.ygridvisible = true
    ax.xgridwidth = 0.5
    ax.ygridwidth = 0.5
    ax.xgridcolor = :gray
    ax.ygridcolor = :gray
    
    # Display and save
    display(fig)
    try
        save(filename, fig, px_per_unit=2)
        println("Saved: $filename")
    catch e
        # Fallback: save as PNG explicitly
        png_filename = replace(filename, r"\.[^.]*$" => ".png")
        CairoMakie.save(png_filename, fig, px_per_unit=2)
        println("Saved as PNG: $png_filename")
    end
    
    return fig
end

"""
Zoom into a specific region of the Complex Collatz fractal

Parameters:
- center_x, center_y: Complex coordinates for the center of the zoom
- zoom_width, zoom_height: Width and height of the viewing window
- resolution: Image resolution (e.g., 800 = 800×800 pixels)
- max_iter: Maximum iterations for computation detail
- map_func: Which Collatz function to use (default: complex_collatz)
- title_suffix: Additional text for the plot title

Returns:
- fig: The generated figure
- julia_data: The computed fractal data matrix
"""
function plot_collatz_zoom(center_x::Float64, center_y::Float64, 
                          zoom_width::Float64, zoom_height::Float64,
                          resolution::Int=800, max_iter::Int=200,
                          map_func=complex_collatz,
                          title_suffix::String="")
    
    # Calculate the zoom window boundaries
    x_range = (center_x - zoom_width/2, center_x + zoom_width/2)
    y_range = (center_y - zoom_height/2, center_y + zoom_height/2)
    
    # Print computation info
    println("Generating zoomed fractal:")
    println("  Center: ($(center_x), $(center_y))")
    println("  Window: $(zoom_width) × $(zoom_height)")
    println("  Resolution: $(resolution)×$(resolution)")
    println("  Max iterations: $(max_iter)")
    
    # Generate the zoomed fractal data
    julia_data = generate_complex_collatz_julia(resolution, resolution, 
                                              x_range, y_range, 
                                              map_func, max_iter)
    
    # Create safe filename - ensure .png extension
    base_name = "collatz_zoom_$(center_x)_$(center_y)_$(zoom_width)"
    base_name = replace(base_name, "." => "p")
    base_name = replace(base_name, "-" => "neg")
    filename = base_name * ".png"  # Explicitly add .png extension
    
    # Create descriptive title
    # zoom_title = "Complex Collatz Fractal - Zoom View$title_suffix"
    zoom_title = "$(title_suffix)"
    zoom_subtitle = "Center: ($(center_x), $(center_y)), Window: $(zoom_width)×$(zoom_height)"
    
    # Plot using the existing plotting function
    fig = plot_collatz_julia(julia_data, x_range, y_range, 
                            zoom_title, zoom_subtitle, filename, (1000, 1000))
    
    return fig, julia_data
end

function plot_collatz_zoom_grid_old(center_x_vec::Vector{Float64}, center_y_vec::Vector{Float64},
                               zoom_width::Float64, zoom_height::Float64,
                               resolution::Int=400, max_iter::Int=200,
                               map_func=complex_collatz,
                               main_title::String="Complex Collatz Fractal - 3x3 Zoom Grid",
                               figsize::Tuple{Int,Int}=(1200, 1200))
    
    # Validate input
    if length(center_x_vec) != 9 || length(center_y_vec) != 9
        error("Need exactly 9 center points for 3x3 grid")
    end
    
    # Create figure with 3x3 layout
    fig = Figure(resolution=figsize,backgroundcolor =:transparent)
    
    # Store all the data for potential return
    all_data = Vector{Any}(undef, 9)
    
    println("Generating 3x3 zoomed fractal grid:")
    println(" Window size: $(zoom_width) × $(zoom_height)")
    println(" Resolution per subplot: $(resolution)×$(resolution)")
    println(" Max iterations: $(max_iter)")
    
    # Create subplots in 3x3 grid
    for row in 1:3
        for col in 1:3
            i = (row-1)*3 + col
            center_x = center_x_vec[i]
            center_y = center_y_vec[i]
            
            # Calculate zoom window boundaries
            x_range = (center_x - zoom_width/2, center_x + zoom_width/2)
            y_range = (center_y - zoom_height/2, center_y + zoom_height/2)
            
            println(" Subplot $i: Center ($(center_x), $(center_y))")
            
            # Generate fractal data for this subplot
            julia_data = generate_complex_collatz_julia(resolution, resolution,
                                                       x_range, y_range,
                                                       map_func, max_iter)
            
            all_data[i] = julia_data
            
            # Create axis for this subplot
            ax = Axis(fig[row, col], 
                     title="($(center_x), $(center_y))",
                     titlesize=12,
                     aspect=1)
            
            # Create heatmap
            x_vals = range(x_range[1], x_range[2], length=resolution)
            y_vals = range(y_range[1], y_range[2], length=resolution)
            
            heatmap!(ax, x_vals, y_vals, julia_data)
        end
    end
    
    # Add main title to the figure
    Label(fig[0, :], main_title, fontsize=16, font="bold")
    
    # Add a colorbar
    Colorbar(fig[:, 4], limits=(0, max_iter), label="Iterations")
    
    return fig, all_data
end

function generate_grid_centers(main_center_x::Float64, main_center_y::Float64, 
                              spacing::Float64)
    centers_x = Float64[]
    centers_y = Float64[]
    
    for row in -1:1
        for col in -1:1
            push!(centers_x, main_center_x + col * spacing)
            push!(centers_y, main_center_y + 0*row * spacing)
        end
    end
    
    return centers_x, centers_y
end

function plot_collatz_zoom_grid(center_x_vec::Vector{Float64}, center_y_vec::Vector{Float64},
                               zoom_width_vec::Union{Float64, Vector{Float64}}, 
                               zoom_height_vec::Union{Float64, Vector{Float64}},
                               resolution::Int=400, max_iter_vec::Vector{Int}=[200],
                               map_func=complex_collatz,
                               main_title::String="",
                               figsize::Tuple{Int,Int}=(1200, 1200))
    
    # Validate input
    if length(center_x_vec) != 9 || length(center_y_vec) != 9
        error("Need exactly 9 center points for 3x3 grid")
    end
    
    # Handle zoom_width_vec - convert to vector and validate
    if isa(zoom_width_vec, Float64)
        zoom_width_vec = fill(zoom_width_vec, 9)
    elseif length(zoom_width_vec) != 9
        error("zoom_width_vec must be a single Float64 or Vector{Float64} of length 9, got length $(length(zoom_width_vec))")
    end
    
    # Handle zoom_height_vec - convert to vector and validate
    if isa(zoom_height_vec, Float64)
        zoom_height_vec = fill(zoom_height_vec, 9)
    elseif length(zoom_height_vec) != 9
        error("zoom_height_vec must be a single Float64 or Vector{Float64} of length 9, got length $(length(zoom_height_vec))")
    end
    
    # Handle max_iter_vec - if single value, repeat for all 9 subplots
    if length(max_iter_vec) == 1
        max_iter_vec = fill(max_iter_vec[1], 9)
    elseif length(max_iter_vec) != 9
        error("max_iter_vec must have length 1 or 9, got $(length(max_iter_vec))")
    end
    
    # Create figure with 3x3 layout
    fig = Figure(resolution=figsize,backgroundcolor =:transparent)
    
    # Store all the data for potential return
    all_data = Vector{Any}(undef, 9)
    
    println("Generating 3x3 zoomed fractal grid:")
    println(" Zoom widths: $(zoom_width_vec)")
    println(" Zoom heights: $(zoom_height_vec)")
    println(" Resolution per subplot: $(resolution)×$(resolution)")
    println(" Max iterations per subplot: $(max_iter_vec)")
    
    # Find global min/max iterations for consistent colorbar
    global_min_iter = minimum(max_iter_vec)
    global_max_iter = maximum(max_iter_vec)
    
    # Create subplots in 3x3 grid
    for row in 1:3
        for col in 1:3
            i = (row-1)*3 + col
            center_x = center_x_vec[i]
            center_y = center_y_vec[i]
            zoom_width = zoom_width_vec[i]
            zoom_height = zoom_height_vec[i]
            max_iter = max_iter_vec[i]
            
            # Calculate zoom window boundaries
            x_range = (center_x - zoom_width/2, center_x + zoom_width/2)
            y_range = (center_y - zoom_height/2, center_y + zoom_height/2)
            
            println(" Subplot $i: Center ($(center_x), $(center_y)), Window: $(zoom_width)×$(zoom_height), Max iter: $(max_iter)")
            
            # Generate fractal data for this subplot
            julia_data = generate_complex_collatz_julia(resolution, resolution,
                                                       x_range, y_range,
                                                       map_func, max_iter)
            
            all_data[i] = julia_data
            
            # Create axis for this subplot
            ax = Axis(fig[row, col], 
            title = "z=($(center_x)+ $(center_y) im),max_iter=$(max_iter),stop_time($(real(center_x)))=$(collatz_length(real(center_x)))",
                    #  title="($(center_x), $(center_y))\n$(zoom_width)×$(zoom_height), iter: $(max_iter)",
                     titlesize=9,
                     aspect=1)
            
            # Create heatmap
            x_vals = range(x_range[1], x_range[2], length=resolution)
            y_vals = range(y_range[1], y_range[2], length=resolution)
            
            # Use consistent color limits across all subplots
            heatmap!(ax, x_vals, y_vals, julia_data, 
                    colorrange=(0, global_max_iter))
        end
    end
    
    # Add main title to the figure
    Label(fig[0, :], main_title, fontsize=16, font="bold")
    
    # Add a colorbar with global range
    Colorbar(fig[:, 4], limits=(0, global_max_iter), label="Iterations")
    
    return fig, all_data
end

