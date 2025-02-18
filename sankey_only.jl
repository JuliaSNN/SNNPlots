using PlotlyJS
using ElectronDisplay
using JLD2
function sankey_applied()
    @load "sankey_data.jld" pre_layer_names post_layer_names connections labels
    sankey_trace = sankey(
        arrangement = "snap",
        node = attr(
            label    = labels,
            pad      = 15,
            thickness = 20,
            line     = attr(color = "black", width = 0.5)
        ),
        link = attr(
            source = [i[1] for i in connections],
            target = [i[2] for i in connections],
            value  = [i[3] for i in connections]
        )
    )
    plt = plot(sankey_trace)
    ElectronDisplay.display(plt)  # opens a new Electron window
end
sankey_applied()