module ExamplePlots

using Reexport
@reexport using Plots
# using Colors
# using Compat

export
  test_examples

include("example_generation.jl")

end # module
