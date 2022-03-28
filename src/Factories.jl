function mesh1d(v::AbstractVector{T}; axis_imag = false, axis_log = false) where {T}
  edges = nothing
  Tc = axis_imag ? complex(T) : T
  abs_points = Vector{Tc}(undef, length(v))
  m = Mesh(Vector(sort(v)), edges, axis_log, axis_imag, abs_points)
  update_abs_points!(m)
  return m
end

function Mesh(points::AbstractVector{TV}, edges; axis_log=zeros(Bool,length(points[1])), axis_imag=zeros(Bool, length(points[1]))) where {TV <: AbstractVector}
  T = eltype(points[1])
  Tc = any(axis_log) ? float(T) : T
  Tc = any(axis_imag) ? complex(Tc) : Tc
  abs_points = Vector{Vector{Tc}}(undef, length(points))
  mesh = Mesh(Vector(points), edges, axis_log, axis_imag, abs_points)
  update_mesh(mesh)
  return mesh
end

function Mesh(points::AbstractVector{TV}; axis_log=zeros(Bool,length(points[1])), axis_imag=zeros(Bool, length(points[1]))) where {TV <: AbstractVector}
  T = eltype(points[1])
  Tc = any(axis_log) ? float(T) : T
  Tc = any(axis_imag) ? complex(Tc) : Tc
  abs_points = Vector{Vector{Tc}}(undef, length(points))
  mesh = Mesh(Vector(points), Vector{Vector{Int}}(undef, 0), axis_log, axis_imag, abs_points)
  update_mesh(mesh)
  return mesh
end
