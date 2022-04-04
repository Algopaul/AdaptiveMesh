function mesh1d(v::AbstractVector{T}; axis_imag = false, axis_log = false) where {T}
  edges = nothing
  Tc = axis_imag ? complex(T) : T
  abs_points = Vector{Tc}(undef, length(v))
  m = Mesh(Vector(sort(v)), edges, [1], axis_log, axis_imag, abs_points)
  update_abs_points!(m)
  return m
end

function Mesh(points::AbstractVector{TV}, edges; axis_log=zeros(Bool,length(points[1])), axis_imag=zeros(Bool, length(points[1]))) where {TV <: AbstractVector}
  T = eltype(points[1])
  Tc = any(axis_log) ? float(T) : T
  Tc = any(axis_imag) ? complex(Tc) : Tc
  abs_points = Vector{Vector{Tc}}(undef, length(points))
  mesh = Mesh(Vector(points), edges, [1], axis_log, axis_imag, abs_points)
  update_edge_orientations!(mesh)
  update_mesh(mesh)
  return mesh
end

function Mesh(points::AbstractVector{TV}; axis_log=zeros(Bool,length(points[1])), axis_imag=zeros(Bool, length(points[1]))) where {TV <: AbstractVector}
  T = eltype(points[1])
  Tc = any(axis_log) ? float(T) : T
  Tc = any(axis_imag) ? complex(Tc) : Tc
  abs_points = Vector{Vector{Tc}}(undef, length(points))
  mesh = Mesh(Vector(points), Vector{Vector{Int}}(undef, 0), [1], axis_log, axis_imag, abs_points)
  update_edge_orientations!(mesh)
  update_mesh(mesh)
  return mesh
end

function Mesh(points::AbstractVector{TV}; axis_log=zeros(Bool, 1), axis_imag = zeros(Bool, 1)) where {TV <: Number}
  return mesh1d(points, axis_log = axis_log[1], axis_imag = axis_imag[1])
end

function MeshGrid2d(Ps1::AbstractVector{V}, Ps2::AbstractVector{V}; axis_log=zeros(Bool, 2), axis_imag=zeros(Bool, 2)) where {V <: Number}
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
  m = Mesh(points; axis_log, axis_imag)
  return m
end

export mesh1d, MeshGrid2d
