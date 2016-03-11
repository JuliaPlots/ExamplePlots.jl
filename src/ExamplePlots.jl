module ExamplePlots

using Reexport
@reexport using Plots
import DataFrames, RDatasets

export
  test_examples

include("example_generation.jl")

end # module
