using Test

## Load in source code
include("../src/Lunettes.jl")
using .Lunettes
@testset "All Tests" begin

@testset "Composition" begin

# set up domain model with structs
@lens struct Leaf 
    color::String
end

@lens struct Twig
    leaves::Leaf
end

@lens struct Branch
    twigs::Twig
end
@lens struct Trunk
    branches::Branch
end
@lens struct Tree
    species::String
    trunk::Trunk
end

# build tree
my_tree = Tree("Pohutakawa", Trunk(Branch(Twig(Leaf("Light Green")))))
another_tree = Tree("Pohutakawa", Trunk(Branch(Twig(Leaf("Light Green")))))

@test my_tree === another_tree

# build big Lens
leaf_one = Lens{Tree,:trunk}() ∘ 
    Lens{Trunk,:branches}() ∘
    Lens{Branch,:twigs}() ∘
    Lens{Twig,:leaves}() ∘
    Lens{Leaf,:color}()

@test getr(leaf_one)(my_tree) == "Light Green"
@test getr(leaf_one, my_tree) == "Light Green"

@test setr(leaf_one, my_tree, "Light Blue") == Tree("Pohutakawa", Trunk(Branch(Twig(Leaf("Light Blue")))))
@test setr(leaf_one, "Light Blue")(my_tree) == Tree("Pohutakawa", Trunk(Branch(Twig(Leaf("Light Blue")))))

end

@testset "Errors" begin

end

@testset "Macro on Parametric types" begin

@lens struct MyTestStruct{T}
   my_field::T
end

@lens struct AnotherTestStruct{T <: Number} 
   my_field::T
end

end


end
