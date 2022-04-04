using BenchmarkTools
using ProfileView
using Plots
using Revise
using AdaptiveMesh

d1 = 1.0:20
d2 = 1.0:20
# @profview M = MeshGrid2d(d1, d2)
@time M = MeshGrid2d(d1, d2)
# push!(M.points, [49.5, 49.5])
# push!(M.points, [49.5, 49.8])
plot(M)
push!(M.points, [19.5, 18.5])
push!(M.points, [19.5, 19.8])
plot(M)
update_mesh(M)
plot(M)

@btime AdaptiveMesh.get_dim(M.points[1], M.points[2])

@btime AdaptiveMesh.get_dim(p1, p2)

points = [[0.0, 0.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, 1.0], [1.0, 0.0, 1.0], [0.0, 1.0, 0.0], [1.0, 1.0, 0.0], [1.0, 1.0, 1.0], [0.0, 1.0, 1.0]]
M = Mesh(points)
update_mesh(M)
plot(M)
