macro lens(ex)
    lens(ex)
end

function lens(ex)
    if ex.head == :struct       # check to see if the expression is a struct
        if ex.args[1] == false      # check to see if it is immutable 
            struct_name = ex.args[2]    # get the name of the new struct
            field_names = Symbol[]      # collect up the names of the fields
            for arg in ex.args[3].args
                if arg isa Expr
                    if arg.head == :(::)
                        push!(field_names, arg.args[1])
                    end
                end
            end
            #for each field name, make expression that build the getr and setter for the type
            final_quote = Expr(:block, esc(ex), (map(field_names) do name
                get = """begin function Lunettes.getr(::Lens{$struct_name, :$name}, a)   
                        a.$name 
                    end \n; """
                set = "function Lunettes.setr(::Lens{$struct_name, :$name}, a, c) \n " * " $struct_name( "
                for fname in field_names
                    if name == fname
                        set = set * " c, "
                    else
                        set = set * " a.$fname, "
                    end
                end
                set *=" );  end end"
                out = get * set
                out
                Meta.parse(out) |> esc
            end)..., nothing )
            final_quote
        else
            error("Expected a `struct` expression, but received a `mutable struct` instead.")
        end
    else
        error("Expected a `struct` expression.")
    end
end