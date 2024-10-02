function make_plot(path)

    stim, seq, net, dends, learn, store = load_params(path)
    network = load_weights(store.data)
    spikes = load_spikes(store.data)
    analysis_path = get_path(store, "analysis")
    plot_path = get_path(store, "plots")


    t = length(spikes) - 10
    interval_ratio = 1.0
    for t = 1:10:length(spikes)
        p = raster_both_populations(spikes, seq, t, store)
        p_name = "raster_pops-$(spikes[t].tt/1000).pdf"
        savefig(p, joinpath(plot_path, p_name))
    end


    pop_weights = joinpath(analysis_path, "pop_weights.jld")
    wd1 = JLD.load(pop_weights, "d1")
    wd2 = JLD.load(pop_weights, :d2)
    _m = minimum([wd1[:]; wd2[:]])
    _M = maximum([wd1[:]; wd2[:]])
    ww = length(get_words(seq))
    p =
        (wd1, wd2, t) -> begin
            plot(
                heatmap(
                    wd1[t, :, :],
                    clims = (_m, _M),
                    cbar = false,
                    ylabel = "post-synaptic",
                    xlabel = "                               pre-synaptic",
                    title = "Timeframe: $t",
                ),
                heatmap(wd2[t, :, :], clims = (_m, _M), yticks = :none),
                xticks = ([5, ww + 7], ["words", "phonemes"]),
            )
            vline!([ww], c = :white, ls = :dash, lw = 2, label = "")
            hline!([ww], c = :white, ls = :dash, lw = 2, label = "")
        end
    anim = @animate for t = 1:length(network)
        p(wd1, wd2, t)
    end
    cgif = joinpath(plot_path, "connections_dendrites.gif")
    gif(anim, cgif, fps = 5)

    ws = JLD.load(pop_weights, "s")
    _m = minimum(ws[:])
    _M = maximum(ws[:])
    p =
        (ws, t) -> begin
            heatmap(
                ws[t, :, :],
                clims = (_m, _M),
                cbar = false,
                ylabel = "post-synaptic",
                xlabel = "                               pre-synaptic",
                title = "Timeframe: $t",
            )
            vline!([ww], c = :white, ls = :dash, lw = 2, label = "")
            hline!([ww], c = :white, ls = :dash, lw = 2, label = "")
        end
    anim = @animate for t = 1:length(network)
        p(ws, t)
    end
    cgif = joinpath(plot_path, "connections_soma.gif")
    gif(anim, cgif, fps = 5)

    ##
    # .- wd1[1,:,:])
    ## dendrites and weights
    # l1 = getfield.(dends[1],:l)
    # l2 = getfield.(dends[2],:l)
    # wμ1= mean(read(network[120],"e_d1_e"), dims=2)
    # wμ2 = mean(read(network[120],"e_d2_e"), dims=2)
    # title= corspearman(l1,wμ1), corspearman(l2,wμ2)
    # plot(
    # 	scatter(l1,wμ1, title="Corr ρ: "),
    # 	scatter(l2,wμ2)
    # )
    ##
    for (w_name, w_lab) in zip(
        [["e_if"], ["e_d1_e", "e_d2_e"], ["e_s_e"], ["e_d1_is", "e_d1_is"], ["e_s_is"]],
        [
            "fast_inhibition",
            "excitation_dend",
            "excitation_soma",
            "slow_inhibition_dend",
            "slow_inhibition_soma",
        ],
    )
        plots = []
        ll = length(network)
        for _w in w_name
            for x = 1:ll÷6:ll-ll÷6
                push!(
                    plots,
                    histogram(
                        getfield(read(network[x]), Symbol(_w))[:],
                        norm = true,
                        bins = 1:1:42,
                    ),
                )
                (x < length(spikes) - 20) && (plot!(xaxis = false))
                (x == 1) && (plot!(title = "W: $_w"))
            end
        end
        (length(w_name) == 2) && (plots = plots[[1, 7, 2, 8, 3, 9, 4, 10, 5, 11, 6, 12]])
        p = plot(plots..., leg = false, layout = (length(plots) ÷ 2, 2))
        savefig(p, joinpath(plot_path, "hist_$w_lab.pdf"))
    end
end

# 	plot(p)
#
# 	##
# 	# ## Import inhibitory weights
# 	# w_names = ["e_if" "e_d1_is" "e_d2_is"]
# 	w_t = global_weights(network[1:10:end], w_names )
# 	## Seq
# 	p = plot([getfield(w_t,k) for k in keys(w_t)], labels=w_names)
# 	q = plot_rate(spikes[1:20:end])
# 	plot(p,q, layout=(2,1))
# 	##
# 	for t in 1:10:length(spikes)
# 		_start = (spikes[t][1]-spikes[1][1])/1000
# 		_end = spikes[t][1]/1000
# 		p =raster_plot(readS(spikes[t])[1:3]...);
# 		plot!(xlims=(_start,_end))
# 		p_name = "raster_all-$(spikes[t][1]/1000).pdf"
# 		savefig(p, joinpath(plot_path, p_name))
# 	end
# 	##
# 	p = plot_rate(spikes)
# 	p_name = "rates.pdf"
# 	savefig(p, joinpath(plot_path, p_name))
#
# 	##
#
# 	results = joinpath(analysis_path,"pop_activity.h5")
# 	activity = read(h5open(results, "r")) |> x-> NamedTuple(Symbol(key)=>x[key] for key in keys(x))
# 	plot(mean(activity.base_rate,dims=2))
# 	size(activity.phonemes)[2]
# 	activity.seq
# 	scatter(activity.word[10,:])
# 	scatter()
#
# 	max_rate_words = [argmax(activity.word[:,x]) for x in 1:size(activity.word)[2]]
# 	max_rate_ph = [argmax(activity.phonemes[:,x]) for x in 1:size(activity.phonemes)[2]]
#
# 	maximum(activity.seq[1,:])
# 	scatter(activity.seq[2,:], max_rate_ph .+ 24, alpha=0.2, ms=5)
# 	countmap(string.(collect(zip(activity.seq[1,:], max_rate_words))))
# 	seq.lemmas
# 	length(get_phonemes(seq))
# 	length(get_words(seq))
# 	confusion_matrix(c[:,1], c[:,2])
# 	c = categorical(hcat(activity.seq[2,1:12000],max_rate_ph), ordered=true)
#
# 	any(isnothing.(max_rate_ph))
# 	 # alpha=0.2, ms=5, ylabel="Estimate", xlabe)
# 	categorical([1,10])
# 	##
# 	# end
# 	###
# end
