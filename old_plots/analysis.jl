using DrWatson
@quickactivate "Tripod"

using Random, UnPack, Revise, YAML, Plots
using TripodNetwork

Random.seed!(1337)
conf = YAML.load_file(joinpath(projectdir(), "conf/paths.yaml"))
data = conf["dataset_path"]
path = joinpath(data, "test/lkd_soma")

# path = joinpath(data,"test/duarte_soma")
# path = joinpath(data,"test/lkd_soma")
# path = joinpath(data,"test/lkd_soma")
# path = datadir("simple", "lkd_network")
# path = joinpath(data,"test/lkd2014_dend")

## load observables
store = TNN.StoreParams(id = path, interval = 5000)
network = TNN.load_network(store.path, T = 0.0f0)
@unpack stim, seq, net, dends, learn, store = network
spikes = TNN.load_spikes(store.data)
W0 = read(TNN.load_weights(store.data)[1])
Ws = TNN.load_weights(store.data)
trackers = TNN.load_trackers(store.data)
states = TNN.load_states(store.data)
rates = TNN.load_rates(store.data)
##
p1 = TNN.plot_voltage(trackers, seq, 1, index = 14)
p2 = TNN.plot_stimuli(tracker, seq, index = 5)
TNN.raster_both_populations(spikes, seq, 1, store)
TNN.raster_plot(spikes, 1, store)

TNN.plot_rates(rates)
##

feats, labels, interval = TNN.spikes_to_features(
    spikes,
    network,
    timeshift = 0,
    sampling = 50,
    τ = 10,
    tt0 = 0,
    ttf = 60_000,
)
feats_r = TNN.apply_PCA(Float32.(feats), 500)
TNN.MultiLogReg(feats_r, labels)

##
# spikes
scatter(mean(feats[:, 1:500], dims = 2))
scatter!(mean(feats[:, 5_01:end], dims = 2))
feats[:, 5_01:end]

##
feats, labels, n_neurons = TNN.states_to_features(states)
feat_s = TNN.apply_PCA(feats, 800)
TNN.MultiLogReg(feats_s, labels)

##
TNN.population_activity(store; ttf = 60_000)
##
wd1 = TNN.epop_cluster_history(seq, Ws, "e_s_e")


heatmap(wd1[59, :, :])



##

# function MultiLogReg(
#     X::Union{Matrix{Float64},Matrix{Float32}},
#     labels;
#     λ = 0.5::Float64,
#     test_ratio = 0.7,
# )

hcat(signs...)
@show interval
plot(interval, rates[1, :])
scatter!(read(spikes[1]).exc[1], fill(10, 18))
scatter!(read(spikes[2]).exc[1], fill(10, 18))
# plot!(xlims=(1,700))

ceil(0)
TNN.get_signs_at_time(50, network.seq)
network.seq.sequence

TNN.get_isi(spikes[1], :exc)


plot(25:50:200, TNN.convolve([50.0f0], interval = 25:50:200, τ = 15))
plot!(25:2:200, TNN.convolve([50.0f0], interval = 25:2:200, τ = 15))
##
W = read(Ws[55])
@unpack seq, dends = network
@unpack stdp, istdp = network.learn

p_is = plot(
    histogram(W.e_s_is[:], bins = istdp.j⁻:istdp.j⁺, title = "IS->E", titlefontsize = 12),
    histogram(W.e_d1_is[:], bins = istdp.j⁻:(istdp.j⁺+3)),
    histogram(W.e_d2_is[:], bins = istdp.j⁻:(istdp.j⁺+3)),
    yaxis = false,
    layout = (3, 1),
    legend = false,
)

p_if = plot(
    histogram(W.e_if[:], bins = istdp.j⁻:istdp.j⁺, title = "IF->E", titlefontsize = 12),
    yaxis = false,
    layout = (3, 1),
    legend = false,
)

p_exc = plot(
    histogram(W.e_s_e[:], bins = stdp.j⁻:stdp.j⁺, title = "E->E", titlefontsize = 12),
    histogram(W.e_d1_e[:], bins = stdp.j⁻:stdp.j⁺),
    histogram(W.e_d2_e[:], bins = stdp.j⁻:stdp.j⁺),
    yaxis = false,
    layout = (3, 1),
    legend = false,
)

layout = @layout [
    a{0.5w} b{0.5w}
    c{0.3h}
]

