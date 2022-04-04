function refine!(mesh, fun, tol)
  i_start = 1
  while i_start <= length(mesh.edges)
    i_start = refine_i!(mesh, fun, tol, i_start)
  end
  return nothing
end

function refine_i!(mesh, fun, tol, i_start = 1)
  n_edges = length(mesh.edges)
  inds = get_critical_edges(mesh, fun, tol, i_start)
  for idx in sort(inds, rev=true)
    split_edge(idx, mesh)
  end
  n_edges_m = length(mesh.edges)
  update_mesh(mesh)
  n_edges_final = length(mesh.edges)
  new_i_start = n_edges-(n_edges_m-n_edges) + 1
  return new_i_start
end

function get_critical_edges(m, fun, tol, i_start = 1)
  crit_edges = Vector{Int}(undef, 0)
  for i in i_start:length(m.edges)
    if check_edge(m.edges[i], fun, tol, m)
      push!(crit_edges, i)
    end
  end
  return crit_edges
end

function split_edge(i::Int, mesh)
  edge = mesh.edges[i]
  p1, p2, pmp = endpoints(edge, mesh) |> with_mean
  popat!(mesh.edges, i)
  k = popat!(mesh.edge_orientations, i)
  push!(mesh.points, pmp)
  push!(mesh.edges, [edge[1], length(mesh.points)])
  push!(mesh.edges, [length(mesh.points), edge[2]])
  push!(mesh.edge_orientations, k)
  push!(mesh.edge_orientations, k)
end

function check_edge(edge, fun, tol, mesh, absco = p -> abscoords(p, mesh))
  s0, s1, smp = endpoints(edge, mesh) |> with_mean
  ωs0, ωs1, ωsmp = s0, s1, smp
  fs0, fs1, fsmp = fun(ωs0), fun(ωs1), fun(ωsmp)
  d1=abs(fsmp-fs0)/norm(ωs0-ωsmp)
  d2=abs(fs1-fsmp)/norm(ωs1-ωsmp)
  return inner_point_required(max(d1, d2), ωs0, ωs1, fs0, fs1, tol, mesh)
end

function abscoords(p, mesh::Mesh)
  return p
end

function abscoords(p, sm::ScaledMesh)
  return imag_if_necessary(expcoords(p, sm), sm)
end

function with_mean(A)
  a, b = A
  return with_mean(a, b)
end

function with_mean(a, b)
  return a, b, (a+b)/2
end

function inner_point_required(deriv_bound, x1, x2, f1, f2, tol, mesh)
  γ=max(f1, f2)
  return deriv_bound*dist(x2, x1, mesh) >= 2*(γ+tol)-(f1+f2)
end

function refine_i!(mesh::Mesh{TP}, fun, tol) where {TP <: Number}
  E = [0,0]
  new_samples = Vector{TP}(undef, 0)
  for (i, j) in enumerate(2:length(mesh.points))
    E .= (i, j)
    if check_edge([i, j], fun, tol, mesh)
      push!(new_samples, (mesh.points[i]+mesh.points[j])/2)
    end
  end
  if length(new_samples) > 0
    mesh.points =sort(vcat(mesh.points, new_samples))
    update_mesh(mesh)
    return true
  else
    update_mesh(mesh)
    return false
  end
end
