using PlotlyJS
using ElectronDisplay
using JLD2
"""
Assuming you have already created a connectome and you have formated the date into three seperate dense vectors, which are encoded as the 1,2 and 3rd elements of the List of Lists represented by the loaded variable 
"connections" Make a Sankey diagram from the given information about pre synaptic and post synaptic connection densities.
Network layer sources (pre-synaptic densities), network layer targets (post synaptic densities), and ribbon thickness (values).
"""
function sankey_applied(from_jld=true)
    if from_jld
        @load "sankey_data.jld" _ _ connections _
    else
        throw("implement connectome creating code here."))
    end
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