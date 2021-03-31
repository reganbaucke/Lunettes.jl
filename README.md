# Lunettes.jl

Lunettes.jl is a small package for getting and setting fields in large nested
data structures in a safe, mutation-free, way.

## Installation

In a Julia REPL, run
```julia
import Pkg
Pkg.add("Lunettes")
```
Simple as!

## Usage

The package exports one type: a `Lens{F,T}`, read: a `Lens` from `F` to `T`.

```julia
@lens struct Curtain
    color::String
    state::String
end
```

```julia
@lens struct Window
    frame_color::String
    left_curtain::Curtain
    right_curtain::Curtain
end
```

We have a complicated nested data structure above. Suppose we would like to manipulate this data structure, and make queries of its values.

Let us define a new `Lens` as the composition of two simpler lenses.

```julia
left_curtain_state = Lens{Window,:left_curtain}() ○ Lens{Curtain,:state}()
left_curtain_color = Lens{Window,:left_curtain}() ○ Lens{Curtain,:color}()
```

We will be able to use `left_curtain_state` as a way to access (with `getr`) and change (with `setr`) different windows.

Lets initialise a `Window`:

```julia
my_window = Window("White", Curtain("Purple", "Open"), Curtain("Orange","Shut"))
```

Suppose we would like to reach into our `Window` and learn the state of the left curtain. We could write 

```julia
my_curtain.left_window.state
```

or we could write

```julia
getr(left_curtain_state, my_window)
```

Better yet, suppose we would like to update the window and have the left curtain shut. We could write:

```julia
my_new_window = Window("White", Curtain("Purple", "Shut"), Curtain("Orange","Shut")) 
```

or instead

```julia
setr(left_curtain_state, my_window, "Shut")
```

In fact, both `getr` and `setr` are automatically curried, so we could even write

```julia
my_third_window = my_window |>
setr(left_curtain_state, "Shut") |> 
setr(left_curtain_color, "Goldish Brown")
```
producing a third window based off `my_window` that has its left curtain shut and a new color!

## So what's going on?

The `@lens` macro is doing nothing more that defining a method for the `getr` and `setr` functions for each member of the struct.

For instance, after defining the `Curtain` `struct`, the function `getr(::Lens, a)` is now defined for the `Lens` of types `Lens{Curtain,:state}()` and `Lens{Curtain,:color}()`. In fact their defintions are very simple:
```julia
function getr(l::Lens{Curtain,:state}, a)
    a.state
end

function setr(l::Lens{Curtain,:state}, a, c)
    Curtain(a.color, c)
end
```

By defining these getters and setters for these basic lenses, and then by composing lenses, we automatically obtain the correct definition of `getr` (and `setr`) for `Lens{Window,:left_curtain}() ○ Lens{Curtain,:state}()`.