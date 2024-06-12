#=======================
	 Confusion matrix
=======================#
import Plots: Series, Plot, Subplot
import TripodNetwork: NNSpikes, Encoding, Spiketimes
import TripodNetwork: get_words, get_phonemes, get_chunks_with_intervals
import TripodNetwork: merge_spiketimes
import TripodNetwork: get_ticks, get_mean_fr, score_population_activity, Cohen_kappa

using Logging



function plot_confusion_matrix(sample; delay = 100, unique = false)
    @unpack stim, seq, net, dends, learn, store = sample.network
    spikes = sample.spikes

    ## Confusion matrix for phonemes and words
    delay = occursin("Tripod", sample.params.name) ? delay : 0
    confusion_matrix_phonemes, _ =
        score_population_activity(get_mean_fr, "phonemes", spikes, seq, unique = unique)
    ticks = get_ticks(seq)
    confusion_matrix_words, _ = score_population_activity(
        get_mean_fr,
        "words",
        spikes,
        seq,
        delay = delay,
        unique = unique,
    )
    words = [seq.mapping[x] for x in get_words(seq)]
    z = zeros(100, 1) |> x -> ([x[n, 1] = n / 100 for n = 1:100]; x)
    h = heatmap(
        z,
        colorbar = false,
        legend = false,
        xticks = :none,
        ylabel = "Recognition",
        yticks = ([0, 100], ["0", "1"]),
        clims = (0, 1),
        c = :greys,
        leftmargin = 10Plots.mm,
    )
    p1 = heatmap(
        confusion_matrix_phonemes,
        xlabel = "Target population",
        ylabel = "Reactivated population",
        clims = (0, 1),
        xticks = ticks.ph,
        yticks = ticks.ph,
        c = :greys,
    )
    p2 = heatmap(
        confusion_matrix_words,
        clims = (0, 1),
        xticks = ticks.w,
        yticks = ticks.w,
        c = :greys,
        colorbar_ticks = (0:1, ["0", "1"]),
        xrotation = 45,
    )
    layout = @layout([_ c{0.04w} a{0.48w} b{0.48w}])
    p = plot(
        h,
        p1,
        p2,
        size = (1200, 400),
        bottommargin = 15Plots.mm,
        colorbar = false,
        layout = layout,
    )

    score = Cohen_kappa(confusion_matrix_words)
    @info "Model $(store.id) Score: $score"
    return p1, p2, score
end

# function test_delays_recognition(sample)
#     @unpack stim, seq, net, dends, learn, store = sample.network
#     spikes= sample.spikes

#     ## Confusion matrix for phonemes and words
#     delay = occursin("Tripod", sample.params.name) ? delay : 0
#     confusion_matrix_phonemes, p_indices = score_population_activity(get_mean_fr,"phonemes",spikes,seq, unique=unique)
#     ticks = get_ticks(seq)
#     ## Test recognition against delay
#     delays = -40:20:250
#     scores_words = zeros(length(delays))
#     scores_phonemes = zeros(length(delays))
#     for d in eachindex(delays)
#         delay = delays[d]
#         confusion_matrix_words, w_indices = score_population_activity(get_mean_fr,"words",spikes,seq, delay=delay)
#         scores_words[d] = Cohen_kappa(confusion_matrix_words)
#         confusion_matrix_phonemes, p_indices = score_population_activity(get_mean_fr,"phonemes",spikes,seq, delay=delay)
#         scores_phonemes[d] = Cohen_kappa(confusion_matrix_phonemes)
#     end
#     q = plot(delays, scores_words, xlabel="Time to stimulus (ms)", ylabel="Recognition score", legend=false, size=(400,300),ylims=(-0.2,1), label="words")
#     q = plot!(delays, scores_phonemes, xlabel="Delay (ms)", ylabel="Recognition score", legend=false, size=(400,300),ylims=(-0.2,1), label="phon.")

#     # Test recognition against delay
#     delays = -40:20:250
#     scores_words = zeros(length(delays))
#     scores_phonemes = zeros(length(delays))
#     for d in eachindex(delays)
#         delay = delays[d]
#         confusion_matrix_words, w_indices = score_population_activity(get_mean_fr,"words",spikes,seq, delay=delay, unique=true)
#         scores_words[d] = Cohen_kappa(confusion_matrix_words)
#         confusion_matrix_phonemes, p_indices = score_population_activity(get_mean_fr,"phonemes",spikes,seq, delay=delay, unique=true)
#         scores_phonemes[d] = Cohen_kappa(confusion_matrix_phonemes)
#     end
#     plot!(delays, scores_words, xlabel="Delay (ms)", ylabel="Recognition score", legend=false, size=(400,300),ylims=(-0.2,1), ls = :dash, label="words unique")
#     q = plot!(delays, scores_phonemes, xlabel="Delay (ms)", ylabel="Recognition score", size=(400,300),ylims=(-0.2,1), ls = :dash, label="phon. unique")
#     plot!(legend=:bottomleft, leftmargin=10Plots.mm, ylims=(-0.4,1))

#     p =plot(p,q, layout=@layout([a{0.7w} b{0.3w}]), size=(1200,400))
#     return p
# end
