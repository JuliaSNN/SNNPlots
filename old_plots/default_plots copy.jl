# Copyright (c) 2022 Alessio Quaresima
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


PLOT_SIZE = one_column_size
mpi_palette = palette(vcat([c.full for c in mpi_colors], [c.tint for c in mpi_colors]))
default(
    size = PLOT_SIZE,
    dpi = 300,
    fontfamily = "sans-serif",
    # font=font(18, "sans-serif"), 
    palette = mpi_palette,
    legend = :bottomright,
    legendfontsize = 15,
    titlefontsize = 18,
    guidefontsize = 18,
    tickfontsize = 15,
    linewidth = 2,
    markersize = 4,
    grid = false,
    fg_legend = :transparent,
    # palette = mpi_palette,#(:tab10), 
    frame = :box,
    margins = 5mm,
)


rectangle(w, h, x, y) = Shape(x .+ [0, w, w, 0], y .+ [0, 0, h, h])

nmda_color = mpi_palette[3]
ampa_color = mpi_palette[5]

# updown_plot = YAML.load_file(projectdir("conf.yaml"))["updown_plot"]
