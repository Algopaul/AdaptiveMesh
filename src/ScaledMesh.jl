mutable struct ScaledMesh{TM, TL, TV}
  mesh::TM
  axis_log::TL
  axis_imag::TL
  abs_points::TV
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
