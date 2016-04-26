module ExamplePlots

using Reexport
@reexport using Plots

export
  test_examples, generate_markdown

include("example_generation.jl")

end # module
