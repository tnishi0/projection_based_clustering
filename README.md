# Clustering Algorithm based on Projection and Visual Analytics Approach

In this project, I developed a new clustering algorithm that combines the visual pattern recognition ability of humans with the power of automated processing. The figure below illustrates the algorithm:

<p align="center">
<img src="fig2.png" width="1000">
</p>

1. The _p_ features are computed for each node _i_ in a given network of _n_ nodes (panel __a__). The nodes are then represented as points in the _p_-dimensional space, which are projected onto a randomly chosen two-dimensional subspace.

2. Using a graphical interface (see a [demo video of my MATLAB implementation](https://youtu.be/F0hLdxc1nR8) and [code](find_struct_groups)), the user can either reject the projection (panel __b__), which indicates that there is no visible group separation, or indicate visible groups (panel __c__), which automatically assigns a group index to each node for that particular projection.

3. Repeating this for a given number of random projections, each node _i_ is associated with a group assignment vector listing the group indices the user has assigned to node _i_ (panel __d__).

4. Dendrogram obtained by clustering the assignment vectors (panel __e__). Cutting the dendrogram at a threshold Hamming distance _d_ produces a grouping for the network.

5. Quality of grouping as a function of the threshold level _d_ (panel __f__). The appropriate number of groups is determined to be _K_ = 3 by thresholding at the "elbow" (dashed line).

<p align="center">
<img src="fig1.png" width="600">
</p>


The algorithm is described in this publication: [T. Nishikawa and A. E. Motter, *Discovering Network Structure Beyond Communities*, Scientific Reports **1**, 151 (2011)](https://doi.org/10.1038/srep00151)
