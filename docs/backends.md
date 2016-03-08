
Backends are the lifeblood of Plots, and the diversity between features, approaches, and strengths/weaknesses was 
one of the primary reasons that I started this package.

For those who haven't had the pleasure of hacking on 15 different plotting APIs:  First, consider yourself lucky.  However,
you will probably have a hard time choosing the right backend for your task at hand.  This document is meant to be a guide and 
introduction to making that choice.

## For the impatient

Just let me plot already!

If your plot requires... | ... then use...
----------- | -----------------
Lots of features    | Gadfly, PyPlot, Plotly, GR
Speed               | GR, PyPlot
Interactivity       | Plotly, PyPlot, PlotlyJS
Beauty              | Plotly, Gadfly
REPL Plotting       | UnicodePlots
Standalone GUI      | GR, Immerse, PyPlot, PlotlyJS
Minimal Dependencies | Plotly, UnicodePlots

Of course nothing in life is that simple.  Likely there are subtle tradeoffs between backends, long hidden bugs, and more excitement.
Don't be shy to try out something new!

## Gadfly

http://gadflyjl.org/

A Julia implementation inspired by the "Grammar of Graphics".

Pros:

- clean look
- lots of features
- flexible when combined with Compose (inset plots, etc)

Cons:

- do not support 3D
- slow time-to-first-plot
- lots of dependencies


## PyPlot

https://github.com/stevengj/PyPlot.jl

A Julia wrapper around the popular python package PyPlot (Matplotlib).  It uses PyCall to pass data with minimal overhead.

Pros:

- tons of functionality
- 2D and 3D
- 
