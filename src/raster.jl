using Plots
#=======================
	 Raster Plot
=======================#
import Plots: Series, Plot, Subplot

import TripodNetwork: NNSpikes, Encoding, Spiketimes
import TripodNetwork: get_words, get_phonemes, get_chunks_with_intervals
import TripodNetwork: merge_spiketimes, read, get_spikes_in_interval

using Logging


"""
	raster_both_populations(spikes::Vector{NNSpikes}, seq::Encoding, interval::Vector=[0s,1s]; kwargs...)

Plot the raster plot of the words and phonemes populations, in the interval `interval`.
The 'spikes' argument is a NNSpikes object, which contains the pointer to spiketimes of the network. 
The 'interval' argument is expected to receive time units (ms or s).
"""
function raster_both_populations(
    spikes::Vector{NNSpikes},
    seq::Encoding,
    interval::Vector = [0second, 1second];
    rec_interval = 5000,
    delay = 100ms,
    kwargs...,
)
    p = let
        p1 = raster_populations(spikes, seq, interval = interval, target = "phs"; kwargs...)
        p2 = raster_populations(
            spikes,
            seq,
            interval = interval,
            target = "words",
            delay = delay;
            kwargs...,
        )
        plot!(p1, xticks = :none)
        plot!(p1, xaxis = "")
        plot(p1, p2, layout = (2, 1))
    end
    plot!(; kwargs...)
    plot!(size=(1200,800))
    return p
end


function plot_sequence(
    seq::Encoding,
    interval::AbstractVector;
    target = "phs",
    kwargs...,
)

    ## Get the words or phs population
    if target == "words"
        _targets = get_words(seq)
        _target = 1
    elseif target == "phs"
        _targets = get_phonemes(seq)
        _target = 2
    else
        throw(DomainError("Set target to 'words' or 'phs'"))
    end
    active_pops = sort(_targets)
    lengths = [length(seq.populations[x]) for x in active_pops]
    labels = string.([seq.mapping[x] for x in active_pops])

    ax = plot()
    for (n, pop) in enumerate(seq.sequence[_target, :])
        _y = findfirst(x -> x == pop, active_pops)
        if !isnothing(_y)
            _y += -1
            y, h = length(seq.populations[pop]) .* (_y, 1)
            plot!(
                ax,
                rectangle(50ms, h, (n - 1) * 50ms, y),
                alpha = 0.2,
                c = mpi_palette[2],
                msc = mpi_palette[2],
            )
        end
    end

    plot!(yticks = (cumsum(lengths) .- mean(lengths) / 2, labels))
    plot!(xlims = interval, ylabel = target * " pops")
    plot!(xticks = (range(interval..., 5), range(interval..., 5) ./ 1000))
    plot!(legend=false)
end
  

function raster_populations(
    spikes::Vector{NNSpikes},
    seq::Encoding;
    target,
    interval::AbstractVector,
    delay::T = 0,
    kwargs...,
) where {T<:Real}

    ii = get_chunks_with_intervals(interval, spikes)
    # interval = isnothing(interval) ? [tt-5,tt] : interval
    if length(ii) == 0
        throw(DomainError("No spikes in the interval"))
    elseif length(ii) > 1
        @warn "More than one interval found. The merge of spikes is slow."
        spikes = merge_spiketimes(spikes[ii], pop = :ALL)
    elseif length(ii) == 1
        i = ii[1]
        @warn "Spikes in $i"
        spikes = read(spikes[i]).exc
    end

    @info "Raster plot of $target populations, "

    ## Get the words or phs population
    if target == "words"
        _targets = get_words(seq)
        _target = 1
    elseif target == "phs"
        _targets = get_phonemes(seq)
        _target = 2
    else
        throw(DomainError("Set target to 'words' or 'phs'"))
    end
    active_pops = sort(_targets)
    labels = string.([seq.mapping[x] for x in active_pops])
    lengths = [length(seq.populations[x]) for x in active_pops]

    neurons = []
    for pop in active_pops
        push!(neurons, seq.populations[pop]...)
    end

    ax = plot()
    for (n, pop) in enumerate(seq.sequence[_target, :])
        _y = findfirst(x -> x == pop, active_pops)
        if !isnothing(_y)
            _y += -1
            y, h = length(seq.populations[pop]) .* (_y, 1)
            plot!(
                ax,
                rectangle(50ms, h, (n - 1) * 50ms + delay, y),
                alpha = 0.2,
                c = mpi_palette[2],
                msc = mpi_palette[2],
            )
        end
    end

    # _start = spikes[timeframe].tt-spikes[1].tt
    # _end = spikes[timeframe].tt
    raster_plot!(ax, spikes[neurons], interval)
    plot!(yticks = (cumsum(lengths) .- mean(lengths) / 2, labels))
    plot!(xlims = interval, ylabel = target * " pops")
    plot!(xticks = (range(interval..., 5), range(interval..., 5) ./ 1000))
    return ax
end

raster_plot!(ax::Plot, args...; kwargs...) = raster_plot(args...; ax = ax, kwargs...)


