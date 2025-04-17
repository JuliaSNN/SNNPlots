using XLSX
using Colors


struct MPIColor
    full::Colorant
    tint::Colorant
    shade::Colorant
end

MPI_colors = []
_names = []
path = joinpath(@__DIR__, "MPI_palette.xlsx")
XLSX.openxlsx(path, enable_cache = false) do f
    sheet = f["Sheet1"]
    for r in XLSX.eachrow(sheet)
        rn = XLSX.row_number(r) # `SheetRow` row number
        (rn < 3) && continue # skip heade
        name = r[1]    # will read value at column 1
        color = []

        counter = 1
        for t = 1:3
            push!(color, RGB(r[counter+1] / 255, r[counter+2] / 255, r[counter+3] / 255))
            counter += 3
        end
        push!(MPI_colors, MPIColor(color...))
        push!(_names, r[1])
    end
end

mpi_colors = Dict{String,MPIColor}(zip(_names, MPI_colors)) |> dict2ntuple

mpi_palette = palette(vcat([c.full for c in mpi_colors], [c.tint for c in mpi_colors]))

export mpi_colors, mpi_palette
