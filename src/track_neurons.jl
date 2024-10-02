
##
# scatter(all_v1)
# scatter(all_v2)
default(grid = true, guidefontsize = 6, legendfontsize = 5, titlefontsize = 7)

function plot_voltage(trackers::Vector{NNTracker}, seq::Encoding, timeframe; kwargs...)

    p = plot_voltage(read(trackers[timeframe], :voltage), seq; kwargs...)
    return p

end

function plot_stimuli(
    trackers::Vector{NNTracker},
    seq::Encoding,
    timeframe;
    index::Int = 1,
    dt = 0.1,
    ax = plot(),
)

    p = plot_stimuli(read(trackers[timeframe]), seq; index = index, dt = dt)
    return p

end

function get_ext_stimulus_time(
    seq::Encoding,
    neuron::Int,
    pop_index::Int,
    interval,
    y_shift = 0;
    c_palette = [:red, :blue, :green],
)
    population_compartments = get_target_dendrites(seq)
    target_compartment = population_compartments[pop_index]
    if neuron in target_compartment[1]
        cbars = :black
    elseif neuron in target_compartment[2]
        cbars = c_palette[1]
    elseif neuron in target_compartment[3]
        cbars = c_palette[3]
    else
        throw("track neuron has not matching compartment synaptic weight")
    end
    sign = pop_index > length(get_words(seq)) ? 2 : 1
    up_states =
        findall(x -> seq.sequence[sign, x] == pop_index, seq_in_interval(seq, interval))
    x_stim = [interval[1] + 5_0 * (x - 1) .+ (51:10:101) for x in up_states] ./ 1000
    y_stim = [10 * ones(6) .+ y_shift for x in up_states]
    return x_stim, y_stim, cbars
end

function plot_voltage(
    tracker::Tracker,
    seq::Encoding;
    pop::Int = 1,
    index = 1,
    dt = 0.1,
    ax = plot(),
    xlims = [0, 1],
    c_palette = [:red, :blue, :green],
)
    @unpack voltage, stimuli, track_neurons, interval = tracker
    neuron = track_neurons[index]
    pops = findall(x -> neuron ∈ x, seq.populations)
    pop = pops[pop]
    @info "plotting voltage for neuron $neuron in population $pop, also in populations $pops"

    xs = range(interval[1] / 1000, interval[2] / 1000, tracker.interval_steps)
    ## Index is the population index and the neurons in track_neurons are the first M=1 neurons of the indexed population
    # isnothing(track_pops) && (throw(ErrorException("Set the populations corresponding to the index  ")))
    # for (n_pop,pop) in enumerate(track_pops[index])
    stimuli = []
    n_pop = 1
    push!(
        stimuli,
        get_ext_stimulus_time(
            seq,
            neuron,
            pop,
            interval,
            5 * (n_pop - 1),
            c_palette = c_palette,
        ),
    )
    # end
    # return stimuli
    p1 = begin
        p1 = plot!(ax)
        plot!(xs, voltage[index, 2, :], label = "d1")
        plot!(xs, voltage[index, 1, :], c = :black, label = "s")
        plot!(xs, voltage[index, 3, :], label = :d2)
        plot!(xs, voltage[index, 1, :], c = :black, label = "s")
        for (x_stim, y_stim, cbars) in stimuli
            plot!(x_stim, y_stim, c = cbars, lw = 8, label = "")
        end
        # scatter!(voltage[nn,2,:],msize=0.04, label="", c=:black)
        # scatter!(voltage[nn,3,:],msize=0.04, label="", c=:black)
        plot!(ylabel = "Membrane (mV)")
        my_interval = interval[2] / 1000 - interval[1] / 1000
        _my_lims = (
            interval[1] / 1000 + my_interval * xlims[1],
            interval[1] / 1000 + my_interval * xlims[2],
        )
        plot!(ylims = (-75, 20))
    end
    plot!(xlims = _my_lims)
    tt = (interval[end] - interval[1]) ÷ 5
    tts = interval[1]:tt:interval[end]
    xticks = (tts, string.(round.(collect(tts) ./ 1000, digits = 1)))
    plot!(xlabel = "Time (s)", legend = false)
    return p1
    # return plot!(p1, xticks=xticks, legend=false)
end

