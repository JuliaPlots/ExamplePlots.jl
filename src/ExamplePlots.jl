module ExamplePlots

using Reexport
@reexport using Plots

export
  test_examples

include("example_generation.jl")

end # module
