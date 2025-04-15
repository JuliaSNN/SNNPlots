function doparallelCoords(pre_synapses,post_synapses)
    including_smaller_sets_pre = []
    including_smaller_sets_post = []
    cnt = 0
    @showprogress for (i,j) in zip(pre_synapses,post_synapses)
        num_samples = get_num_samples(length(i))
        # Generate the same random indices for both lists
        indices = sample(1:length(i), num_samples, replace=false)
        cnt+=length(i[indices])
        push!(including_smaller_sets_pre, i[indices])
        push!(including_smaller_sets_post, j[indices])
    end    
    p = Plots.plot()
    cnt=0
    @showprogress for (ilist,jlist) in zip(including_smaller_sets_pre,including_smaller_sets_post)
        # This line is necessary because we are in layers now.
        #
        for (y,(i,j)) in enumerate(zip(ilist,jlist))
            Plots.plot!(p,[cnt,cnt+1],[i,j],legend=false)
            Plots.scatter!(p, [cnt, cnt+1], [i, j], color=:black, markersize=1, label="", legend=false)
        end
        cnt+=1
    Plots.xlims!(p, 0, cnt)  # Set the x limits based on the count of pairs processed
    Plots.ylabel!(p, "Values")
    Plots.xlabel!(p, "Sample Index")
    end
    return p
end
