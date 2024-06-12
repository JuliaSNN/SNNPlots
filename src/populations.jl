import StatsBase: normalize
using Statistics
function histogram_population!(
    p::Plot,
    populations;
    func,
    EdgeRange = nothing,
    get_N = false,
    max_x = nothing,
    max_y = nothing,
    kwargs...,
)
    if isnothing(EdgeRange)
        firstEdge = minimum(func.(vcat(populations...))) * 0.95
        lastEdge = maximum(func.(vcat(populations...))) * 1.05
        lastEdge = isnothing(max_x) ? lastEdge : max_x
        lastEdge = isnothing(max_y) ? lastEdge : max_y
        binSize = (lastEdge - firstEdge) / 60
        EdgeRange = (firstEdge:binSize:lastEdge)
    end
    hs = []
    for s in populations
        h = StatsBase.fit(Histogram, func.(s), EdgeRange) # |> x->normalize(x, mode=:density)
        push!(hs, h.weights)
    end
    v = hcat(hs...)
    N = (1 + maximum(maximum(sum(hs, dims = 1))) ÷ 150) * 150
    yticks = ([N], [N])
    plot!(p)
    h = groupedbar!(
        v,
        ylabel = "Count",
        legend = :topleft,
        size = (400, 400),
        label = "",
        bar_position = :stack,
        lw = 1,
        lc = :match,
        yticks = yticks,
        bar_width = 1;
        kwargs...,
        ylims = (0, N),
    )
    if get_N
        plot!(yrotation = 90)
        return p, N
    end
    return p
end
#   xticks=:none, frame=:none, xlims=(1,length(EdgeRange)))

histogram_population(args...; kwargs...) = histogram_population!(plot(), args...; kwargs...)



function get_proj_noproj_spiketimes(; sample, types = [:exc, :pv, :sst])
    @unpack stim, seq, net, dends, learn, store, W = sample.network

    spiketimes = TNN.merge_spiketimes(sample.spikes, pop = :ALL, type = types)
    phonemes_neurons = Set(vcat(seq.populations[get_phonemes(seq)]...))
    words_neurons = Set(vcat(seq.populations[get_words(seq)]...))
    all_neurons = Set(1:net.tripod)
    non_pops_neurons = setdiff(all_neurons, union(words_neurons, phonemes_neurons))
    populations = []
    n = 1
    if :exc in types
        sp = spiketimes[collect(phonemes_neurons)]
        sw = spiketimes[collect(words_neurons)]
        sn = spiketimes[collect(non_pops_neurons)]
        push!(populations, sw) # stimulated
        push!(populations, sp) # stimulated
        push!(populations, sn) # no stimulated
        n += getfield(net, :tripod)
    end
    if :pv in types
        nn = getfield(net, :pv)
        s = spiketimes[n:(n+nn-1)]
        push!(populations, s)
        n += nn
    end
    if :sst in types
        nn = getfield(net, :sst)
        s = spiketimes[n:(n+nn-1)]
        push!(populations, s)
        n += nn
    end
    if :exc in types
        tt = [:words, :phonemes, :none]
        types = append!(tt, types[2:end])
    end

    return populations, types
end
