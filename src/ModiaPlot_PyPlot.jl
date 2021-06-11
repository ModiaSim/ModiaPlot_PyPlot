# License for this file: MIT (expat)
# Copyright 2017-2021, DLR Institute of System Dynamics and Control
                           
# ToDo:
# MatplotlibDeprecationWarning: Adding an axes using the same arguments as a previous axes currently 
# reuses the earlier instance.  In a future version, a new instance will always be created and returned.  
# Meanwhile, this warning can be suppressed, and the future behavior ensured, by passing a unique label to each axes instance.
#
# Description how to get rid of the warning:
# https://stackoverflow.com/questions/46933824/matplotlib-adding-an-axes-using-the-same-arguments-as-a-previous-axes#  

                           
module ModiaPlot_PyPlot

# It seems that rcParams settings has only an effect, when set on PyPlot in Main
import ModiaResult
import Measurements
import MonteCarloMeasurements
using  Unitful

import PyCall
import PyPlot

set_matplotlib_rcParams!(args...) = 
   merge!(PyCall.PyDict(PyPlot.matplotlib["rcParams"]), Dict(args...))


include("$(ModiaResult.path)/src_plot/plot.jl")


function plotOneSignal(xsig, ysig, ysigType, label, MonteCarloAsArea)
    xsig2 = ustrip.(xsig)
    ysig2 = ustrip.(ysig)
	if typeof(ysig2[1]) <: Measurements.Measurement
		# Plot mean value signal
		xsig_mean = Measurements.value.(xsig2)
		ysig_mean = Measurements.value.(ysig2)
		curve = PyPlot.plot(xsig_mean, ysig_mean, label=label)

		# Plot area of uncertainty around mean value signal (use the same color, but transparent)
		color = PyPlot.matplotlib.lines.Line2D.get_color(curve[1])
		rgba  = PyPlot.matplotlib.colors.to_rgba(color)
		rgba2 = (rgba[1], rgba[2], rgba[3], 0.2)
		ysig_u   = Measurements.uncertainty.(ysig2)
		ysig_max = ysig_mean + ysig_u
		ysig_min = ysig_mean - ysig_u
		PyPlot.fill_between(xsig_mean, ysig_min, ysig_max, color=rgba2)

    elseif typeof(ysig2[1]) <: MonteCarloMeasurements.StaticParticles ||
           typeof(ysig2[1]) <: MonteCarloMeasurements.Particles
		# Plot mean value signal
		xsig_mean = MonteCarloMeasurements.mean.(xsig2)
		ysig_mean = MonteCarloMeasurements.mean.(ysig2)
        xsig_mean = ustrip.(xsig_mean)
        ysig_mean = ustrip.(ysig_mean)
		curve = PyPlot.plot(xsig_mean, ysig_mean, label=label)
        color = PyPlot.matplotlib.lines.Line2D.get_color(curve[1])
        rgba  = PyPlot.matplotlib.colors.to_rgba(color)

        if MonteCarloAsArea
            # Plot area of uncertainty around mean value signal (use the same color, but transparent)
    		rgba2 = (rgba[1], rgba[2], rgba[3], 0.2)
    		ysig_max = MonteCarloMeasurements.maximum.(ysig2)
	    	ysig_min = MonteCarloMeasurements.minimum.(ysig2)
            ysig_max = ustrip.(ysig_max)
            ysig_min = ustrip.(ysig_min)
    		PyPlot.fill_between(xsig_mean, ysig_min, ysig_max, color=rgba2)
        else
            # Plot all particle signals (use the same color, but transparent)
    		rgba2 = (rgba[1], rgba[2], rgba[3], 0.1)
            value = ysig[1].particles
            ysig3 = zeros(eltype(value), length(xsig))
            for j in 1:length(value)
                for i in eachindex(ysig)
                    ysig3[i] = ysig[i].particles[j]
                end
                ysig3 = ustrip.(ysig3)
                PyPlot.plot(xsig, ysig3, color=rgba2)
            end
        end

	else
        if typeof(xsig2[1]) <: Measurements.Measurement
            xsig2 = Measurements.value.(xsig2)
        elseif typeof(xsig2[1]) <: MonteCarloMeasurements.StaticParticles ||
               typeof(xsig2[1]) <: MonteCarloMeasurements.Particles
            xsig2 = MonteCarloMeasurements.mean.(xsig2)
            xsig2 = ustrip.(xsig2)
        end
        if ysigType == ModiaResult.Continuous
            PyPlot.plot(xsig2, ysig2, label=label)
        else # ModiaResult.Clocked
            PyPlot.plot(xsig2, ysig2, ".", label=label)
        end
	end
