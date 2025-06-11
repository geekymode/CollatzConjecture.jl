```@meta
CurrentModule = CollatzConjecture
```

# CollatzConjecture

This is Documentation for the Julia package [CollatzConjecture](https://github.com/geekymode/CollatzConjecture.jl). For more background, check out this article [Fun with Collatz Conjecture](https://geekymode.github.io/CollatzBlog/). 

The Collatz Conjecture is a simple yet fascinating mathematical problem that asks: take any positive integer and repeatedly apply a basic rule until you reach 1. The rule is straightforward—if your number is even, divide it by 2; if it's odd, multiply by 3 and add 1. For example, starting with 7: 7 → 22 → 11 → 34 → 17 → 52 → 26 → 13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1. The conjecture claims that no matter which positive integer you start with, you will always eventually reach 1. Despite its elementary appearance, this problem has stumped mathematicians for decades—while it has been verified by computers for incredibly large numbers, no one has been able to prove it's true for all positive integers, making it one of the most famous unsolved problems in mathematics.




## The Collatz Function

Let $f: \mathbb{Z}^+ \to \mathbb{Z}^+$ be defined by:

$$f(n) = \begin{cases}
\frac{n}{2} & \text{if } n \equiv 0 \pmod{2} \\
3n + 1 & \text{if } n \equiv 1 \pmod{2}
\end{cases}$$

where $\mathbb{Z}^+$ denotes the set of positive integers.

## The Collatz Sequence

For any positive integer $n_0 \in \mathbb{Z}^+$, the **Collatz sequence** starting at $n_0$ is the sequence $(n_k)_{k=0}^{\infty}$ defined by:

$$n_{k+1} = f(n_k) \quad \text{for } k \geq 0$$

with initial condition $n_0$ given.

## Stopping Time

For a given starting value $n_0$, the **stopping time** $T(n_0)$ is defined as:

$$T(n_0) = \min\{k \geq 1 : n_k = 1\}$$

if such a $k$ exists, and $T(n_0) = \infty$ otherwise.

## The Collatz Conjecture (3n+1 Conjecture)

**Conjecture:** For every positive integer $n_0 \in \mathbb{Z}^+$, the stopping time $T(n_0)$ is finite.

Equivalently: For every $n_0 \in \mathbb{Z}^+$, there exists a finite $k$ such that $n_k = 1$.



### Trajectory Convergence
Every orbit of the dynamical system defined by $f$ eventually reaches the fixed point 1.

### Universal Convergence
$$\forall n_0 \in \mathbb{Z}^+ : \exists k \in \mathbb{N} \text{ such that } f^{(k)}(n_0) = 1$$

where $f^{(k)}$ denotes the $k$-fold composition of $f$.

## Remarks

1. The conjecture has been verified computationally for all $n_0 \leq 2^{68}$ (as of recent computational efforts).

2. The problem is equivalent to proving that the only cycle in the dynamical system is the trivial cycle $1 \to 4 \to 2 \to 1$.

3. The conjecture remains one of the most famous unsolved problems in mathematics, connecting elementary number theory with dynamical systems theory.


# Visualizations

This package provides tools for exploring and visualizing the famous Collatz conjecture through various mathematical and artistic representations.

## Quick Start

Here's a basic visualization of the first 25 Collatz sequences represented in the form of a tree.

```@example plot25
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()

fig_first_25 = create_collatz_with_labels(
    n=25, label_fontsize=20,use_range = true,
    s = 2.49, r = 0.76, h = 1.815, g = 1.3, 
    opacity = 0.93,  # Lower opacity for many lines
    e = 1.3, a = 0.19, f = 0.7,
    label_color=:gray)
```

## Fancy Visualizations



```@example plots2
using CollatzConjecture
using CairoMakie

CairoMakie.activate!()

# Large set visualization
fig = create_collatz_visualization()
fig
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