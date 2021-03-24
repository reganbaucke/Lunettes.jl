module Lunettes

#Very basic struct
struct Lens{T,U} end

#compose two lenses
function Base.:∘(::Lens{T,U},::Lens{V,W}) where {T,U,V,W}
    Lens{Lens{T,U}, Lens{V,W}}()
end

# getter law for composed lenses
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

