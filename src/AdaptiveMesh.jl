module AdaptiveMesh

using LinearAlgebra
# Write your package code here.
#
mutable struct Mesh{TP, TE, TL, TV}
  points::Vector{TP}
  edges::TE
  edge_orientations::Vector{Int}
  axis_log::TL
  axis_imag::TL
  abs_points::Vector{TV}
end

function update_mesh(mesh)
  counter = 1
  update_mesh_i(mesh) # maybe this must be repeated
end

function update_mesh(mesh::Mesh{TP}) where {TP <: Number}
  return nothing
end

function update_mesh_i(mesh)
  n_dims = length(mesh.points[1])
  counter = 0
  for i in 1:length(mesh.points)
    for dim in 1:n_dims
      for dir in [1, -1]
        counter += create_new_edge_if_needed(i, mesh, dim, dir)
      end
    end
  end
  return counter
end

function create_new_edge_if_needed(i::Int, mesh, dim, dir)
  j = next_point(i, mesh, dim, dir)
  if j !== nothing
    if !edge_between(mesh.points[i], mesh.points[j], mesh)
      push!(mesh.edges, [i, j])
      push!(mesh.edge_orientations, get_dim(mesh.points[i], mesh.points[j]))
      return 1
    end
  end
  return 0
end

function update_edge_orientations!(mesh)
  mesh.edge_orientations = Vector{Int}(undef, length(mesh.edges))
  for (i, e) in mesh.edges
    mesh.edge_orientations[i] = get_dim(mesh.edges[i][1], mesh.edges[i][2])
  end
end

function next_point(point, mesh, dim, dir)
  cands = findall(s -> (equal_coords_axis(s, point, dim) && correct_dir(point, s, dim, dir)), mesh.points)
  if length(cands) == 0
    return nothing
  end
  val, i = findmin([dist(s, point, mesh) for s in mesh.points[cands]])
  i = cands[i]
end

function next_point(i::Int, mesh, dim, dir)
  next_point(mesh.points[i], mesh, dim, dir)
end

function edge_between(p1, p2, mesh)
  ch_dim = findfirst(s -> (p1-p2)[s] != 0, 1:length(p1))
  d1 = min(p1[ch_dim], p2[ch_dim])
  d2 = max(p1[ch_dim], p2[ch_dim])
  for (i, edge) in enumerate(mesh.edges)
    p3, p4 = endpoints(edge, mesh)
    dim = mesh.edge_orientations[i]
    if check_if_between(p1, p2, p3, p4, ch_dim, d1, d2, dim)
      return true
    end
  end
  return false
end

function check_if_between(p1, p2, p3, p4,
    ch_dim = findfirst(s -> (p1-p2)[s] != 0, 1:length(p1)),
    d1 = min(p1[ch_dim], p2[ch_dim]),
    d2 = max(p1[ch_dim], p2[ch_dim]),
    dim = get_dim(p3, p4)
  )
  if (p3, p4) == (p1, p2)
    return true
  end
  if (p4, p3) == (p1, p2)
    return true
  end
  if !(d1 < p3[ch_dim] < d2)
    return false
  end
  if !(d1 < p4[ch_dim] < d2)
    return false
  end
  for i in setdiff(1:length(p1), [dim, ch_dim])
    if p2[i] != p4[i]
      return false
    end
  end
  d1 = min(p3[dim], p4[dim])
  d2 = max(p3[dim], p4[dim])
  if d1 < p1[dim] < d2
    return true
  else
    return false
  end
end

edge_between(i::Int, j::Int, mesh) = edge_between(mesh.points[i], mesh.points[j], mesh)

function endpoints(edge, mesh)
  return mesh.points[edge[1]], mesh.points[edge[2]]
end

function dist(p1, p2, mesh)
  p1abs = abscoords(p1, mesh)
  p2abs = abscoords(p2, mesh)
  return norm(p1abs-p2abs)
end

function get_dim(p1, p2)
  @inbounds for i in 1:length(p1)
    if p1[i] != p2[i]
      return i
    end
  end
  return length(p1)
end

function hamming_norm(v)
  sum( v .!= 0)
end

dist(i::Int, j::Int, mesh) = dist(mesh.points[i], mesh.points[j], mesh)


function correct_dir(p1, p2, dim, dir)
  if dir*p1[dim] < dir*p2[dim]
    return true
  else
    return false
  end
end

function equal_coords_axis(p1, p2, dim::Int)
  for i in 1:length(p1)
    if i != dim
      if p1[i] != p2[i]
        return false
      end
    end
  end
  return true
end

function plot_mesh2d(m)
  plot()
  for e in m.edges
    p1 = m.points[e[1]]
    p2 = m.points[e[2]]
    plot!([p1[1], p2[1]], [p1[2], p2[2]], legend=nothing, color = :blue)
  end
  for p in m.points
    scatter!([p[1]], [p[2]], legend=nothing, color = :black)
  end
  plot!()
end

function plot_mesh3d(m)
  plot()
  for e in m.edges
    p1 = m.points[e[1]]
    p2 = m.points[e[2]]
    plot!([p1[1], p2[1]], [p1[2], p2[2]], [p1[3], p2[3]], legend=nothing, color = :blue)
  end
  for p in m.points
    scatter!([p[1]], [p[2]], [p[3]], legend=nothing, color = :black)
  end
  plot!()
end


function Base.length(m::Mesh)
  return length(m.points)
end

Base.getindex(m::Mesh, I...) = getindex(m.abs_points, I...)
Base.iterate(m::AdaptiveMesh.Mesh, i=1) = length(m) >= i ? (getindex(m, i), i+1) : nothing

include("./Factories.jl")
include("./PlotRecipes.jl")
include("./ScaledMesh.jl")

export Mesh, update_mesh, refine!, refine_i!, mesh1d

end
