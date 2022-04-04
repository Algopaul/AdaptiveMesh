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
    update_mesh(mesh)
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