### Raster plot with all populations
function raster_plot(
    spikes::Vector{NNSpikes},
    interval = [0second, 1second];
    ax = plot(),
    kwargs...,
)
    ii = get_chunks_with_intervals(interval, spikes; kwargs...)
    if length(ii) == 0
        throw(DomainError("No spikes in the interval"))
    elseif length(ii) > 1
        @warn "More than one interval found. The merge of spikes is slow."
        spikes = (
            exc = merge_spiketimes(spikes[ii], type = :exc, pop = :ALL),
            sst = TNN.merge_spiketimes(spikes[ii], type = :sst, pop = :ALL),
            pv = TNN.merge_spiketimes(spikes[ii], type = :pv, pop = :ALL),
        )
    elseif length(ii) == 1
        i = ii[1]
        spikes = read(spikes[i])
    end
    npop = [0, length(spikes.exc), length(spikes.pv), length(spikes.sst)]
    _x, _y = Float32[], Float32[]
    _c = []
    y0 = Int32[0]
    colors = [:black, mpi_palette[5], mpi_palette[7]]
    for (_n, pop) in enumerate([spikes.exc, spikes.pv, spikes.sst])
        pop = get_spikes_in_interval(pop, interval)
        for n in eachindex(pop)
            for ft in pop[n]
                push!(_x, ft)
                push!(_y, n + cumsum(npop)[_n])
                push!(_c, colors[_n])
            end
        end
        push!(y0, npop[_n])
    end
    plt = scatter!(
        ax,
        _x,
        _y,
        m = (1),
        msc = _c,
        mc = _c,
        leg = :none,
        xaxis = ("Time (s)", (0, Inf)),
        yaxis = ("neuron",),
    )
    _y0 = y0[2:end]
    plot!(; kwargs...)
    plot!(yticks = (cumsum(_y0) .+ npop[2:end] ./ 2, ["exc", "pv", "sst"]))
    # !isempty(_y0) && hline!(plt, cumsum(_y0), linecolor = :red)
    plot!(xlims = interval)
    plot!(xticks = (interval, interval ./ 1000))
end

function raster_plot(
    pop::Spiketimes,
    interval;
    ax = plot(),
    mc = :black,
    y0 = 0,
    alpha = 0.4,
    kwargs...,
)
    _x, _y = Float32[], Float32[]
    pop = get_spikes_in_interval(pop, interval)
    for n in eachindex(pop)
        for ft in pop[n]
            push!(_x, ft)
            push!(_y, n + y0)
        end
    end
    plt = scatter!(
        _x,
        _y,
        m = (2, mc),
        msc = mc,
        leg = :none,
        alpha = alpha,
        xaxis = ("Time (s)"),
        yaxis = ("neuron",),
    )
    plot!(; kwargs...)
    return plt
end




# function raster_plot(spikes::NNSpikes, interval=[0,1]; ax=plot(), kwargs...)
# 	npop = [0, length(spikes.exc), length(spikes.sst), length(spikes.pv)]
# 	_x, _y, _c = Float32[], Float32[], RGB[]
#     y0 = Int32[0]
# 	pops = [ ]
# 	for pop in [spikes.exc, spikes.sst, spikes.pv]
# 		push!(pops,pop)
# 	end
# 	colors = [RGB(0,0,0), RGB(0,0,1), RGB(1,0,0)]
# 	for (_n, pop) in enumerate(pops)
# 	    for n in eachindex(pop)
# 			for ft in pop[n]
# 				push!(_x,ft*1e-3)
# 				push!(_y,n+cumsum(npop)[_n])
# 				push!(_c, colors[_n])
# 			end
# 		end
# 		push!(y0,npop[_n])
# 	end
#     plt = scatter!(ax, _x, _y, m = (1, _c), msc=_c, leg = :none,
#                   xaxis=("Time (s)", (0, Inf)), yaxis = ("neuron",))
#     _y0 = y0[2:end]
# 	plot!(;kwargs...)
# 	plot!(xlims=interval)
# 	plot!(yticks=(cumsum(_y0) .+ npop[2:end]./2, ["exc", "sst", "pv"]))
#     !isempty(_y0) && hline!(plt, cumsum(_y0), linecolor = :red)
# end

# ### Raster plot with neurons ordered by external input
# function raster_plot_order(pop::Spiketimes, order=nothing; mss=1, ax=plot(), c=:black, kwargs...)
#     _x, _y, _c = Float32[], Float32[], []
#     y0 = Int32[0]
#     neurons = order == nothing ? (1:length(pop)) : order  
#     for (n, cell) in enumerate(neurons)
#         for ft in pop[cell]
#             push!(_x,ft*1e-3)
#             push!(_y,n)
#             !isa(c,Symbol) && (push!(_c, c[cell]))
#         end
#     end
#     c = isa(c,Symbol) ? c : _c
#     plt= scatter!(ax, _x , _y, m = (mss, c), msc=c, leg = :none,
#                   xaxis=("Time (s)" ), yaxis = ("neuron",); kwargs...)
# 	return plt
# end


# # # spikes_plot(SPIKE_TIMES)
# # function plot_spikes(spike_times)
# #     s = plot()
# #     for n in eachindex(spike_times)
# #         for times in spike_times[n]
# #             plot!(s,[times, times],[n+0.1,n+0.9], color=:black, label="")
# #         end
# #     end
# #     s = plot!(s, xaxis=false,yaxis=false)
# #     return s
# # end



# # function raster_plot(spikes::Vector{NNSpikes}, timeframe::Int, store::StoreParams)
# # 	read_spikes = read(spikes[timeframe])
# # 	xlims = (10e-4(read_spikes.tt-store.interval),(read_spikes.tt)*10e-4)
# # 	@show read_spikes
# # 	return raster_plot(read_spikes, xlims=xlims)
# # end
