module SNNPlots

export SNNPlots

using Plots
using ColorSchemes
using LaTeXStrings 
using Measures
using YAML
using XLSX
using DrWatson

@info "using Plots and plot functions"

include("load_MPI_palette.jl")
include("conversion.jl")
include("utils.jl")
include("default_plots.jl")
include("utils.jl")
include("raster.jl")
include("recognition.jl")
include("populations.jl")

end
# include("dataframes.jl")
# include("rate.jl")
# include("weights.jl")
# include("colors.jl")
# include("all_plots.jl")
# include("track_neurons.jl")


# default(legendfontsize=12, bglegend=:transparent, fglegend=:transparent,grid=false, guidefontsize = 18, tickfontsize=13, frame=:axes )
# pyplot()


# macro makeplot(p, folder,name)
#     return :( $p,savefig( joinpath($folder,$name *".pdf")) )
# end