function plot_stimuli(tracker::Tracker, seq::Encoding; index::Int = 1, dt = 0.1)
    @unpack stimuli, track_neurons, interval = tracker
    nn = index
    xs = range(interval[1], interval[2], tracker.interval_steps)
    ## Index is the population index and the neurons in track_neurons are the first M=1 neurons of the indexed population
    target_dendrites = get_target_dendrites(seq)[index]
    sign = index > get_words(seq)[end] ? 2 : 1
    up_states = findall(x -> seq.sequence[sign, x] == index, seq_in_interval(seq, interval))
    x_stim = [interval[1] + 5_0 * (x - 1) .+ (0:10:50) for x in up_states]
    y_stim = [-30 * ones(6) for x in up_states]

    soma_only = sum(stimuli[nn, 3, :]) < 1
    if soma_only
        p1 = begin
            a = plot(xs, stimuli[nn, 1, :], c = :red)
            plot!(xs, stimuli[nn, 2, :], alpha = 0.5, c = :blue, xticks = :none)
            plot!(x_stim, y_stim, c = c_palette[2], lw = 8, label = "")
        end
    else
        p1 = begin
            a = plot(xs, stimuli[nn, 1, :], c = :red)
            plot!(xs, stimuli[nn, 2, :], alpha = 0.5, c = :blue, xticks = :none)
            b = plot(xs, stimuli[nn, 3, :], c = :red)
            plot!(
                xs,
                stimuli[nn, 4, :],
                alpha = 0.5,
                c = :blue,
                xticks = :none,
                ylabel = "Inputs",
            )
            if track_neurons[index] in target_dendrites[1]
                plot!(x_stim, y_stim, c = c_palette[2], lw = 8, label = "")
            end
            c = plot(xs, stimuli[nn, 5, :], c = :red)
            plot!(xs, stimuli[nn, 6, :], alpha = 0.5, c = :blue)
            if track_neurons[index] in target_dendrites[2]
                plot!(x_stim, y_stim, c = c_palette[3], lw = 8, label = "")
            end
            plot(a, b, c, layout = (3, 1), alpha = 0.3, xticks = :none)
        end
    end

    plot!(xlims = interval)
    tt = (interval[end] - interval[1]) ÷ 5
    tts = interval[1]:tt:interval[end]
    xticks = (tts, string.(round.(collect(tts) ./ 1000, digits = 1)))
    return plot!(p1, xticks = xticks, legend = false)
end

