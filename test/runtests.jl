module Runtests

import ModiaResult

ModiaResult.activate("PyPlot")
include("$(ModiaResult.path)/test_plot/all_tests.jl")
ModiaResult.activatePreviousPlotPackage()

end