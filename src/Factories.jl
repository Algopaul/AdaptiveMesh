function mesh1d(v::AbstractVector{T}) where {T}
  m = Mesh(Vector(sort(v)), edges, [1], axis_log, axis_imag, abs_points)
  return m
end

function Mesh(
  points::AbstractVector{TV},
  edges=Vector{Vector{Int}}(undef, 0),
  edge_orientations=Vector{Int}(undef, 0)
  ) where {TV <: AbstractVector}
  Tc = eltype(points[1])
  abs_points = Vector{Vector{Tc}}(undef, length(points))
  mesh = Mesh(Vector(points), edges, edge_orientations)
  update_edge_orientations!(mesh)
  update_mesh(mesh)
  return mesh
end

function Mesh(points::AbstractVector{TV}) where {TV <: Number}
  return mesh1d(points)
end

function MeshGrid2d(
    Ps1::AbstractVector{V},
    Ps2::AbstractVector{V}
  ) where {V <: Number}
  np1 = length(Ps1)
  np2 = length(Ps2)
  points = Vector{Vector{V}}(undef, np1*np2)
  ij = 0
  for i in 1:np1
    for j in 1:np2
      ij += 1
      points[ij] = [Ps1[i], Ps2[j]]
    end
  end
  m = Mesh(points)
  update_edge_orientations!(m)
  update_mesh(m)
  return m
end

export mesh1d, MeshGrid2d
