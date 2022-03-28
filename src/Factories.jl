function mesh_from_1dsamples(v::AbstractVector{T}; axis_imag = false, axis_log = false) where {T}
  edges = nothing
  Tc = axis_imag ? complex(T) : T
  abs_points = Vector{Tc}(undef, length(v))
  m = Mesh(Vector(v), edges, axis_log, axis_imag, abs_points)
  update_abs_points!(m)
  return m
end
