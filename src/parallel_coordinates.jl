using Plots
using ProgressBars
#using Random
#using StatsBase


using Plots
# Optionally, choose the GR backend for speed:
#gr()


#using Dagger

#using Dagger
#using Distributed
#addprocs(1; exeflags="--threads=2")
#@everywhere using Dagger


#task1 = Dagger.@spawn expensive_function(arg1)
#task2 = Dagger.@spawn another_function(arg2)
#result = fetch(Dagger.@spawn combine_results(task1, task2))

# A small team, obviously very enthusiastic about there work, but under high pressure to develop the company
# products further, how do the team members stay connected and keep morale high when working under pressure.
#

function get_num_samples(length)
    if length > 100000
        return Int(trunc(1.0/length))# * 0.0001))  # 1% for lengths > 100,000
    elseif length > 10000
        return Int(trunc(1.0/length))# * 0.001))  # 1% for lengths > 100,000

    elseif length > 1000 #&& length<= 10000
        return Int(trunc(1.0/length))# * 0.01))    # 10% for lengths > 1,000
    else
        return length                       # Use the full length for smaller lists
    end
end


function plot_auxillary_method(pre_synapses,post_synapses)
    including_smaller_sets_pre = []
    including_smaller_sets_post = []
    cnt = 0
    for (i,j) in zip(pre_synapses,post_synapses)
        #num_samples = get_num_samples(length(i))
        # Generate the same random indices for both lists
        #indices = Random.sample(1:length(i), num_samples, replace=false)
        #cnt+=length(i[indices])
        push!(including_smaller_sets_pre, i)#[indices])
        push!(including_smaller_sets_post, j)#[indices])
    end    
    including_smaller_sets_pre,including_smaller_sets_post
end


function doparallelCoords_optimized(pre_synapses, post_synapses;figure_name=nothing)
    # Instead of calling plot_auxillary_method, we assume the inputs have already been selected.
    # We'll compute the number of "groups" (each group corresponds to one pair of arrays).
    n_groups = length(pre_synapses)
    
    # Preallocate arrays for storing all line segments and scatter points.
    # We'll store each segment as two endpoints.
    #line_xs = zeros(n_groups)(Vector{Float32})
    line_xs = Float32[] 
    line_ys = Float32[]
    scatter_xs = Float32[]
    scatter_ys = Float32[]
    
    cnt = 0.0
    for (ilist, jlist) in ProgressBar(zip(pre_synapses, post_synapses))
        # For each (i, j) in the current group, draw a line from (cnt, i) to (cnt+1, j)
        for (i, j) in zip(ilist, jlist)
            # Append the two endpoints for the line segment.
            push!(line_xs, cnt)
            push!(line_xs, cnt + 1)
            push!(line_ys, i)
            push!(line_ys, j)
            # Also record the scatter points for each endpoint.
            push!(scatter_xs, cnt)
            push!(scatter_xs, cnt + 1)
            push!(scatter_ys, i)
            push!(scatter_ys, j)
        end
        cnt += 1
    end

    # Now, make one call to create the plot and then add the line and scatter series.
    p = plot(xlim=(0, cnt), xlabel="Sample Index", ylabel="Values", legend=false)
    plot!(p, line_xs, line_ys, line=:solid)  # One batched line series
    scatter!(p, scatter_xs, scatter_ys, markersize=1, color=:black)  # One batched scatter series
    if figure_name!=nothing
        savefig(p,figure_name)
    end

    return p
end

function doparallelCoords(pre_synapses, post_synapses)
    including_smaller_sets_pre, including_smaller_sets_post = plot_auxillary_method(pre_synapses, post_synapses)
    p = Plots.plot()
    cnt = 0
    
    # Collect jobs into an array
    jobs = []
    for (ilist, jlist) in zip(including_smaller_sets_pre, including_smaller_sets_post)
        cnt_local = cnt
        plot_data = [(cnt_local, cnt_local + 1, i, j) for (i, j) in zip(ilist, jlist)]
        push!(jobs,plot_data)
        cnt += 1
    end

    # Wait for jobs to complete and plot
    for plot_data in jobs
        #plot_data = fetch(job)
        for (x1, x2, y1, y2) in plot_data
            Plots.plot!(p, [x1, x2], [y1, y2], legend=false)
            Plots.scatter!(p, [x1, x2], [y1, y2], color=:black, markersize=1, label="", legend=false)
        end
    end

    Plots.xlims!(p, 0, cnt)
    Plots.ylabel!(p, "Values")
    Plots.xlabel!(p, "Sample Index")
    Plots.savefig("ParallelCoordinates.png")
    
    return p
end
#=
function doparallelCoords(pre_synapses,post_synapses)
    including_smaller_sets_pre,including_smaller_sets_post = plot_auxillary_method(pre_synapses,post_synapses)
    p = Plots.plot()
    cnt=0
    # iterate through layers.
    @sync for (ilist,jlist) in zip(including_smaller_sets_pre,including_smaller_sets_post)
        # This line is necessary because we are in layers now.
        # Then iterate over individual connections.
        for (y,(i,j)) in enumerate(zip(ilist,jlist))
            Dagger.@spawn Plots.plot!(p,[cnt,cnt+1],[i,j],legend=false)
            Dagger.@spawn Plots.scatter!(p, [cnt, cnt+1], [i, j], color=:black, markersize=1, label="", legend=false)
        end
        cnt+=1
    Plots.xlims!(p, 0, cnt)  # Set the x limits based on the count of pairs processed
    Plots.ylabel!(p, "Values")
    Plots.xlabel!(p, "Sample Index")
    end
    return p
end
=#