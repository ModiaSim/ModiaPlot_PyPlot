# License for this file: MIT (expat)
# Copyright 2017-2021, DLR Institute of System Dynamics and Control
                           
module ModiaPlot_PyPlot

#using Requires
            import PyPlot
            import PyCall
            
             set_matplotlib_rcParams!(args...) = 
                merge!(PyCall.PyDict(PyPlot.matplotlib["rcParams"]), Dict(args...))

           
# It seems that rcParams settings has only an effect, when set on PyPlot in Main
#function __init__()
   #if !Requires.isprecompiling()
   #     println("... 1")
   #     @eval Main begin

            
        
            set_matplotlib_rcParams!("axes.formatter.limits" => [-3,4],
                                     "font.size"        => 14.0,
                                     "lines.linewidth"  => 1.0,
                                     "grid.linewidth"   => 0.5,
                                     "axes.grid"        => true,
                                     "axes.titlesize"   => "medium",
                                     "figure.titlesize" => "medium")
          println("... 4")
        #end
    #end   

        println("... 2")    
  
    #@require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" begin
    #    @require PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0" include("pyplot_methods.jl")
    #end
#end


        println("... 3")
include("pyplot_methods.jl")
end
