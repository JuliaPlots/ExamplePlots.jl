
# Intro to Plots in Julia

**Author: Thomas Breloff (@tbreloff)**

Data visualization has a complicated history, with plotting software making trade-offs between features vs simplicity, speed vs beauty, and static vs dynamic.  Some make a visualization and never change it, others must make updates in real-time. 

Plots is a visualization interface and toolset.  It sits above other visualization "backends", connecting commands with implementation.  If one backend does not support your desired features, or make the right trade-offs, just switch to another backend with one command.  No need to change your code.  No need to learn something new.  Plots might be the last plotting package you ever learn.

My goals with the package are:

- **Intuitive**.  Start generating complex plots without reading volumes of documentation.  Commands should "just work".
- **Concise**.  Less code means fewer mistakes and more efficient development/analysis.
- **Flexible**.  Produce your favorite plots from your favorite package, but quicker and simpler.
- **Consistent**.  Don't commit to one graphics package.  Use the same code and access the strengths of all backends.
- **Lightweight**.  Very few dependencies, since backends are loaded and initialized dynamically.

Use the preprocessing pipeline in Plots to fully describe your visualization before it calls the backend code.  This maintains modularity and allows for efficient separation of front end code, algorithms, and backend graphics.  New graphical backends can be added with minimal effort.

