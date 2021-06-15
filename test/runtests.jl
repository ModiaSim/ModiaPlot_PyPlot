module Runtests

import ModiaResult

ModiaResult.activate("PyPlot")
include("$(ModiaResult.path)/test/runtests_withPlot.jl")
ModiaResult.activatePrevious()

end