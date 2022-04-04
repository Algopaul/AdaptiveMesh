mutable struct ScaledMesh{TM, TL, TV}
  mesh::TM
  axis_log::TL
  axis_imag::TL
  abs_points::TV
end

function Base.length(m::Mesh)
  return length(m.points)
end
Base.getindex(m::ScaledMesh, I...) = getindex(m.abs_points, I...)
Base.iterate(m::AdaptiveMesh.ScaledMesh, i=1) = length(m) >= i ? (getindex(m, i), i+1) : nothing

function update_abs_points!(sm::ScaledMesh)
  n_points = sm.mesh.points
  sm.abs_points = Vector{eltype(sm.mesh.points)}(undef, length(n_points))
  for i in 1:length(n_points)
    sm.abs_points[i] = imag_if_necessary(expcoords(sm.mesh.points[i], sm), sm)
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

function expcoords(p::AbstractVector, mesh)
  pabs = deepcopy(p)
  for i in 1:length(p)
    if mesh.axis_log[i]
      pabs[i] = exp10(pabs[i])
    end
  end
  return pabs
end

function expcoords(p::Number, mesh)
  if mesh.axis_log
    return exp10(p)
  else
    return p
  end
end

function update_mesh(sm::ScaledMesh)
  update_mesh(sm.mesh)
  update_abs_points!(sm)
end

expcoords(i::Int, sm::Mesh{TD}) where {TD <: AbstractVector{TV} where {TV <: AbstractVector}} = expcoords(sm.mesh.points[i], sm)

export ScaledMesh
