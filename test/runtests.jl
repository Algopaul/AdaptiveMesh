using AdaptiveMesh
using Test

"""
Make sure that
x--x--x     x--x--x
            |  |  |
x     x     x  |  x
        --> |  |  |
x  x  x     x--x--x
|  |        |  |  |
x--x  x     x--x--x
"""
function TestConnection_Case2D()
  Points = [[0, 0], [1, 0], [2, 0], [0, 1], [1, 1], [2, 1], [0, 2], [2, 2], [0, 3], [1, 3], [2, 3]]
  edges = [[1, 2], [1,4], [2,5], [9, 10], [10, 11]]
  expected_edges = [[2, 3], [4, 5], [5,6], [3, 6], [4, 7], [5, 10], [6, 8], [7, 9], [8, 11]]
  M = Mesh(Points, edges)
  update_mesh(M)
  for expected_edge in expected_edges
    @test expected_edge ∈ M.edges
  end
end

"""
Make sure that all required points are connected. Use Plot function to verify behavior.
"""
function TestConnection_Case3D()
  Points = [[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1], [0, 0.5, 0.5], [0, 0.5, 1], [0.5, 0.5, 0.5], [0.5, 1, 1], [0.5, 0.5, 1], [0.5, 1, 0.5], [0, 1, 0.5]]
  M = Mesh(Points)
  update_mesh(M)
  @test length(M.edges) == 24
end

@testset "AdaptiveMesh.jl" begin
  TestConnection_Case2D()
  TestConnection_Case3D()
end

include("./RefinementTests.jl")


