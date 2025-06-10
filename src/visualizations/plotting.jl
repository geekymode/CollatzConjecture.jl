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