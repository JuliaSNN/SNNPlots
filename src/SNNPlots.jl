module SNNPlots

using Plots
using ColorSchemes
using LaTeXStrings
using Measures
using YAML
using XLSX
using DrWatson


include("load_MPI_palette.jl")
include("conversion.jl")
include("utils.jl")
include("parallel_coordinates.jl")
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

export SNNPlots, Plots
export plot, plot!

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
