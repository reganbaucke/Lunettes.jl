# Lunettes.jl

## A small Lens package for Julia

Lunettes is a small library for getting and setting elements in large nested
data structures in a safe way.

## Usage

The package exports one type: a `Lens{F,T}`, read: a `Lens` from `F` to `T`.

```julia
@lens struct Missal
    color::String
end
```

```julia
@lens struct Cruet
    fullness::Float64
end
```

```julia
@lens struct Altar
    missal::Missal
    wine_cruet::Cruet
    water_cruet::Cruet
end
```

We have a complicated nested data structure above.

missal_color = Lens{Altar,:missal}() \circ Lens{Missal,:color}()
water_status = Lens{Altar,:water_cruet}() \circ Lens{Cruet,:fullness}()

Lets initialise an Altar:

my_altar = Altar(Missal("Red"), Cruet(0.8), Cruet(0.9))

suppose we would like to reach in and learn the value of the water cruet's fullness:

We could write 

my_altar.water_cruet.fullness

or we could write

getr(water_status)

Better yet, suppose we would like to update the Altar, we might consider writing

my_new_altar = Altar(Missal("Red"), Cruet(0.2), Cruet(0.5))

setr(water_status, my_altar, 0.2)

infact, both getr and setr are automatically curried, so we could even write

my_third_altar = my_altar |>
setr(water_state, 0.5) |> 
setr(missal_color, "Green")