function plot_conductance(tracker::Tracker, seq::Encoding; interval::Tuple, index::Int = 1)
    @unpack gs, g1, g2, currents, track_neurons = tracker
    nn = index
    p2 = begin
        plot()
        c = [:darkred :red :blue :blue]
        ls = [:solid :dash]
        ll = ["AMPA" "NMDA" "GABAa" "GABAb"]
        plot(
            plot(gs[nn, :, :]', c = c, ls = ls, title = "", xticks = :none, labels = ll),
            plot(
                g1[nn, :, :]',
                c = c,
                ls = ls,
                title = "",
                xticks = :none,
                legend = false,
                ylabel = "Syn Conductance",
            ),
            plot(g2[nn, :, :]', c = c, ls = ls, title = "", legend = false),
            layout = (3, 1),
        )
        plot!(xlims = interval)
    end
    p3 = begin
        plots = []
        for x = 0:2
            _p = plot()
            for i in [1, 4] .+ x
                plot!(currents[nn, i, :], label = "")
            end
            plot!(currents[nn, 1+x, :] + currents[nn, 4+x, :], label = "", c = :black)
            # plot!(ylims=(-100,100))
            push!(plots, _p)
            plot!(xlims = interval)
        end
        plot!(plots[2], ylabel = "Syn current", xticks = :none)
        plot!(plots[1], xticks = :none)
        plot!(plots[3], xlabel = "Time (0.1 ms)")
        plot(plots..., layout = (3, 1))
    end
    ss = plot(p2, p3, layout = (2, 1), tickfontsize = 4)
end
#
# 	p_inh = begin
# 		nnI = length(track_neurons)-1
# 		p1 = begin
# 			p = plot()
# 			plot!(voltage[nnI,2,:], label="SST")
# 			plot!(voltage[nnI,3,:], label="PV")
# 			# scatter!(voltage[nn,2,:],msize=0.04, label="", c=:black)
# 			# scatter!(voltage[nn,3,:],msize=0.04, label="", c=:black)
# 			plot!(ylabel="Membrane")
# 			plot!(xlims=interval)
# 			plot!(ylims=(-90,5))
# 			p2 = begin
# 				# a = plot( rollmean(stimuli[nn,1,:],50), c=:red)
# 				# 	plot!(rollmean(stimuli[nn,2,:],50) , c=:blue, xticks=:none)
# 				b = plot(stimuli[nnI,3,:] , c=:red)
# 					plot!(stimuli[nnI,4,:], c=:blue, xticks=:none, ylabel="SST")
# 				c = plot(stimuli[nnI,5,:], c=:red)
# 					plot!(stimuli[nnI,6,:],c=:blue, ylabel="PV")
# 				plot(b,c, layout=(2,1), alpha=0.3, legend=false)
# 				plot!(xlims=interval)
# 			end
# 			plot(p,p2, layout=(2,1))
# 		end
# 		p3 = begin
# 			c = [:darkred :red :blue :blue]
# 			ls = [:solid :dash]
# 			ll = ["AMPA" "NMDA" "GABAa" "GABAb"]
# 			plot(
# 			plot(g_pv[nnI,:,:]', c=c, ls=ls, title="",legend=false, ylabel="Syn Conductance"),
# 			plot(g_sst[nnI,:,:]', c=c, ls=ls,legend=false),
# 			 layout=(2,1))
# 			plot!(xlims=interval)
# 		 end
# 		p4 = begin
# 			plots = []
# 			for x in [0,2]
# 				_p = plot(currents[nnI,3+x,:], label="")
# 				_p = plot!(currents[nnI,4+x,:], label="")
# 				# plot!(currents[nnI,3+x,:]+currents[nn,4+x,:], c=:black)
# 				# plot!(ylims=(-100,100))
# 				push!(plots,_p)
# 			end
# 			plot!(xlims=interval)
# 			plot!(plots[2],ylabel="Syn current")
# 			plot(plots..., layout=(2,1))
# 		end
# 		plot!(xlims=interval)
# 		plot(p1,p3,p4, layout=(3,1))
# 	end
#
# 	ss = plot(p_tripod,p_inh, layout=(1,2), tickfontsize=4)
# 	savefig(ss,joinpath(@__DIR__,"track_neuron_"*replace(store.id, "/"=>"_")*"_neuron_$nn.pdf"))
# end
# ##
#
# support_plot = begin
# 	sp = let
# 		sp1 = plot(voltage[nn,2,:], label="d1_before")
# 			 plot!(voltage[nn,3,:], label="d2_before")
# 			plot!(xticks=:none, xaxis=false)
# 			plot!(support_var[nn,9,:], label="d1_after_curr")
# 			 plot!(support_var[nn,10,:], label="d2_after_curr")
# 			plot!(xticks=:none, xaxis=false)
# 		sp2 = plot(support_var[nn,3,:], title="d1_after")
# 			plot!(support_var[nn,4,:], title="d2_after" )
# 			plot!(xticks=:none, xaxis=false)
# 		sp3 = plot(support_var[nn,5,:], title="d1_correct",legend=false)
# 			plot!(support_var[nn,6,:], title="d2_correct",legend=false)
# 		plot(sp1, sp2, sp3, layout=(3,1))
# 		end
# 	dp = let
# 		sp1 = plot(support_var[nn,1,:],  title="Δd1 before",legend=false)
# 			plot!(sp1,support_var[nn,2,:],  title= "Δd2 before",legend=false)
# 			plot!(xticks=:none, xaxis=false)
# 		sp2 = plot(support_var[nn,7,:],  title="Δd1 after",legend=false)
# 			plot!(sp2,support_var[nn,8,:],  title="Δd2 after ",legend=false)
# 		plot(sp1, sp2, layout=(2,1))
# 		end
# 	ptot  = plot(sp, dp, layout=(1,2))
# 	plot!(xlims=interval)
# 	savefig(ptot, joinpath(@__DIR__,"support.pdf"))
# end
#
# ##
# # path ="/home/cocconat/Documents/Research/phd_project/simulations/spiking/tripod_network/data/analysis/lkd2014_dend"
# store = StoreParams(id=path,  interval=15000 )
# stim, seq, net, dends, learn, store = load_params(store.path)
# s_t = 1
# spikes = load_spikes(store.data)
# r = load_rates(store.data)
# rp = raster_plot(spikes, s_t,store)
# plot!(rp, xaxis=:none, xlabel="")
# vline!(rp,collect(0.:0.05:1.), c=:red, ls=:dash)
# plot!(rp, xlims=interval./10000)
#
# rboth = raster_both_populations(spikes, seq, s_t, store)
# plot!(rboth, xaxis=:none, xlabel="")
# plot!(rboth, xlims=interval./1000)
# # vline!(rp,collect(0.:0	.05:1.), c=:red, ls=:dash)
# r_plot= begin
# 	plot()
# 	for i in 1:length(r)
# 		plot!(r[i][2])
# 		plot!(r[i][3])
# 		plot!(r[i][4])
# 	end
# 	# plot!(yticks =(-20:-20:-80, 10:10:40) )
# 	plot!(legend=false, ylabel="Hz")
# end
# layout= @layout [
# 				a{0.3h}
# 				[b{0.5w}  c{0.5w}]
# ]
# ss = plot(r_plot, rp,rboth, layout=layout)
# savefig(ss,joinpath(@__DIR__,"raster_"*replace(store.id, "/"=>"_")*".pdf"))
