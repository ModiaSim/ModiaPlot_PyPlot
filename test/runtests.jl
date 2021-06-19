module Runtests

import ModiaResult
using  Test

@testset "Test ModiaPlot_PyPlot/test" begin
    ModiaResult.usePlotPackage("PyPlot")
    include("$(ModiaResult.path)/test/runtests_withPlot.jl")
    ModiaResult.usePreviousPlotPackage()
end

end