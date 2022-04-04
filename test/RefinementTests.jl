using AdaptiveMesh, LinearAlgebra
using Test

function Refinement_test_on2D(tol = 1.0)
  M = MeshGrid2d(1.0:5.0, 1.0:5.0)
  f(x) = exp(norm(x))
  AdaptiveMesh.refine!(M, f, tol)
  for e in M.edges
    @test AdaptiveMesh.check_edge(e, f, tol, M) === false
  end
end

function Refinement_test_scaled_on2D(tol = 1.0)
  M = ScaledMesh(MeshGrid2d(log10.(1.0:5.0), 1.0:5.0), axis_imag = [true, false], axis_log = [true, false])
  f(x) = exp(norm(x))
  AdaptiveMesh.refine!(M, f, tol)
  for e in M.mesh.edges
    @test AdaptiveMesh.check_edge(e, f, tol, M) === false
  end
end

@testset "Refinement Tests" begin
  Refinement_test_on2D()
end
