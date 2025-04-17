import TripodNetwork: Encoding, get_words
function clustering_ee_history(ws, rd)
    for (tt, w) in ws
        w = readW(w, "e_s_e")
        nodes, cols = clustering_ee(w)
        p = heatmap(w[cols, cols, 3])
        savefig(p, joinpath(rd, "graphs", string(tt)))
    end
end


# function weights_animation(w1::Array,w2::Array, seq::Encoding, filepath=joinpath("/tmp","connections_dendrites.gif"); fps=1)
# 	_m = floor(minimum([w1[:];w2[:]]))
# 	_M = ceil(maximum([w1[:];w2[:]]))
# 	ww = length(get_words(seq))
# 	p = (w1,w2,t) ->
# 		begin
# 		ticks = ([ww/2,ww+ww/2], ["words", "phonemes"])
# 		plot(
# 		heatmap(w1[t,:,:], clims=(_m,_M), yticks=ticks, ylabel="post-synaptic", xlabel="pre-synaptic", title="Timeframe: $t"),
# 		heatmap(w2[t,:,:], ylabel="post-synaptic", xlabel="pre-synaptic", clims=(_m,_M), yticks=:none, cbar=false,   title="Dendrite 2"),
# 		size=(800,800),
# 		xticks=ticks,
# 		titlefontsize = 13,
# 		)
# 		vline!([ww+0.5], c=:white, ls=:dash, lw=2, label="")
# 		hline!([ww+0.5], c=:white, ls=:dash, lw=2, label="")
# 	end
# 	anim = @animate for t in 1:size(w1,1)
# 		p(w1,w2,t)
# 	end
# 	cgif = joinpath(@__DIR__,filepath)
# 	gif(anim, cgif, fps = fps)
# end


function weights_animation(
    w1::Array,
    seq::Encoding,
    filepath = joinpath("/tmp", "connections_dendrites.gif");
    fps = 1,
)
    _m = floor(minimum(w1[:]))
    _M = ceil(maximum(w1[:]))
    ww = length(get_words(seq))
    p =
        (w1, t) -> begin
            yticks = ([ww / 2, ww + ww / 2], ["words", "phonemes"])
            xticks = 1:size(w1, 2) |> x -> (x, [seq.mapping[i] for i in x])
            plot(
                heatmap(
                    w1[t, :, :],
                    clims = (_m, _M),
                    yticks = yticks,
                    ylabel = "post-synaptic",
                    xlabel = "pre-synaptic",
                    title = "Timeframe: $t",
                ),
                # layout=(1,3), 
                size = (600, 600),
                xticks = xticks,
                titlefontsize = 13,
                yrotation = 90,
                xrotation = 45,
            )
            vline!([ww + 0.5], c = :white, ls = :dash, lw = 2, label = "")
            hline!([ww + 0.5], c = :white, ls = :dash, lw = 2, label = "")
        end
    # return p(w1,1)
    anim = @animate for t = 1:size(w1, 1)
        p(w1, t)
    end
    cgif = joinpath(@__DIR__, filepath)
    gif(anim, cgif, fps = fps)
end
