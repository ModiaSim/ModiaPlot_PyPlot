# ModiaPlot_PyPlot

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://modiasim.github.io/ModiaResult.jl/stable/index.html)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/ModiaSim/ModiaResult.jl/blob/master/LICENSE.md)

ModiaPlot_PyPlot is part of [ModiaSim](https://modiasim.github.io/docs/)
and provides convenient line plots of simulation results with package
[PyPlot](https://github.com/JuliaPy/PyPlot.jl).

The package is typially not directly used, but is activated via package
[ModiaResult](https://github.com/ModiaSim/ModiaResult.jl).
For details of the installation and the usage, 
see the ModiaResult [documentation](https://modiasim.github.io/ModiaResult.jl/stable/index.html).


## Example

Once a result data structure `result` with signals `sigA(t), sigB(t), sigC(t), r[3](t)`
is available and `PyPlot` selected for plotting, 

```julia
import ModiaResult
using  Unitful

# Define plotting software globally
ModiaResult.activate("PyPlot") # or ENV["MODIA_PLOT"] = "PyPlot"

# Define result data structure
...
                
# Generate "using ModiaPlot_PyPlot"                              
ModiaResult.@usingModiaPlot
```

then the following command

```julia
plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])
```

generates the following image (labels are automatically constructed):

![SegmentedSignalsPlot](docs/resources/images/segmented-signals-plot.png)


## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)