Please add wishlist items, bugs, or any other comments/questions to the [issues list](https://github.com/tbreloff/Plots.jl/issues).

## A Quick Example

```julia
using Plots
pyplot(size=(300,300))

# initialize the attractor
n = 3000
dt = 0.02
σ, ρ, β = 10., 28., 8/3
x, y, z = 1., 1., 1.
X, Y, Z = [x], [y], [z]

# build an animated gif, saving every 10th frame
@gif for i=1:n
    dx = σ*(y - x);      x += dt * dx; push!(X,x)
    dy = x*(ρ - z) - y;  y += dt * dy; push!(Y,y)
    dz = x*y - β*z;      z += dt * dz; push!(Z,z)
    plot3d(X,Y,Z)
end every 10
```

![](examples/img/lorenz.gif)

## Installation

First, add the package

```julia
Pkg.add("Plots")

# if you want the latest features:
Pkg.checkout("Plots")

# or for the bleeding edge:
Pkg.checkout("Plots", "dev")
```

then get any plotting packages you need (obviously, you should get at least one backend).

```julia
Pkg.add("PyPlot")
Pkg.add("GR")
Pkg.add("Gadfly")
Pkg.add("Immerse")
Pkg.add("UnicodePlots")
Pkg.add("Qwt")
```

## Use

Load it in.  The underlying plotting backends are not imported until `backend()` is called (which happens
on your first call to `plot` or `subplot`).  This means that you don't need any backends to be installed when you call `using Plots`.

Plots will try to figure out a good default backend for you automatically based on what backends are installed.

```julia
using Plots
```

#### Example (inspired by [this](http://gadflyjl.org/geom_point.html))

```julia
# switch to Gadfly as a backend
gadfly()

# load a dataset
using RDatasets
iris = dataset("datasets", "iris");

# Scatter plot with some custom settings
scatter(iris, :SepalLength, :SepalWidth, group=:Species,
        title = "My awesome plot",
        xlabel = "Length", ylabel = "Width",
        m=(0.5, [:+ :h :star7], 12),
        bg=RGB(.2,.2,.2))

# save a png
png("iris")
```

![iris_plt](examples/img/iris.png)

## Documentation warning

The content below here is somewhat dated, and may not be fully accurate.  At a minimum it is not complete.  I'll replace it with more complete documentation and tutorials sometime in the future.  In the meantime, feel free to ask questions using the [Plots issue tracker](https://github.com/tbreloff/Plots.jl/issues).

## API

Call `backend(backend::Symbol)` or the shorthands (`gadfly()`, `qwt()`, `unicodeplots()`, etc) to set the current plotting backend.
Subsequent commands are converted into the relevant plotting commands for that package:

Use `plot` to create a new plot object, and `plot!` to add to an existing one:

```julia
plot(args...; kw...)                  # creates a new plot window, and sets it to be the `current`
plot!(args...; kw...)                 # adds to the `current`
plot!(plt, args...; kw...)            # adds to the plot `plt`
```

There are many ways to pass in data to the plot functions... some examples:

- Vector-like (subtypes of AbstractArray{T,1})
- Matrix-like (subtypes of AbstractArray{T,2})
- Vectors of Vectors
- Functions
- Vectors of Functions
- DataFrames with column symbols

In general, you can pass in a `y` only, or an `x` and `y`, both of whatever type(s) you want, and Plots will slice up the data as needed.
For matrices, data is split by columns.  For functions, data is mapped.  For DataFrames, a Symbol/Symbols in place of x/y will map to
the relevant column(s).

Here are some example usages... remember you can always use `plot!` to update an existing plot, and that, unless specified, you will update the `current()`.

```julia
plot()                                    # empty plot object
plot(4)                                   # initialize with 4 empty series
plot(rand(10))                            # plot 1 series... x = 1:10
plot(rand(10,5))                          # plot 5 series... x = 1:10
plot(rand(10), rand(10))                  # plot 1 series
plot(rand(10,5), rand(10))                # plot 5 series... y is the same for all
plot(sin, rand(10))                       # y = sin(x)
plot(rand(10), sin)                       # same... y = sin(x)
plot([sin,cos], 0:0.1:π)                  # plot 2 series, sin(x) and cos(x)
plot([sin,cos], 0, π)                     # plot sin and cos on the range [0, π]
plot(1:10, Any[rand(10), sin])            # plot 2 series, y = rand(10) for the first, y = sin(x) for the second... x = 1:10 for both
plot(dataset("Ecdat", "Airline"), :Cost)  # plot from a DataFrame
```

All plot methods accept a number of keyword arguments (see the tables below), which follow some rules:
- Many arguments have aliases which are replaced during preprocessing.  `c` is the same as `color`, `m` is the same as `marker`, etc.  You can choose how verbose you'd like to be.  (see the tables below)
- There are some special arguments (`xaxis`, `yaxis`, `line`, `marker`, `fill` and the aliases `l`, `m`, `f`) which magically set many related things at once.  (see the __Tip__ below)
- If the argument is a "matrix-type", then each column will map to a series, cycling through columns if there are fewer columns than series.  Anything else will apply the argument value to every series.
- Many arguments accept many different types... for example the `color` (also `markercolor`, `fillcolor`, etc) argument will accept strings or symbols with a color name, or any `Colors.Colorant`, or a `ColorScheme`, or a symbol representing a `ColorGradient`, or an AbstractVector of colors/symbols/etc...

You can update certain plot settings after plot creation (not supported on all backends):

```julia
plot!(title = "New Title", xlabel = "New xlabel", ylabel = "New ylabel")
plot!(xlims = (0, 5.5), ylims = (-2.2, 6), xticks = 0:0.5:10, yticks = [0,1,5,10])

# using shorthands:
xaxis!("mylabel", :log10, :flip)
```

## Subplots

With `subplot`, create multiple plots at once, with flexible layout options:

```julia
y = rand(100,3)
subplot(y)                    # create an automatic grid, and let it figure out the shape
subplot(y, n = 2)             # create two plots, the third series is added to the first plot
subplot(y; nr = 1)            # create an automatic grid, but fix the number of rows
subplot(y; nc = 1)            # create an automatic grid, but fix the number of columns
subplot(y; layout = [1, 2])   # explicit layout.  Lists the number of plots in each row
```

__Tip__: You can call `subplot!(args...; kw...)` to add to an existing subplot.

To create a grid of existing plots `p` and `q`, use:
```julia
pq = subplot(p, q)
```
__Tip__: Calling `subplot!` on a `Plot` object, or `plot!` on a `Subplot` object will throw an error.

## Shorthands

```julia
scatter(args...; kw...)    = plot(args...; kw...,  linetype = :scatter)
scatter!(args...; kw...)   = plot!(args...; kw..., linetype = :scatter)
bar(args...; kw...)        = plot(args...; kw...,  linetype = :bar)
bar!(args...; kw...)       = plot!(args...; kw..., linetype = :bar)
histogram(args...; kw...)  = plot(args...; kw...,  linetype = :hist)
histogram!(args...; kw...) = plot!(args...; kw..., linetype = :hist)
heatmap(args...; kw...)    = plot(args...; kw...,  linetype = :heatmap)
heatmap!(args...; kw...)   = plot!(args...; kw..., linetype = :heatmap)
sticks(args...; kw...)     = plot(args...; kw...,  linetype = :sticks, marker = :ellipse)
sticks!(args...; kw...)    = plot!(args...; kw..., linetype = :sticks, marker = :ellipse)
hline(args...; kw...)      = plot(args...; kw...,  linetype = :hline)
hline!(args...; kw...)     = plot!(args...; kw..., linetype = :hline)
vline(args...; kw...)      = plot(args...; kw...,  linetype = :vline)
vline!(args...; kw...)     = plot!(args...; kw..., linetype = :vline)
ohlc(args...; kw...)       = plot(args...; kw...,  linetype = :ohlc)
ohlc!(args...; kw...)      = plot!(args...; kw..., linetype = :ohlc)

title!(s::AbstractString)                 = plot!(title = s)
xlabel!(s::AbstractString)                = plot!(xlabel = s)
ylabel!(s::AbstractString)                = plot!(ylabel = s)
xlims!{T<:Real,S<:Real}(lims::Tuple{T,S}) = plot!(xlims = lims)
ylims!{T<:Real,S<:Real}(lims::Tuple{T,S}) = plot!(ylims = lims)
xticks!{T<:Real}(v::AVec{T})              = plot!(xticks = v)
yticks!{T<:Real}(v::AVec{T})              = plot!(yticks = v)
xflip!(flip::Bool = true)                 = plot!(xflip = flip)
yflip!(flip::Bool = true)                 = plot!(yflip = flip)
xaxis!(args...)                           = plot!(xaxis = args)
yaxis!(args...)                           = plot!(yaxis = args)
annotate!(anns)                           = plot!(annotation = anns)
```

## Keyword arguments:

Keyword | Default | Type | Aliases 
---- | ---- | ---- | ----
`:annotation` | `nothing` | Series | `:ann`, `:annotate`, `:annotations`, `:anns`  
`:axis` | `left` | Series | `:axiss`  
`:background_color` | `RGB{U8}(1.0,1.0,1.0)` | Plot | `:background`, `:background_colour`, `:bg`, `:bg_color`, `:bgcolor`  
`:color_palette` | `auto` | Plot | `:palette`  
`:fill` | `nothing` | Series | `:area`, `:f`  
`:fillalpha` | `nothing` | Series | `:fa`, `:fillalphas`, `:fillopacity`  
`:fillcolor` | `match` | Series | `:fc`, `:fcolor`, `:fillcolors`, `:fillcolour`  
`:fillrange` | `nothing` | Series | `:fillranges`, `:fillrng`  
`:foreground_color` | `auto` | Plot | `:fg`, `:fg_color`, `:fgcolor`, `:foreground`, `:foreground_colour`  
`:grid` | `true` | Plot |   
`:group` | `nothing` | Series | `:g`, `:groups`  
`:guidefont` | `Plots.Font("Helvetica",11,:hcenter,:vcenter,0.0,RGB{U8}(0.0,0.0,0.0))` | Plot |   
`:label` | `AUTO` | Series | `:lab`, `:labels`  
`:layout` | `nothing` | Plot |   
`:legend` | `true` | Plot | `:leg`  
`:legendfont` | `Plots.Font("Helvetica",8,:hcenter,:vcenter,0.0,RGB{U8}(0.0,0.0,0.0))` | Plot |   
`:line` | `nothing` | Series | `:l`  
`:linealpha` | `nothing` | Series | `:la`, `:linealphas`, `:lineopacity`  
`:linecolor` | `auto` | Series | `:c`, `:color`, `:colour`, `:linecolors`  
`:linestyle` | `solid` | Series | `:linestyles`, `:ls`, `:s`, `:style`  
`:linetype` | `path` | Series | `:linetypes`, `:lt`, `:t`, `:type`  
`:linewidth` | `1` | Series | `:linewidths`, `:lw`, `:w`, `:width`  
`:link` | `false` | Plot |   
`:linkfunc` | `nothing` | Plot |   
`:linkx` | `false` | Plot | `:xlink`  
`:linky` | `false` | Plot | `:ylink`  
`:marker` | `nothing` | Series | `:m`, `:mark`  
`:markeralpha` | `nothing` | Series | `:alpha`, `:ma`, `:markeralphas`, `:markeropacity`, `:opacity`  
`:markercolor` | `match` | Series | `:markercolors`, `:markercolour`, `:mc`, `:mcolor`  
`:markershape` | `none` | Series | `:markershapes`, `:shape`  
`:markersize` | `6` | Series | `:markersizes`, `:ms`, `:msize`  
`:markerstrokealpha` | `nothing` | Series | `:markerstrokealphas`  
`:markerstrokecolor` | `match` | Series | `:markerstrokecolors`  
`:markerstrokestyle` | `solid` | Series | `:markerstrokestyles`  
`:markerstrokewidth` | `1` | Series | `:markerstrokewidths`  
`:n` | `-1` | Plot |   
`:nbins` | `30` | Series | `:nb`, `:nbin`, `:nbinss`  
`:nc` | `-1` | Plot |   
`:nlevels` | `15` | Series | `:nlevelss`  
`:nr` | `-1` | Plot |   
`:pos` | `(0,0)` | Plot |   
`:show` | `false` | Plot | `:display`, `:gui`  
`:size` | `(500,300)` | Plot | `:windowsize`, `:wsize`  
`:smooth` | `false` | Series | `:reg`, `:regression`, `:smooths`  
`:surface` | `nothing` | Series | `:surfaces`  
`:tickfont` | `Plots.Font("Helvetica",8,:hcenter,:vcenter,0.0,RGB{U8}(0.0,0.0,0.0))` | Plot |   
`:title` | `` | Plot |   
`:windowtitle` | `Plots.jl` | Plot | `:wtitle`  
`:xaxis` | `nothing` | Plot |   
`:xflip` | `false` | Plot |   
`:xlabel` | `` | Plot | `:xlab`  
`:xlims` | `auto` | Plot | `:xlim`, `:xlimit`, `:xlimits`  
`:xscale` | `identity` | Plot |   
`:xticks` | `auto` | Plot | `:xtick`  
`:yaxis` | `nothing` | Plot |   
`:yflip` | `false` | Plot |   
`:ylabel` | `` | Plot | `:ylab`  
`:ylims` | `auto` | Plot | `:ylim`, `:ylimit`, `:ylimits`  
`:yrightlabel` | `` | Plot | `:y2lab`, `:y2label`, `:ylab2`, `:ylabel2`, `:ylabelright`, `:ylabr`, `:yrlab`  
`:yscale` | `identity` | Plot |   
`:yticks` | `auto` | Plot | `:ytick`  
`:z` | `nothing` | Series | `:zs`  


## Plot types:

Type | Desc | Aliases
---- | ---- | ----
`:none` | No line | `:n`, `:no`  
`:line` | Lines with sorted x-axis | `:l`  
`:path` | Lines | `:p`  
`:steppre` | Step plot (vertical then horizontal) | `:stepinv`, `:stepinverted`, `:stepsinv`, `:stepsinverted`  
`:steppost` | Step plot (horizontal then vertical) | `:stair`, `:stairs`, `:step`, `:steps`  
`:sticks` | Vertical lines | `:stem`, `:stems`  
`:scatter` | Points, no lines | `:dots`  
`:heatmap` | Colored regions by density |   
`:hexbin` | Similar to heatmap |   
`:hist` | Histogram (doesn't use x) | `:histogram`  
`:bar` | Bar plot (centered on x values) |   
`:hline` | Horizontal line (doesn't use x) |   
`:vline` | Vertical line (doesn't use x) |   
`:ohlc` | Open/High/Low/Close chart (expects y is AbstractVector{Plots.OHLC}) |   
`:contour` | Contour lines (uses z) |   
`:path3d` | 3D path (uses z) | `:line3d`  
`:scatter3d` | 3D scatter plot (uses z) |   


## Line styles:

Type | Aliases
---- | ----
`:auto` | `:a`  
`:solid` | `:s`  
`:dash` | `:d`  
`:dot` |   
`:dashdot` | `:dd`  
`:dashdotdot` | `:ddd`  


## Markers:

Type | Aliases
---- | ----
`:none` | `:n`, `:no`  
`:auto` | `:a`  
`:cross` | `:+`, `:plus`  
`:diamond` | `:d`  
`:dtriangle` | `:V`, `:downtri`, `:downtriangle`, `:dt`, `:dtri`, `:v`  
`:ellipse` | `:c`, `:circle`  
`:heptagon` | `:hep`  
`:hexagon` | `:h`, `:hex`  
`:octagon` | `:o`, `:oct`  
`:pentagon` | `:p`, `:pent`  
`:rect` | `:r`, `:sq`, `:square`  
`:star4` |   
`:star5` | `:s`, `:star`, `:star1`  
`:star6` |   
`:star7` |   
`:star8` | `:s2`, `:star2`  
`:utriangle` | `:^`, `:uptri`, `:uptriangle`, `:ut`, `:utri`  
`:xcross` | `:X`, `:x`  


__Tip__: With supported backends, you can pass a `Plots.Shape` object for the `marker`/`markershape` arguments.  `Shape` takes a vector of 2-tuples in the constructor, defining the points of the polygon's shape in a unit-scaled coordinate space.  To make a square, for example, you could do `Shape([(1,1),(1,-1),(-1,-1),(-1,1)])`

__Tip__: You can see the default value for a given argument with `default(arg::Symbol)`, and set the default value with `default(arg::Symbol, value)` or `default(; kw...)`.  For example set the default window size and whether we should show a legend with `default(size=(600,400), leg=false)`.

## Magic Arguments

__Tip__: There are some helper arguments you can set:  `xaxis`, `yaxis`, `line`, `marker`, `fill`.  These go through special preprocessing to extract values into individual arguments.  The order doesn't matter, and if you pass a single value it's equivalent to wrapping it in a Tuple.  Examples:

```
plot(y, xaxis = ("mylabel", :log, :flip, (-1,1)))   # this sets the `xlabel`, `xscale`, `xflip`, and `xlims` arguments automatically
plot(y, line = (:bar, :blue, :dot, 10))             # this sets the `linetype`, `color`, `linestyle`, and `linewidth` arguments automatically
plot(y, marker = (:rect, :red, 10))                 # this sets the `markershape`, `markercolor`, and `markersize` arguments automatically
plot(y, fill = (:green, 10))                        # this sets the `fillcolor` and `fillrange` arguments automatically
                                                    # Note: `fillrange` can be:
                                                              a number (fill to horizontal line)
                                                              a vector of numbers (different for each data point)
                                                              a tuple of vectors (fill a band)
```

__Tip__: When plotting multiple lines, you can set all series to use the same value, or pass in a matrix to cycle through values.  Example:

```julia
plot(rand(100,4); color = [:red RGB(0,0,1)],     # (Matrix) lines 1 and 3 are red, lines 2 and 4 are blue
                  axis = :auto,                  # lines 1 and 3 are on the left axis, lines 2 and 4 are on the right
                  markershape = [:rect, :star]   # (Vector) ALL lines are passed the vector [:rect, :star1]
                  width = 5)                     # all lines have a width of 5
```

__Tip__: Not all features are supported for each backend, but you can see what's supported by calling the functions: `supportedArgs()`, `supportedAxes()`, `supportedTypes()`, `supportedStyles()`, `supportedMarkers()`, `subplotSupported()`

__Tip__: Call `gui()` to display the plot in a window.  Interactivity depends on backend.  Plotting at the REPL (without semicolon) implicitly calls `gui()`.

## Animations

Animations are created in 3 steps (see example #2):

- Initialize an `Animation` object.
- Save each frame of the animation with `frame(anim)`.
- Convert the frames to an animated gif with `gif(anim, filename, fps=15)`