end



"""
    addPlot(names, result, grid, xLabel, xAxis)

Add the time series of one name (if names is one symbol/string) or with
several names (if names is a tuple of symbols/strings) to the current diagram
"""
function addPlot(collectionOfNames::Tuple, result, grid::Bool, xLabel::Bool, xAxis, prefix::AbstractString, reuse::Bool, maxLegend::Integer, MonteCarloAsArea::Bool)
    xsigLegend = ""
    xAxis2 = string(xAxis)
    nLegend = 0

    for name in collectionOfNames
        name2 = string(name)
        (xsig2, xsigLegend, ysig2, ysigLegend, ysigType) = ModiaResult.getPlotSignal(result, xAxis2, name2)
        if !isnothing(xsig2)
            xsig = xsig2[1]
            ysig = ysig2[1]
            if length(xsig2) > 1
                xNaN = convert(eltype(xsig), NaN)
                if ndims(ysig) == 1
                    yNaN = convert(eltype(ysig), NaN)               
                else
                    yNaN = fill(convert(eltype(ysig), NaN), 1, size(ysig,2))
                end
                   
                for i = 2:length(xsig2)
                    xsig = vcat(xsig, xNaN, xsig2[i])
                    ysig = vcat(ysig, yNaN, ysig2[i])
                end
            end
            
            nLegend = nLegend + length(ysigLegend)
            if ndims(ysig) == 1
				plotOneSignal(xsig, ysig, ysigType, prefix*ysigLegend[1], MonteCarloAsArea)
            else
                for i = 1:size(ysig,2)
					plotOneSignal(xsig, ysig[:,i], ysigType, prefix*ysigLegend[i], MonteCarloAsArea)
                end
            end
        end
    end

    PyPlot.grid(grid)
    if nLegend <= maxLegend
       PyPlot.legend()
    end

    if xLabel && !reuse && xsigLegend !== nothing
        PyPlot.xlabel(xsigLegend)
    end
end

addPlot(name::AbstractString, args...) = addPlot((name,)        , args...)
addPlot(name::Symbol        , args...) = addPlot((string(name),), args...)



#--------------------------- Plot function
function plot(result, names::AbstractMatrix; heading::AbstractString="", grid::Bool=true, xAxis="time",
              figure::Int=1, prefix::AbstractString="", reuse::Bool=false, maxLegend::Integer=10,
              minXaxisTickLabels::Bool=false, MonteCarloAsArea=false)

    set_matplotlib_rcParams!("axes.formatter.limits" => [-3,4],
                             "font.size"        => 8.0,
                             "lines.linewidth"  => 1.0,
                             "grid.linewidth"   => 0.5,
                             "axes.grid"        => true,
                             "axes.titlesize"   => "medium",
                             "figure.titlesize" => "medium")

    PyPlot.pygui(true) # Use separate plot windows (no inline plots)

                                     
    if isnothing(result)
        @info "The call of ModiaPlot.plot(result, ...) is ignored, since the first argument is nothing."
        return
    end
    xAxis2 = string(xAxis)
    PyPlot.figure(figure)
    if !reuse
       PyPlot.clf()
    end
    heading2 = ModiaResult.getHeading(result, heading)
    (nrow, ncol) = size(names)

    # Add signals
    k = 1
    for i = 1:nrow
        xLabel = i == nrow
        for j = 1:ncol
            ax = PyPlot.subplot(nrow, ncol, k)
            if minXaxisTickLabels && !xLabel
                # Remove xaxis tick labels, if not the last row
                ax.set_xticklabels([])
            end
            addPlot(names[i,j], result, grid, xLabel, xAxis2, prefix, reuse, maxLegend, MonteCarloAsArea)
            k = k + 1
            if ncol == 1 && i == 1 && heading2 != "" && !reuse
                PyPlot.title(heading2)
            end
        end
    end

    # Add overall heading in case of a matrix of diagrams (ncol > 1)
    if ncol > 1 && heading2 != "" && !reuse
        PyPlot.suptitle(heading2)
    end
end

showFigure(figure::Int) = nothing

function saveFigure(figureNumber::Int, fileName)::Nothing
    fullFileName = joinpath(pwd(), fileName)
    println("... save plot in file: \"$fullFileName\"")
    PyPlot.figure(figureNumber)
    PyPlot.savefig(fileName)
    return nothing
end


closeFigure(figure::Int) = PyPlot.close(figure)

"""
    closeAllFigures()

Close all figures.
"""
closeAllFigures() = PyPlot.close("all")


end