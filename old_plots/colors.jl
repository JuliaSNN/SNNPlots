using Crayons
using ColorSchemes


RED = RGBA(0.889, 0.436, 0.278, 1)
BLU = RGBA(0, 0.605, 0.978, 1)
GREEN = RGBA{Float32}(0.2422242978521988, 0.6432750931576304, 0.30444865153411527, 1.0)
PURPLE = RGBA{Float32}(0.7644401754934356, 0.4441117794687767, 0.8242975359232758, 1.0)
BROWN = RGBA{Float32}(0.675544, 0.555662, 0.0942343, 1.0)
BLUGREEN = RGBA{Float32}(4.82118e-7, 0.665759, 0.680997, 1.0)
color_list = [BLU, RED, GREEN, PURPLE, BROWN, BLUGREEN]
# colors = [:red, :green, :grey, :purple, :yellow, :orange, :lightblue, :blue, :lightgreen, :white]
colors(L) = reshape(range(BLU, stop = RED, length = L), 1, L);


cexc = round.(Int, 255 .* (RED.r, RED.g, RED.b))
csst = round.(Int, 255 .* (BLUGREEN.r, BLUGREEN.g, BLUGREEN.b))
cpv = round.(Int, 255 .* (BLU.r, BLU.g, BLU.b))
black = round.(Int, 255 .* (0, 0, 0))
