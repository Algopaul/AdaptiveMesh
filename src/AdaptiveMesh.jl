module AdaptiveMesh

using LinearAlgebra
# Write your package code here.
#
mutable struct Mesh{TP, TE, TL, TV}
  points::Vector{TP}
  edges::TE
  axis_log::TL
  axis_imag::TL
  abs_points::Vector{TV}
end

function update_mesh(mesh)
  counter = 1
  while counter > 0
    counter = update_mesh_i(mesh)
  end
  update_abs_points!(mesh)
end

function update_mesh(mesh::Mesh{TP}) where {TP <: Number}
  update_abs_points!(mesh)
  return nothing
end

function update_abs_points!(mesh)
  mesh.abs_points = Vector{eltype(mesh.points)}(undef, length(mesh.points))
  for i in 1:length(mesh.points)
    mesh.abs_points[i] = imag_if_necessary(abscoords(mesh.points[i], mesh), mesh)
  end
  return nothing
end

function imag_if_necessary(v::AbstractVector, mesh)
  vv = complex(deepcopy(v))
  for i in 1:length(vv)
    if mesh.axis_imag[i]
      vv[i] = im*vv[i]
    end
  end
  return vv
end

function imag_if_necessary(v::Number, mesh)
  if mesh.axis_imag == true
    return im*v
  else
    return v
  end
end

function abscoords(p::AbstractVector, mesh)
  pabs = deepcopy(p)
  for i in 1:length(p)
    if mesh.axis_log[i]
      pabs[i] = exp10(pabs[i])
    end
  end
  return pabs
end

function abscoords(p::Number, mesh)
  if mesh.axis_log
    return exp10(p)
  else
    return p
  end
end

abscoords(i::Int, mesh::Mesh{TD}) where {TD <: AbstractVector{TV} where {TV <: AbstractVector}}= abscoords(mesh.points[i], mesh)

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
      return 1
    end
  end
  return 0
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
  for edge in mesh.edges
    p3, p4 = endpoints(edge, mesh)
    if check_if_between(p1, p2, p3, p4)
      return true
    end
  end
  return false
end

function check_if_between(p1, p2, p3, p4)
  if (p3, p4) == (p1, p2)
    return true
  end
  if (p4, p3) == (p1, p2)
    return true
  end
  dim = get_dim(p3, p4)
  ch_dim = findfirst(s -> (p1-p2)[s] != 0, 1:length(p1))
  d1 = min(p1[ch_dim], p2[ch_dim])
  d2 = max(p1[ch_dim], p2[ch_dim])
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
  d = p1-p2
  @assert hamming_norm(d) == 1
  return findfirst(s -> d[s] != 0, 1:length(d))
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

function plot_mesh(m)
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

function split_edge(i::Int, mesh, midpointfun)
  edge = mesh.edges[i]
  p1 = mesh.points[edge[1]]
  p2 = mesh.points[edge[2]]
  pmp = midpointfun(p1, p2)
  popat!(mesh.edges, i)
  push!(mesh.points, pmp)
  push!(mesh.edges, [edge[1], length(mesh.points)])
  push!(mesh.edges, [length(mesh.points), edge[2]])
end

function midpoint(p1, p2)
  return (p1+p2)/2
end


function refine!(mesh, fun, tol, midpointfun=midpoint)
  while refine_i!(mesh, fun, tol, midpointfun)
  end
  return nothing
end

function refine_i!(mesh, fun, tol, midpointfun=midpoint)
  n_edges = length(mesh.edges)
  inds = get_critical_edges(mesh, fun, midpointfun, tol)
  for idx in sort(inds, rev=true)
    split_edge(idx, mesh, midpointfun)
  end
  update_mesh(mesh)
  return n_edges < length(mesh.edges)
end

function refine_i!(mesh::Mesh{TP}, fun, tol, midpointfun=midpoint) where {TP <: Number}
  E = [0,0]
  new_samples = Vector{TP}(undef, 0)
  for (i, j) in enumerate(2:length(mesh.points))
    E .= (i, j)
    if check_edge([i, j], fun, tol, midpointfun, mesh)
      push!(new_samples, midpointfun(mesh.points[i], mesh.points[j]))
    end
  end
  if length(new_samples) > 0
    mesh.points =sort(vcat(mesh.points, new_samples))
    update_mesh(mesh)
    return true
  else
    return false
  end
end

function check_edge(edge, fun, tol, midpointfun, mesh)
  s0 = mesh.points[edge[1]]
  s1 = mesh.points[edge[2]]
  smp = midpointfun(s0, s1)
  ωs0 =  imag_if_necessary(abscoords(s0, mesh), mesh)
  ωs1 =  imag_if_necessary(abscoords(s1, mesh), mesh)
  ωsmp = imag_if_necessary(abscoords(smp, mesh), mesh)
  fs0 = fun(ωs0)
  fs1 = fun(ωs1)
  fsmp = fun(ωsmp)
  d1=abs(fsmp-fs0)/dist(smp, s0, mesh)
  d2=abs(fs1-fsmp)/dist(s1, smp, mesh)
  return inner_point_required(max(d1, d2), s0, s1, fs0, fs1, tol, mesh)
end

function inner_point_required(deriv_bound, x1, x2, f1, f2, tol, mesh)
  γ=max(f1, f2)
  return deriv_bound*dist(x2, x1, mesh) >= 2*(γ+tol)-(f1+f2)
end

function get_critical_edges(m, fun, midpointfun, tol)
  crit_edges = Vector{Int}(undef, 0)
  for (i, e) in enumerate(m.edges)
    if check_edge(e, fun, tol, midpointfun, m)
      push!(crit_edges, i)
    end
  end
  return crit_edges
end

function Base.length(m::Mesh)
  return length(m.points)
end

Base.getindex(m::Mesh, I...) = getindex(m.abs_points, I...)
Base.iterate(m::AdaptiveMesh.Mesh, i=1) = length(m) > i ? (getindex(m, i), i+1) : nothing

include("./Factories.jl")

export Mesh, update_mesh, refine!, refine_i!, mesh1d

end
