using RecipesBase

@recipe function f(m::Mesh)
  @assert length(m.points[1]) <= 3
  if length(m.points[1]) == 1
    seriestype := :path
    markershape --> :diamond
    markercolor --> :green
    linecolor --> :black
    return m.points, zeros(length(m.points))
  else
    for e in m.edges
      @series begin
        seriestype := :path
        primary := false
        linecolor := :black
        generate_edge_series_data(e, m)
      end
    end
    seriestype := :scatter
    markershape --> :diamond
    markercolor --> :green
    primary := false
    return generate_points_dim_separate(m)
  end
end

function generate_edge_series_data(edge, mesh)
  p1 = mesh.points[edge[1]]
  p2 = mesh.points[edge[2]]
  if length(mesh.points[1]) == 1
    [p1[1], p2[1]], [0, 0]
  elseif length(mesh.points[1]) == 2
    [p1[1], p2[1]], [p1[2], p2[2]]
  else
    [p1[1], p2[1]], [p1[2], p2[2]], [p1[3], p2[3]]
  end
end

function generate_points_dim_separate(mesh)
  n = length(mesh.points)
  m = length(mesh.points[1])
  if m == 1
    return vcat(mesh.points...), zeros(n)
  elseif m == 2
    p1 = Vector{eltype(mesh.points[1])}(undef, n)
    p2 = Vector{eltype(mesh.points[1])}(undef, n)
    for i in 1:n
      p1[i] = mesh.points[i][1]
      p2[i] = mesh.points[i][2]
    end
    return p1, p2
  else
    p1 = Vector{eltype(mesh.points[1])}(undef, n)
    p2 = Vector{eltype(mesh.points[1])}(undef, n)
    p3 = Vector{eltype(mesh.points[1])}(undef, n)
    for i in 1:n
      p1[i] = mesh.points[i][1]
      p2[i] = mesh.points[i][2]
      p3[i] = mesh.points[i][3]
    end
    return p1, p2, p3
  end
end
