module CollatzConjecture

# Write your package code here.
# Export the main function so users can access it directly
export collatz_sequence

"""
    collatz_sequence(n::Integer) -> Vector{Int}

Generate the complete Collatz sequence starting from a given positive integer.

The Collatz conjecture states that for any positive integer n, repeatedly applying
the rule (n/2 if even, 3n+1 if odd) will eventually reach 1. This function
returns the entire sequence from the starting number to 1.

# Arguments
- `n::Integer`: Starting positive integer (must be > 0)

# Returns
- `Vector{Int}`: Complete sequence from n to 1 (inclusive)

# Examples
```julia
julia> collatz_sequence(3)
8-element Vector{Int64}:
 3
 10
 5
 16
 8
 4
 2
 1

julia> collatz_sequence(7)
17-element Vector{Int64}:
 7
 22
 11
 34
 17
 52
 26
 13
 40
 20
 10
 5
 16
 8
 4
 2
 1

julia> length(collatz_sequence(27))
112
```

# Notes
- The conjecture remains unproven, but has been verified for very large numbers
- Some sequences can become quite long before reaching 1
- The function will run indefinitely if the conjecture is false for the input

# Throws
- `ArgumentError`: if n ≤ 0

# See Also
- Wikipedia: Collatz conjecture
- OEIS A006577: Number of steps in Collatz sequence
"""
function collatz_sequence(n)
    # Input validation
    if n ≤ 0
        throw(ArgumentError("Input must be a positive integer, got: $n"))
    end
    
    sequence = Int[]
    nn = n
    
    while nn != 1
        push!(sequence, nn)
        nn = iseven(nn) ? nn ÷ 2 : 3*nn + 1
    end
    
    # Add the final 1
    push!(sequence, nn)
    
    return sequence
end

end # module CollatzConjecture


