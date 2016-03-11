

const DOCDIR = joinpath(Pkg.dir("ExamplePlots"), "docs", "examples")
const IMGDIR = joinpath(DOCDIR, "img")

"""
Holds all data needed for a documentation example... header, description, and plotting expression (Expr)
"""
type PlotExample
  header::AbstractString
  desc::AbstractString
  exprs::Vector{Expr}
end

const _heatmaps_are_hists = !isdefined(Plots, :histogram2d)

# the _examples we'll run for each
const _examples = PlotExample[
  PlotExample("Lines",
              "A simple line plot of the columns.",
              [
                :(plot(Plots.fakedata(50,5), w=3))
              ]),
  PlotExample("Functions, adding data, and animations",
              "Plot multiple functions.  You can also put the function first, or use the form `plot(f, xmin, xmax)` where f is a Function or AbstractVector{Function}.\n\nGet series data: `x, y = plt[i]`.  Set series data: `plt[i] = (x,y)`. Add to the series with `push!`/`append!`.\n\nEasily build animations.  (`convert` or `ffmpeg` must be available to generate the animation.)  Use command `gif(anim, filename, fps=15)` to save the animation.",
              [
                :(p = plot([sin,cos], zeros(0), leg=false)),
                :(anim = Animation()),
                :(for x in linspace(0, 10π, 100)
                    push!(p, x, Float64[sin(x), cos(x)])
                    frame(anim)
                  end)
              ]),
  PlotExample("Parametric plots",
              "Plot function pair (x(u), y(u)).",
              [
                :(plot(sin, x->sin(2x), 0, 2π, line=4, leg=false, fill=(0,:orange)))
              ]),
  PlotExample("Colors",
              "Access predefined palettes (or build your own with the `colorscheme` method).  Line/marker colors are auto-generated from the plot's palette, unless overridden.  Set the `z` argument to turn on series gradients.",
              [
                :(y = rand(100)),
                :(plot(0:10:100,rand(11,4),lab="lines",w=3, palette=:grays, fill=(0.5,:auto))),
                :(scatter!(y, zcolor=abs(y-.5), m=(:heat,0.8,stroke(1,:green)), ms=10*abs(y-0.5)+4, lab="grad"))
              ]),
  PlotExample("Global",
              "Change the guides/background/limits/ticks.  Convenience args `xaxis` and `yaxis` allow you to pass a tuple or value which will be mapped to the relevant args automatically.  The `xaxis` below will be replaced with `xlabel` and `xlims` args automatically during the preprocessing step. You can also use shorthand functions: `title!`, `xaxis!`, `yaxis!`, `xlabel!`, `ylabel!`, `xlims!`, `ylims!`, `xticks!`, `yticks!`",
              [
                :(y = rand(20,3)),
                :(plot(y, xaxis=("XLABEL",(-5,30),0:2:20,:flip), background_color = RGB(0.2,0.2,0.2), leg=false)),
                :(hline!(mean(y,1)+rand(1,3), line=(4,:dash,0.6,[:lightgreen :green :darkgreen]))),
                :(vline!([5,10])),
                :(title!("TITLE")),
                :(yaxis!("YLABEL", :log10))
              ]),
  PlotExample("Two-axis",
              "Use the `axis` arguments.\n\nNote: Currently only supported with Qwt and PyPlot",
              [
                :(plot(Vector[randn(100), randn(100)*100], axis = [:l :r], ylabel="LEFT", yrightlabel="RIGHT", xlabel="X", title="TITLE"))
              ]),
  PlotExample("Arguments",
              "Plot multiple series with different numbers of points.  Mix arguments that apply to all series (marker/markersize) with arguments unique to each series (colors).  Special arguments `line`, `marker`, and `fill` will automatically figure out what arguments to set (for example, we are setting the `linestyle`, `linewidth`, and `color` arguments with `line`.)  Note that we pass a matrix of colors, and this applies the colors to each series.",
              [
                :(ys = Vector[rand(10), rand(20)]),
                :(plot(ys, line=(:dot,4,[:black :orange]), marker=([:hex :d],12,0.8,stroke(3,:gray))))
              ]),
  PlotExample("Build plot in pieces",
              "Start with a base plot...",
              [
                :(plot(rand(100)/3, reg=true, fill=(0,:green)))
              ]),
  PlotExample("",
              "and add to it later.",
              [
                :(scatter!(rand(100), markersize=6, c=:orange))
              ]),
  PlotExample(_heatmaps_are_hists ? "Heatmaps" : "Histogram2D",
              "",
              [
                _heatmaps_are_hists ? :(heatmap(randn(10000),randn(10000), nbins=20)) : :(histogram2d(randn(10000), randn(10000), nbins=20))
              ]),
  PlotExample("Line types",
              "",
              [
                :(types = intersect(supportedTypes(), [:line, :path, :steppre, :steppost, :sticks, :scatter])'),
                :(n = length(types)),
                :(x = Vector[sort(rand(20)) for i in 1:n]),
                :(y = rand(20,n)),
                :(plot(x, y, line=(types,3), lab=map(string,types), ms=15))
              ]),
  PlotExample("Line styles",
              "",
              [
                :(styles = setdiff(supportedStyles(), [:auto])'),
                :(plot(cumsum(randn(20,length(styles)),1), style=:auto, label=map(string,styles), w=5))
              ]),
  PlotExample("Marker types",
              "",
              [
                :(markers = setdiff(supportedMarkers(), [:none,:auto,Shape])'),
                :(n = length(markers)),
                :(x = linspace(0,10,n+2)[2:end-1]),
                :(y = repmat(reverse(x)', n, 1)),
                :(scatter(x, y, m=(8,:auto), lab=map(string,markers), bg=:linen, xlim=(0,10), ylim=(0,10)))
              ]),
  PlotExample("Bar",
              "x is the midpoint of the bar. (todo: allow passing of edges instead of midpoints)",
              [
                :(bar(randn(999)))
              ]),
  PlotExample("Histogram",
              "",
              [
                :(histogram(randn(1000), nbins=20))
              ]),
  PlotExample("Subplots",
              """
                subplot and subplot! are distinct commands which create many plots and add series to them in a circular fashion.
                You can define the layout with keyword params... either set the number of plots `n` (and optionally number of rows `nr` or
                number of columns `nc`), or you can set the layout directly with `layout`.
              """,
              [
                :(subplot(randn(100,5), layout=[1,1,3], t=[:line :hist :scatter :step :bar], nbins=10, leg=false))
              ]),
  PlotExample("Adding to subplots",
              "Note here the automatic grid layout, as well as the order in which new series are added to the plots.",
              [
                :(subplot(Plots.fakedata(100,10), n=4, palette=[:grays :blues :heat :lightrainbow], bg=[:orange :pink :darkblue :black]))
              ]),
  PlotExample("",
              "",
              [
                :(subplot!(Plots.fakedata(100,10)))
              ]),
  PlotExample("Open/High/Low/Close",
              "Create an OHLC chart.  Pass in a vector of OHLC objects as your `y` argument.  Adjust the tick width with arg `markersize`.",
              [
                :(n=20),
                :(hgt=rand(n)+1),
                :(bot=randn(n)),
                :(openpct=rand(n)),
                :(closepct=rand(n)),
                :(y = [OHLC(openpct[i]*hgt[i]+bot[i], bot[i]+hgt[i], bot[i], closepct[i]*hgt[i]+bot[i]) for i in 1:n]),
                :(ohlc(y; markersize=8))
              ]),
  PlotExample("Annotations",
              "Currently only text annotations are supported.  Pass in a tuple or vector-of-tuples: (x,y,text).  `annotate!(ann)` is shorthand for `plot!(; annotation=ann)`",
              [
                :(y = rand(10)),
                :(plot(y, ann=(3,y[3],text("this is #3",:left)))),
                :(annotate!([(5,y[5],text("this is #5",16,:red,:center)),
                             (10,y[10],text("this is #10",:right,20,"courier"))]))
              ]),
  PlotExample("Custom Markers",
              "A `Plots.Shape` is a light wrapper around vertices of a polygon.  For supported backends, pass arbitrary polygons as the marker shapes.  Note: The center is (0,0) and the size is expected to be rougly the area of the unit circle.",
              [
                :(verts = [(-1.0,1.0),(-1.28,0.6),(-0.2,-1.4),(0.2,-1.4),(1.28,0.6),(1.0,1.0),
                           (-1.0,1.0),(-0.2,-0.6),(0.0,-0.2),(-0.4,0.6),(1.28,0.6),(0.2,-1.4),
                           (-0.2,-1.4),(0.6,0.2),(-0.2,0.2),(0.0,-0.2),(0.2,0.2),(-0.2,-0.6)])
                :(plot(0.1:0.2:0.9, 0.7rand(5)+0.15,
                       l=(3,:dash,:lightblue),
                       m=(Shape(verts),30,RGBA(0,0,0,0.2)),
                       bg=:pink, fg=:darkblue,
                       xlim = (0,1), ylim=(0,1), leg=false))
              ]),

  PlotExample("Contours",
              "",
              [
                :(x = 1:0.3:20),
                :(y = x),
                :(f(x,y) = sin(x)+cos(y)),
                :(contour(x, y, f, fill=true))
              ]),

  PlotExample("Pie",
              "",
              [
                :(x = ["Nerds", "Hackers", "Scientists"]),
                :(y = [0.4, 0.35, 0.25]),
                :(pie(x, y, title="The Julia Community", l=0.5))
              ]),

  PlotExample("3D",
              "",
              [
                :(n = 100),
                :(ts = linspace(0,8π,n)),
                :(x = ts .* map(cos,ts)),
                :(y = 0.1ts .* map(sin,ts)),
                :(z = 1:n),
                :(plot(x, y, z, zcolor=reverse(z), m=(10,0.8,:blues,stroke(0)), leg=false, w=5)),
                :(plot!(zeros(n),zeros(n),1:n, w=10))
              ]),

  PlotExample("DataFrames",
              "Plot using DataFrame column symbols.",
              [
                # :(import DataFrames, RDatasets),
                :(iris = RDatasets.dataset("datasets", "iris")),
                :(scatter(iris, :SepalLength, :SepalWidth, group=:Species,
                          title = "My awesome plot", xlabel = "Length", ylabel = "Width",
                          m=(0.5, [:+ :h :star7], 12), bg=RGB(.2,.2,.2)))
              ]),
]

# --------------------------------------------------------------------------------------

function createStringOfMarkDownCodeValues(arr, prefix = "")
  string("`", prefix, join(sort(map(string, arr)), "`, `$prefix"), "`")
end
createStringOfMarkDownSymbols(arr) = isempty(arr) ? "" : createStringOfMarkDownCodeValues(arr, ":")


function generate_markdown(pkgname::Symbol; skip = [])

  # set up the backend, and don't show the plots by default
  pkg = backend(pkgname)
  # default(:show, false)

  # mkdir if necessary
  pkgdir = joinpath(IMGDIR, string(pkgname))
  try
    mkdir(pkgdir)
  end

  # open the markdown file
  md = open("$DOCDIR/$(pkgname).md", "w")

  # write(md, "## Examples for backend: $pkgname\n\n")

  write(md, "### Initialize\n\n```julia\nusing Plots\n$(pkgname)()\n```\n\n")


  for (i,example) in enumerate(_examples)

    i in skip && continue

    try

      # we want to always produce consistent results
      srand(1234)

      # run the code
      map(eval, example.exprs)

      # # save the png
      # imgname = "$(pkgname)_example_$i.png"

      # NOTE: uncomment this to overwrite the images as well
      if i == 2
        imgname = "$(pkgname)_example_$i.gif"
        gif(anim, "$pkgdir/$imgname", fps=15)
      else
        imgname = "$(pkgname)_example_$i.png"
        png("$pkgdir/$imgname")
      end

      # write out the header, description, code block, and image link
      write(md, "### $(example.header)\n\n")
      write(md, "$(example.desc)\n\n")
      write(md, "```julia\n$(join(map(string, example.exprs), "\n"))\n```\n\n")
      write(md, "![](img/$pkgname/$imgname)\n\n")

    catch ex
      # TODO: put error info into markdown?
      warn("Example $pkgname:$i failed with: $ex")
    end

    #
  end

  write(md, "- Supported arguments: $(createStringOfMarkDownCodeValues(supportedArgs(pkg)))\n")
  write(md, "- Supported values for axis: $(createStringOfMarkDownSymbols(supportedAxes(pkg)))\n")
  write(md, "- Supported values for linetype: $(createStringOfMarkDownSymbols(supportedTypes(pkg)))\n")
  write(md, "- Supported values for linestyle: $(createStringOfMarkDownSymbols(supportedStyles(pkg)))\n")
  write(md, "- Supported values for marker: $(createStringOfMarkDownSymbols(supportedMarkers(pkg)))\n")
  write(md, "- Is `subplot`/`subplot!` supported? $(subplotSupported(pkg) ? "Yes" : "No")\n\n")

  write(md, "(Automatically generated: $(now()))")
  close(md)

end


# make and display one plot
function test_examples(pkgname::Symbol, idx::Int; debug = false, disp = true)
  Plots._debugMode.on = debug
  println("Testing plot: $pkgname:$idx:$(_examples[idx].header)")
  backend(pkgname)
  backend()
  map(eval, _examples[idx].exprs)
  plt = current()
  if disp
    gui(plt)
  end
  plt
end

# generate all plots and create a dict mapping idx --> plt
function test_examples(pkgname::Symbol; debug = false, disp = true)
  Plots._debugMode.on = debug
  plts = Dict()
  for i in 1:length(_examples)

    try
      plt = test_examples(pkgname, i, debug=debug, disp=disp)
      plts[i] = plt
    catch ex
      # TODO: put error info into markdown?
      warn("Example $pkgname:$i:$(_examples[i].header) failed with: $ex")
    end
  end
  plts
end
