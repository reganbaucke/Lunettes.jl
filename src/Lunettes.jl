module Lunettes

#Very basic struct
"""
   my_lens = Lens{A,B}()

Creates a new `Lens` for which the functions `getr` and `setr` can be dispatched on.
"""
struct Lens{T,U} end

#compose two lenses
"""
   Lens{A,B}() ∘ Lens{C,D}()

Create a new `Lens` based upon the composition of two other `Lens`es.
This composed `Lens` will automatically have defined for it both
`getr` and `setr` in such a way which is consist with the Lens composition law.
"""
function Base.:∘(::Lens{T,U},::Lens{V,W}) where {T,U,V,W}
    Lens{Lens{T,U}, Lens{V,W}}()
end

# getter law for composed lenses
"""
   getr(::Lens{A,B}, a)

Returns the value that Lens{A,B}() "sees" for input a.

Note that `getr` is automatically curried i.e.
```
   getr(Lens{A,B}(), a) == getr(Lens{A,B}())(a)
```
"""
function getr(::Lens{Lens{T,U},Lens{V,W}}, a) where {T,U,V,W}
    getr(Lens{V,W}(), getr(Lens{T,U}(), a))
end
# curried version
function getr(l::Lens)
    function out(a)
        getr(l,a)
    end
end


# setter law for composed lens
"""
   setr(::Lens{A,B}, a, c)

Takes value `a` and returns a new value similar to `a` except `c` is now in the position
that Lens{A,B}() "sees".

Note that `setr` is automatically curried i.e.
```
setr(Lens{A,B}(), a, c) == setr(Lens{A,B}(), c)(a)
```

"""
function setr(::Lens{Lens{T,U},Lens{V,W}}, a, c) where {T,U,V,W}
    setr(Lens{T,U}(), a, setr(Lens{V,W}(), getr(Lens{T,U}(), a), c))
end
# curried version
function setr(l::Lens, c)
    function out(a)
        setr(l, a, c)
    end
end

array_lens(N) = Lens{Vector,N}()
function getr(::Lens{Vector,N}, a) where {N}
    a[N]
end
function setr(::Lens{Vector,N}, a, c) where {N}
    if length(a) < N
        throw("Bounds Error")
    end
    map(1:length(a)) do index
        if index == N
            c
        else
            a[index]
        end
    end
end

include("./macro.jl")
export Lens, setr, @lens, array_lens, getr

end  #module