histogram(W.e_s_e[:])


plot(p_exc, p_is, p_if, layout = layout)

##
separator = maximum(wr)
p = plot(interval, (wr .+ TNN.get_words(seq) * separator)', label = "")
scatter!(interval, signs[:, 1] .* separator)
plot!(
    ylims = (
        (TNN.get_words(seq)[1] * separator),
        (TNN.get_words(seq)[end] + 1) * separator,
    ),
)
plot!(
    yticks = (TNN.get_words(seq) * separator, [seq.mapping[x] for x in TNN.get_words(seq)]),
)
plot!(legend = false, xaxis = false)

separator = maximum(pr)
q = plot(interval, (pr .+ TNN.get_phonemes(seq) * separator)', label = "")
scatter!(interval, signs[:, 2] .* separator)
plot!(
    ylims = (
        TNN.get_phonemes(seq)[1] * (separator),
        (TNN.get_phonemes(seq)[end] + 1) * separator,
    ),
)
plot!(
    yticks = (
        TNN.get_phonemes(seq) * separator,
        [string(seq.mapping[x]) for x in TNN.get_phonemes(seq)],
    ),
)
plot!(legend = false, xlabel = "Time (ms)")

plot(p, q, layout = (2, 1))




# function analysis_simulation(id, root)
# W0 = read(load_weights(store.data)[1])
# rates   = load_rates(store.data)
#     store = TNN.StoreParams(id=id, root=datadir(), interval=5000)
#     plots = plotsdir("network", store.id) |> mkpath
#     scores = datadir(id,"scores")  |>mkpath

#     network = TNN.load_network(store.path, T=0.f0)

#     @unpack stim, seq, net, dends, learn = network
#     spikes = TNN.load_spikes(store.data)
#     # W0 = read(TNN.load_weights(store.data)[1])
#     # Ws = TNN.load_weights(store.data)
#     # trackers = TNN.load_trackers(store.data)
#     states   = TNN.load_states(store.data)
#     rates   = TNN.load_rates(store.data)
#     # track_neurons, track_pops =  TNN.get_track_neurons(network.seq)

#     macro makeplot(p, folder,name)
#         return :( $p,savefig( joinpath($folder,$name *".pdf")) )
#     end
#     # names 
#     # TNN.get_phonemes(seq)
#     # @makeplot TNN.plot_voltage(trackers, seq,1, index=64, track_pops=track_pops) plots "voltage"
#     @makeplot TNN.raster_both_populations(spikes,seq,30,store) plots "raster_pop"
#     @makeplot TNN.raster_plot(TNN.Spiketimes(read(spikes[1],:exc)) ) plots "raster_full"

#     ##
#     @makeplot TNN.plot_rates(rates) |> x-> saveplot(x,"rates.pdf") plots "rates"
#     ticks = (1:length(indices), [string(seq.mapping[index]) for index in indices])
#     p = heatmap(confusion_matrix_words, xlabel="Target word", ylabel="Reactivated word", clims=(0,1), xticks=ticks, yticks=ticks);

#     @makeplot p plots "confusion_matrix_words"
#     ticks = (1:length(indices), [string(seq.mapping[index]) for index in indices])
#     p = heatmap(confusion_matrix_phonemes, xlabel="Target phoneme", ylabel="Reactivated phoneme", clims=(0,1), xticks=ticks, yticks=ticks);
#     @makeplot p plots "confusion_matrix_phonemes"

#     ##

#     ##

#     feats, labels, intervals = TNN.spikes_to_features(spikes[1:2], network, tt0=1,ttf=5000)
#     data = TNN.apply_PCA(feats,500)
#     score_word_spikes = TNN.MultiLogReg(data,labels[1,:])
#     score_phonemes_spikes = TNN.MultiLogReg(data,labels[2,:])

#     feats, labels, n_neurons = TNN.states_to_features(states[1:2])
#     data = TNN.apply_PCA(feats,500)
#     score_word_states= TNN.MultiLogReg(data,labels[1,:])
#     score_phonemes_states = TNN.MultiLogReg(data,labels[2,:])

#     safesave(joinpath(scores,"classification.bson"), Dict("states"=>(words=score_word_states,phonemes=score_phonemes_states),
#                                                             "phonemes"=>(words=score_word_spikes, phonemes=score_phonemes_spikes))
#                                                         )
# end
