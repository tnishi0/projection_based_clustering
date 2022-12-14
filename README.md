# Clustering algorithm based on projections and visual analytics approach

In this project, I developed a new clustering algorithm that combines the visual pattern recognition ability of humans with the power of automated processing. The figure below illustrates the algorithm:

<p align="center">
<img src="fig2.png" width="900">
</p>

1. A set of _p_ features are computed for each node in a given network of nodes (panel __a__). The nodes are then represented as points in the _p_-dimensional feature space, which are projected onto a randomly chosen two-dimensional subspace.

2. Using a graphical interface (see a [video demo of my MATLAB implementation](https://youtu.be/F0hLdxc1nR8) and [code](find_struct_groups)), the user can either reject the projection (panel __b__), which indicates that there is no visible group separation, or indicate visible groups (panel __c__), which automatically assigns a group index to each node for that particular projection.

3. Repeating this for a given number of random projections, each node is associated with a group assignment vector listing the group indices the user has assigned to that node (panel __d__).

4. Dendrogram obtained by the hierarchical clustering algorithm to the assignment vectors (panel __e__). Cutting the dendrogram at a threshold Hamming distance produces a grouping for the network.

5. Quality of grouping as a function of the threshold level (panel __f__). The appropriate number of groups is determined to be 3 for this network, with thresholding at the "elbow" (dashed line).

This algorithm addresses a known issue with the _k_-means algorithm, which tends to divide up clusters that are larger/longer than others in the dataset with hetrogeneous cluster variances. The figure below illustrates this:

<p align="center">
<img src="fig_comparison.png" width="900">
</p>

Even when the correct number of clusters _k_ = 3 is used, the _k_-means algorithm does not correctly identical clusters that exist in this network dataset (panel __a__). In contrast, the algorithm described above correctly identifies the 3 clusters (panel __b__).

For more details, see my journal publication: [T. Nishikawa and A. E. Motter, *Discovering Network Structure Beyond Communities*, Scientific Reports **1**, 151 (2011)](https://doi.org/10.1038/srep00151).
