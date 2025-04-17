module SNNPlots

    using Plots
    using ColorSchemes
    using LaTeXStrings
    using Measures
    using SpikingNeuralNetworks
    import SpikingNeuralNetworks: AbstractPopulation, AbstractStimulus, AbstractConnection
    using UnPack
    using Parameters

    include("plot.jl")
    include("extra_plots.jl")
    include("stdp_plots.jl")

    # include("conversion.jl")
    # include("utils.jl")
    # include("default_plots.jl")
    # include("src/utils.jl")
    # include("src/raster.jl")
    # include("src/recognition.jl")
    # include("src/populations.jl")

    default(fg_legend = :transparent)
    default(bg_legend = :transparent)
    default(xguidefontsize = 15)
    default(yguidefontsize = 15)
    default(ytickfontsize = 12)
    default(xtickfontsize = 12)
    default(legend_title_font_halign = :right)
    default(legend_title_font_pointsize = 14)
    default(legend_font_pointsize = 11)
    default(margins = 5Plots.mm)


end
