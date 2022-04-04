using Plots
using AdaptiveMesh

# 1D Plot
M = Mesh(1.0:10.0)
plot(M)

# 2D Plot
d1 = 1.0:20
d2 = 1.0:20
@time M = MeshGrid2d(d1, d2)
plot(M)

# 3D Plot
points = [[0.0, 0.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, 1.0], [1.0, 0.0, 1.0], [0.0, 1.0, 0.0], [1.0, 1.0, 0.0], [1.0, 1.0, 1.0], [0.0, 1.0, 1.0]]
M = Mesh(points)
update_mesh(M)
plot(M)
