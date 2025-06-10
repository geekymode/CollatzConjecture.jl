```@meta
CurrentModule = CollatzConjecture
```

# CollatzConjecture

Documentation for [CollatzConjecture](https://github.com/geekymode/CollatzConjecture.jl).

# Introduction

Welcome to the documentation for CollatzConjecture!

## What is CollatzConjecture.jl?

[CollatzConjecture](https://github.com/geekymode/CollatzConjecture.jl) is a formal TBD.


# Collatz Conjecture Visualizations

Welcome to the Collatz Conjecture Visualization package! This package provides tools for exploring and visualizing the famous Collatz conjecture through various mathematical and artistic representations.

## Overview

The Collatz conjecture is one of the most famous unsolved problems in mathematics. Starting with any positive integer n:
- If n is even, divide it by 2
- If n is odd, multiply by 3 and add 1
- Repeat until you reach 1

This package provides multiple ways to visualize these sequences and explore their mathematical properties.

## Quick Start

Here's a basic visualization of Collatz sequences using the default parameters:

```@example plots
using CollatzConjecture
using CairoMakie
CairoMakie.activate!()
using CollatzConjecture
using CairoMakie

fig = create_collatz_visualization(n=50, print_numbers=true)
save("assets/collatz.png", fig)  # Save the figure to a path within your docs
![](assets/collatz.png)
```

!!! tip
    This is still under active development.

## Resources for getting started

There are a few ways to get started with CollatzConjecture:

## Installation

Open a Julia session and enter

```julia
using Pkg; Pkg.add("CollatzConjecture")
```

this will download the package and all the necessary dependencies for you. Next you can import the package with


and you are ready to go.

## Quickstart

```julia
using CollatzConjecture
```



```@autodocs
Modules = [CollatzConjecture]
```