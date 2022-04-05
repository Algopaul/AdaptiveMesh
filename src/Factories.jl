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
