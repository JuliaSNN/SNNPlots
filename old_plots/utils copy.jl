function colorbar_data(xmin = 0, xmax = 1, steps = 4; values = nothing, digits = 0)
    hm = zeros(100, 1)
    hm[:, 1] .= collect(1:length(hm))
    if isnothing(values)
        if digits > 0
            xxs = round.(range(xmin, xmax, steps), digits = digits)
        else
            xxs = round.(Int, range(xmin, xmax, steps))
        end
    else
        xxs = values
        steps = length(values)
    end
    if digits > 0
        xs = round.(range(1, 100, steps), digits = digits)
    else
        xs = round.(Int, range(1, 100, steps))
    end
    @show xxs
    _xticks = (xs, xxs)
    return hm, _xticks
end



function colorbar(
    xmin = 0,
    xmax = 1,
    steps = 4;
    values = nothing,
    xlabel = "",
    ylabel = "",
    c = :amp,
    digits = 0,
    horizontal = false,
    kwargs...,
)
    hm, xxs = colorbar_data(xmin, xmax, steps; values = values, digits = digits)
    if !horizontal
        return heatmap(
            hm,
            c = c,
            cbar = false,
            xticks = :none,
            frame = :box,
            ylabel = ylabel,
            guidefontsize = 13,
            yticks = xxs;
            kwargs...,
        )
    else
        return heatmap(
            hm',
            c = c,
            cbar = false,
            yticks = :none,
            frame = :box,
            xlabel = xlabel,
            guidefontsize = 13,
            xticks = xxs;
            kwargs...,
        )
    end
end

function colorbar!(
    p,
    inset,
    xmin = 0,
    xmax = 1,
    steps = 4;
    values = nothing,
    title = "",
    xlabel = "",
    ylabel = "",
    subplot = 2,
    c = :amp,
    digits = 0,
    horizontal = true,
    kwargs...,
)
    hm, xxs = colorbar_data(xmin, xmax, steps; values = values, digits = digits)
    if !horizontal
        return heatmap(
            p,
            hm,
            c = c,
            cbar = false,
            xticks = :none,
            ylabel = ylabel,
            inset = inset,
            subplot = subplot,
            title = title,
            guidefontsize = 13,
            yticks = xxs;
            kwargs...,
            frame = :axes,
        )
    else
        return heatmap(
            p,
            hm',
            c = c,
            cbar = false,
            yticks = :none,
            title = title,
            xlabel = xlabel,
            inset = inset,
            subplot = subplot,
            guidefontsize = 13,
            xticks = xxs;
            kwargs...,
            frame = :axes,
        )
    end
end

"""
    my_diag(array, dim=1)

Returns the diagonal of a 4D array along the dimension `dim`.
The array dimensions are assumed to be (dim, d, d, ν). 
It will return an array of size (d, ν).
"""
function my_diag(array, dim = 1)
    @assert size(array)[2] == size(array)[3]
    _ds = size(array)[2]
    _νs = size(array)[4]
    new_array = zeros(_ds, _νs)
    for n = 1:_ds
        new_array[n, :] = array[dim, n, n, :]
    end
    return new_array
end

function cap_voltage(v)
    vv = copy(v)
    vv[v .> TN.AdEx.θ] .= TN.AdEx.θ
    return vv
end
