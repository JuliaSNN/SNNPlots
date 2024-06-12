
# function plot_rate(spikes)
# 	points = collect(1:1:length(spikes))
# 	_rates = zeros(3,length(points))
# 	for n in eachindex(points)
# 		ss = read(spikes[points[n]])
# 		_rates[1,n] = sum([length(x) for x in ss.exc])/length(ss.exc)/5
# 		_rates[2,n] = sum([length(x) for x in ss.sst])/length(ss.sst)/5
# 		_rates[3,n] = sum([length(x) for x in ss.pv]) /length(ss.pv)/5
# 	end
# 	_xs = [spikes[x][1]/1000 for x in points]
# 	return plot(_xs,_rates', xlabel="Time (s)", ylabel="Rate (Hz)", labels=["Tripod" "SST" "PV"], legend=:topleft)
# end
# # x =
# # x =

function plot_rates(rates::Vector{Any}; ax = plot(), tt0 = 0, kwargs...)
    exc = Vector{Float32}()
    sst = Vector{Float32}()
    pv = Vector{Float32}()
    xs = Vector{Float32}()
    tts = [tt0]
    for (n, rate) in enumerate(rates)
        push!(tts, rate[1])
        exc = runmean(vcat(exc, rate[2][1:50:end]), 40)
        sst = runmean(vcat(sst, rate[3][1:50:end]), 40)
        pv = runmean(vcat(pv, rate[4][1:50:end]), 40)
        xs = vcat(xs, [1+tts[n]:5:tts[n+1]...])
    end
    # return xs, exc, sst, pv
    p = plot!(ax)
    p = plot([xs, xs], [sst, pv], labels = ["pv" "sst"])
    p = plot!([xs], [exc], labels = "exc")
    _tt = (tts[end] - tt0) ÷ 5
    plot!(xlabel = "Time (s)", ylabel = "Rate (Hz)", titlefontsize = 15)
    plot!(
        xticks = (
            tt0:_tt:tts[end],
            string.(round.(collect(tt0:_tt:tts[end]) ./ 1000, digits = 1)),
        );
        kwargs...,
    )
    return p
end
