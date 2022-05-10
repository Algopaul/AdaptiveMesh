# AdaptiveMesh

Implements a generalization of the adaptive sampling algorithm as in [SV2021](#References), which is based on [AN2018](#References), to n-dimensional grids.

The function `update_mesh` adds new edges to the mesh based on the following rule. If two points with Hamming norm distance 1 are not connected and there is no edge between them, then add an edge between them. A visualization of this in 2d is:
```
x--x--x     x--x--x
            |  |  |
x     x     x  |  x
        --> |  |  |
x  x  x     x--x--x
|  |        |  |  |
x--x  x     x--x--x
```
Note that no edges are added *off-axis*.

The function ``refine_i!`` adds new points on edges such that a function ``fun`` (passed as argument) is resolved sufficiently accurate on the edges. The function ``refine!`` alternates between the functions ``refine_i`` and ``update_mesh`` to make sure that the given function is resolved sufficiently accurate on the domain of the mesh.

##References

```latex
@article{SV2021,
  title = {Adaptive Sampling for Structure-Preserving Model Order Reduction of Port-{H}amiltonian Systems},
  author = {Schwerdtner, P. and Voigt, M.},
  note = {7th IFAC Workshop on Lagrangian and Hamiltonian Methods for Nonlinear Control, Berlin, 2021},
  journal = {IFAC-PapersOnline},
  volume = {54},
  number = {19},
  pages = {143--148},
}

@article{AN2018,
  author = {Apkarian, P. and Noll, D.},
  title = {Structured $\mathcal{H}_\infty$-control of infinite-dimensional systems},
  journal = {Internat. J. Robust Nonlinear Control},
  volume = {28},
  number = {9},
  pages = {3212--3238},
  year = {2018}
}
```
