using StatsPlots
using LsqFit
include(scriptsdir("artificial_lexicon.jl"));

compare_dictionary =
    (df, pval = 0.005; dep_variable = :max_score, kwargs...) -> begin

        @rtransform! df :var = dep_variable == Symbol("max_score") ? :max_score : :ave_delay
        default(msw = 0, ms = 5)
        ##
        bar_width(x) = diff(collect(extrema(x))) / 30
        @. linear_func(x, p) = p[1] * x + p[2]

        ##
        pval = 0.05
        p1 = dotplot(
            df.overlap,
            df.var,
            group = df.dictionary_sort,
            xlabel = "Phonemic overlap",
            ylabel = "Cohen's κ-score",
            legend = :outertopright,
            legendtitle = "Dictionary",
            xrotation = 0,
            palette = mpi_palette,
            bar_width = bar_width(df.overlap),
        )
        fit = curve_fit(linear_func, df.overlap, df.var, [1.0, 1.0])
        ci = confidence_interval(fit, pval)
        plot!(x -> linear_func(x, fit.param), c = :black, l = "", alpha = 0.6)
        plot!(
            x -> linear_func(x, [ci[1][1], ci[2][2]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(
            x -> linear_func(x, [ci[1][2], ci[2][1]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(legend = false)
        #

        p2 = dotplot(
            df.length,
            df.var,
            group = df.dictionary_sort,
            xlabel = "Word length",
            ylabel = "Score",
            legend = :outertopright,
            bar_width = bar_width(df.length),
        )
        fit = curve_fit(linear_func, df.length, df.var, [1.0, 1.0])
        ci = confidence_interval(fit, pval)
        plot!(x -> linear_func(x, fit.param), c = :black, label = "", alpha = 0.6)
        plot!(
            x -> linear_func(x, [ci[1][1], ci[2][2]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(
            x -> linear_func(x, [ci[1][2], ci[2][1]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(legend = false, ylabel = "")
        #

        p3 = dotplot(
            df.size,
            df.var,
            group = df.dictionary_sort,
            xlabel = "Lexicon size",
            ylabel = "Score",
            bar_width = bar_width(df.size),
            legend = :outertopright,
        )
        fit = curve_fit(linear_func, df.size, df.var, [1.0, 1.0])
        ci = confidence_interval(fit, pval)
        plot!(x -> linear_func(x, fit.param), c = :black, label = "")
        plot!(
            x -> linear_func(x, [ci[1][1], ci[2][2]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(
            x -> linear_func(x, [ci[1][2], ci[2][1]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(legend = false, ylabel = "")
        ##

        p4 = dotplot(
            df.ups,
            df.var,
            group = df.dictionary_sort,
            xlabel = "Onset overlap",
            ylabel = "Score",
            bar_width = bar_width(df.ups),
            legend = :outertopright,
        )
        fit = curve_fit(linear_func, df.ups, df.var, [1.0, 1.0])
        ci = confidence_interval(fit, pval)
        plot!(x -> linear_func(x, fit.param), c = :black, label = "")
        plot!(
            x -> linear_func(x, [ci[1][1], ci[2][2]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(
            x -> linear_func(x, [ci[1][2], ci[2][1]]),
            c = :grey,
            ls = :dash,
            alpha = 0.6,
            label = "",
        )
        plot!(legend = false, ylabel = "")
        ##
        plot!(p2, yticks = :none)
        plot!(p4, yticks = :none)
        plot!(p3, yticks = :none)
        if dep_variable == :max_score
            plot!(p1, yticks = range(0, 1, 5), ylims = (0.2, 1.2))
            [plot!(x, ylims = (0.2, 1.2)) for x in [p1, p2, p3, p4]]
        else
            plot!(p1; kwargs...)
            # plot!(p1,yticks=range(0,100,5), ylims=(-100,100))
            [plot!(x, ylims = (30, 150)) for x in [p1, p2, p3, p4]]
        end
        layout = @layout [a{0.25w} b{0.25w} c{0.25w} d{0.25w} _]
        return plot(
            p1,
            p2,
            p3,
            p4,
            layout = layout,
            legend = false,
            margin = 5Plots.mm,
            size = (1200, 400),
            link = :y,
        )
    end


stacked_confusion_matrix =
    (f) -> begin
        gdf = @by df :dictionary begin
            :opt_delay_err = std(:opt_delay)
            :opt_delay = mean(:opt_delay)
            :max_score_err = std(:max_score)
            :max_score = mean(:max_score)
            :cm_words = mean(:cm_words)
        end
        sort!(gdf, :dictionary)
        f = @subset df :dictionary .== "simple"
        xx = findfirst(x -> x > mean(f.opt_delay), f.delays[1])
        delays = f.delays[1]

        seq = f.network[1].seq
        gdf = @subset gdf :dictionary .== "simple"
        ticks = TNN.get_ticks(seq).w
        hj = heatmap(
            gdf.cm_words[xx],
            clims = (0, 1),
            c = :greys,
            yticks = ticks,
            xticks = ticks,
            xrotation = 45,
            xlabel = "Target word",
            ylabel = "Reactivated word",
            rightmargin = 0Plots.mm,
        )
        return hj
    end


delay_score =
    (df) -> begin

        ##
        q1 = plot()
        for d in sort(unique(df.dictionary_sort))
            f = @chain df begin
                @rsubset :dictionary_sort == d
                @by :dictionary begin
                    :mat = mean(:cm_words)
                    :val = mean(:scores_words)
                    :std = std(:scores_words)
                    :x = mean(:delays)
                end
            end
            plot!(f.x, f.val, ribbon = f.std, label = d)
        end
        plot!(
            legend = :outertopright,
            xlabel = "Delay (ms)",
            ylabel = "Score",
            size = (600, 400),
            legendtitle = "Dictionary",
            legendtitlefontsize = 18,
            margin = 0Plots.mm,
        )
        ##
        q2 = plot()
        for d in sort(unique(df.dictionary_sort))
            f = @chain df begin
                @rsubset :dictionary_sort == d
                @by :dictionary begin
                    :mat = mean(:cm_phonemes)
                    :val = mean(:scores_phonemes)
                    :std = std(:scores_phonemes)
                    :x = mean(:delays)
                end
            end
            plot!(f.x, f.val, ribbon = f.std, label = d)
        end
        plot!(
            legend = :outertopright,
            xlabel = "Delay",
            ylabel = "Score",
            size = (600, 400),
            legendtitle = "Dictionary",
            legendtitlefontsize = 18,
            margin = 0Plots.mm,
        )
        ##
        return q1, q2
    end

##
opt_delay_score =
    (df) -> begin
        pval = 0.05
        @. linear_func(x, p) = p[1] * x + p[2]
        sort!(df, :dictionary_sort)
        gdf = @by df :dictionary_sort begin
            :norm_score = :max_score .- mean(:max_score)
            :norm_delay = :opt_delay .- mean(:opt_delay)
        end
        sort!(gdf, :dictionary_sort)
        q3 = scatter(
            gdf.norm_delay,
            gdf.norm_score,
            c = repeat(mpi_palette[1:9], inner = 10),
        )
        fit = curve_fit(linear_func, gdf.norm_delay, gdf.norm_score, [1.0, 1.0])
        ci = confidence_interval(fit, pval)
        plot!(x -> linear_func(x, fit.param), c = :black, l = "")
        plot!(x -> linear_func(x, [ci[1][1], ci[2][2]]), c = :grey, ls = :dash)
        plot!(x -> linear_func(x, [ci[1][2], ci[2][1]]), c = :grey, ls = :dash)
        plot!(
            legend = false,
            xlabel = "Optimal delay (ms)",
            ylabel = "Cohen's κ-score",
            size = (600, 400),
            leftmargin = 0Plots.mm,
        )
        ##
        return q3
    end



average_cm =
    df -> begin
        plots = []
        for d in sort(unique(df.dictionary_sort))[2:end]
            f1 = @chain df begin
                @rsubset :dictionary_sort == d
            end
            seq = f1.network[1].seq
            f = @chain df begin
                @rsubset :dictionary_sort == d
                @by :dictionary begin
                    :mat = mean(:cm_words)
                    :val = mean(:scores_words)
                    :std = std(:scores_words)
                    :x = mean(:delays)
                end
            end
            delay_i = argmax(f.val)
            # @info "The best delay for dictionary $d is $(f.x[delay_i])"
            ii = TNN.sorted_words(seq)
            # @show seq.lemmas
            @show ii
            ticks = TNN.get_ticks(f1.network[1].seq).w
            p = heatmap(
                f.mat[delay_i][ii, ii],
                ylabel = "$d",
                xticks = ticks,
                xrotation = 45,
                c = :greys,
                yticks = ticks,
                clims = (0, 1),
                cbar = false,
            )
            plot!(yguideposition = :right, xtickfontsize = 11, ytickfontsize = 11)
            push!(plots, p)
            @info "The variance of the best score is:
            $(f.std[delay_i]), in percentage: $(f.std[delay_i]/f.val[delay_i]*100)"


        end
        p = plot(
            plots...,
            layout = (3, 2),
            size = (900, 1200),
            topmargin = 5Plots.mm,
            plot_title = "Confusion matrix for each dictionary",
            leftmargin = 10Plots.mm,
        )
        return p

    end

# ## Export for plotting it somewhere else
# data = @strdict matrix = gdf.cm_words ticks = ticks delays = delays
# datapath = datadir("network/Fig3_score/stacked_confusion_matrix.jld2")
# save(datapath, data)


# isfile(datapath) 
# data = load(datapath)
# matrices = data["matrix"]
# matrix = matrices[1]
# delays = data["delays"]
# ticks = data["ticks"]

# xs = 1:size(matrix)[1]
# heights = 11:10:51

# fig = Figure()
# ax = Axis3(fig[1, 1], aspect=(1, 1, 1), elevation=π/16)
# cr = (0,1) # color range to use for all heatmaps
# for i in eachindex(heights)
#     h = heights[i]
#     hm = CairoMakie.heatmap!(ax, xs, xs, matrices[h], colorrange=cr)
#     CairoMakie.translate!(hm, 0, 0, heights[i])

#     h == 1 && Colorbar(fig[1, 2], hm) # add the colorbar once
# end

# ax.xticks= (1:10,ticks[2])
# ax.yticks= (1:10,ticks[2])
# ax.zticks= (heights, string.(delays[heights]))
# CairoMakie.zlims!(ax, minimum(heights), maximum(heights))
# fig
