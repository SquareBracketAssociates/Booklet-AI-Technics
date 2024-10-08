## Hierarchical Clustering
@sec:AIClustering-HierarchicalClusteringIntroduction

In the previous chapter, we have seen Partitional clustering methods, which generally require a user pre-defined parameter _k_ to obtain a clustering solution. Hierarchical clustering proposes a different type of approach: To build a hierarchy of clusters, **based on the similarity of elements and clusters**, without the need to specify the number of clusters to be generated (the _k_ parameter). Such a built hierarchy is a binary tree. The leaves are the user elements (so-called _data points_) and the nodes are the merges of two clusters. 

The main idea is that the user of this method can obtain a family of significative clusters by **cutting** the tree with a straight horizontal, or vertical, line into N subtrees using a visualization called **dendrogram** (see Figure *@figHC1@*). The level at which to cut a tree is left to the user of the method, as it is highly dependent on the context and it usually requires an exploratory approach and successive interpretations. 

The advantage of hierarchical clustering is that provides an easy way to understand the relationship of the data. Its disadvantage is that it is not suitable for a large number of data points, due to its computational cost and lack of space for visualization.

### What is it?

@sec:AIHClustering-WhatIsIt

Hierarchical clustering (Johnson's, 1967) is a family of unsupervised methods for the decomposition of data based on their similarities, in the form of a binary tree known as a dendrogram. It has two types of methods:

**Agglomerative methods**, one of the sub-types of Hierarchical clustering methods, start by taking each element as a cluster and merge two clusters at a time until there is only one cluster left. So it builds a bottom-up hierarchy of the clusters. 

**Divisive methods**, on the other hand, are the top-down counterpart: Start with one big cluster and split it recursively into two groups generating a top-down hierarchy of clusters. Each level in the hierarchy corresponds to some set of clusters. The leaves of the tree represent the singleton elements.

In practice, the agglomerative type is the most used and it is more suitable to identify small clusters. To distinguish large clusters, the divisive type is better. In this chapter, we will cover Agglomerative methods.

![A basic dendrogram explaining the two types of approaches.](figures/AIBasicDendrogram.png width=100&label=figHC1)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/AIBasicDendrogram}
% \caption{Basic dendrogram}
% \label{figHC1}
% \end{figure}
% }}}

In the next sections, we describe how the agglomeration methods differ visually so we can have a better insight into the differences between different methods to measure similarity. Basically, there are several parts to be aware of:

- Algorithm overview.
- Dendrogram visualization.
- Linkage methods.


### General algorithm overview

@sec:AIHClustering-Overview

The algorithm in pseudocode, without major optimizations, is 


- Data points $P$ and a linkage method $linkageSelector$
- Returns a collection $C$ of clustered instances in dendrogram

```
agglomerateClusters(P, linkageSelector)
 	"Turn each datapoint into a singleton cluster"
	 Clusters := { P1, P2,...,Pn in P }
	 "Build distance matrix"
	 DMatrix := { distance matrix between all pairwise data points P
	 While{not all items are clustered into a single cluster}
	 	{
		 Pair := findClosestPair(Clusters)
		 mergePairIntoNewCluster(Pair)
		 "Compute similarities between new cluster
			 and each of the old clusters"
		 computeDistances(Clusters, linkageSelector)
	 	}
	Return C
```


Initially, numerical data in a collection is passed to the cluster engine and each object is considered as a single-element cluster or point (in a tree they would be represented as leaves). 

The central idea of the algorithm is to combine the two "nearest" clusters - in the first step, each cluster is a data point - into a larger cluster, by calculating the dissimilarity between them, for example, calculating dissimilarity between Points, Points versus Clusters, or between Clusters. 

Such a dissimilarity is calculated using a distance method `BlockClosure` (e.g. Euclidean distance, Manhattan distance, etc). Distance calculation is applied in two contexts: In the first steps when comparing singleton clusters (data points) the distance is applied directly to numerical data (a point), but after the first merge into a larger cluster, there is more than one point in a cluster. Then successive steps need a "representative point" of the new clusters. Different strategies to obtain a new representative to determine which clusters to merge are the linkage methods, for example, the centroid linkage uses the average of points in a cluster. The iteration repeats until there is no more than one cluster.

The key concept of the algorithm is that points (or successive built clusters) are merged into a (or another) cluster. The algorithm will then perform n – 1 merging steps if there are n data points, keeping track of the merging process: for each merging step, remember which clusters (and their distance) are merged to produce which new cluster. 

### Understanding a dendrogram
@sec:AIClustering-Dendrogram

This section contains a brief explanation and annotated figure about how to read a dendrogram. It is useful to understand vocabulary related with this type of visualization. 

The following examples use graphical representations which you can get by installing the **viz** package:

```
Metacello new
	baseline: 'AIViz';
	repository: 'github://pharo-ai/viz/src';
	load: #('AIVizRoassalHC')
```


Note: The viz package also installs Roassal version 2 or 3, depending on the Pharo version you are evaluating the expression. An annotated dendrogram is depicted in Figure *@figHC2@*, where a common visualization option is used which consists of truncating the legs (or arms). The usual option is to let long-legs, this is, branches are truncated to an x-axis or y-axis, and it is useful when combining the dendrogram with a heatmap for example. On the other side, when branches are not truncated, each leg uses the total depth with a depth factor to calculate the length of the line that belongs to each leaf.

![Agglomerative clustering methods : Workflow.](figures/AIHCDendrogram_1-annotated.png width=100&label=figHC2)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/AIHCDendrogram_1-annotated}
% \caption{Hierarchical clustering dendrogram}
% \label{figHC2}
% \end{figure}
% }}}

There are multiple parameters to set up in a dendrogram, such as the orientation:

```
AIR2DendrogramViz from:
	setTopOrientation;
	leafFontSize: 14;
	leafColor: Color black;
	legendTitle: 'A first dendrogram';
	plot.
```


You can explore other options in the class `AIR2DendrogramViz` which contains Roassal 2 compatible options. For Roassal 3 compatibility, you can use `AIR3DendrogramViz`.

### Agglomerative Clustering
@sec:AIClustering-AHC

The key of agglomerative clustering algorithms is to successively merge the input into clusters, until all data points are placed in a single cluster, using a "bottom-up" approach. There are different ways to progressively merge small clusters into larger ones, which are commonly referred to as **agglomeration** or **linkage** methods. 


| Linkage Method | Associated selector | Distance between... |
| --- | --- | --- |
| Average (UPGMA) | `averageLinkage` | All pairwise distances |
| Centroid | `centroid` | Centroids |
| Complete (CLINK) | `completeLinkage` | The farthest members of the clusters |
| Mean | `meanLinkage` | - |
| Single (SLINK) | `singleLinkage` | The closest members of the clusters |

As a user of clustering methods for your own data sets, you should evaluate which agglomeration method fits better for your context. It is important to understand that the selection of the linkage criterion affects both the efficiency and final results of the formed clusters. 

At a code level in Pharo, implies just choosing one of the valid linkage selectors (`Symbol`) as a parameter to the cluster engine method `hierarchicalClusteringUsing:`, but it is necessary to grasp that the main difference between them is **how**" they measure the distance between the clusters and data points, so we may distinguish which ones are similar and most likely to be merged together.

![Agglomerative clustering methods: Workflow.](figures/AIHierarchicalClusteringWorkflow.png width=100&label=figHC3)



#### Input Data
@sec:AIClustering-InputData

This section contains examples with different input formats. There are multiple ways to instantiate a cluster engine, using the `AIClusterEngine class` methods. For a flat `Collection` of `Point`s in an euclidean space:

```
| input |
input := { 
	0.670 	@ -2.428 .
	-0.970 	@ -0.916 . 
	1.203 	@ -0.039 .
	-1.989 	@  0.361 .
	-2.237  @ -0.096 . 
	0.812 	@ -2.422 }.
AIClusterEngine on: input.
```


Also a flat `Collection` of `Number` will create a square matrix of n x n (where n is the collection size) with distances between them:

```
AIClusterEngine on1D: #(25 5 42 15 23 11 43 1 35 31 47 3 2 45 12 41 21 22 32).
```


or by directly providing the distance matrix built from an `Array` of `Number`(s) as input (in this case the input size must be compatible with binomial coefficient (n take: 2), for n >= 2):

```
| distanceMatrix |
distanceMatrix := AIDistanceSquare from: (1 to: 10) asArray.
AIClusterEngine withDistanceMatrix: distanceMatrix.
```


But probably one of the most useful ways is using a DataFrame:

```
| df |
df := DataFrame readFromCsvWithRowNames: 'dataset-90380.csv' asFileReference.
AIClusterEngine with: df standardized.
```


Or by passing directly the CSV String:

```
| df |
df := DataFrame readFromCsvWithRowNames: 'country,child_mort,exports,health,imports,income,inflation,life_expec,total_fer,gdpp
Afghanistan,90.2,10,7.58,44.9,1610,9.44,56.2,5.82,553
Albania,16.6,28,6.55,48.6,9930,4.49,76.3,1.65,4090
Algeria,27.3,38.4,4.17,31.4,12900,16.1,76.5,2.89,4460'.
AIClusterEngine with: df standardized.
```


Next to inputting data into the cluster engine, a linkage method should be configured. We will detail the different linkage methods in the following sections.

#### Single Clustering
@sec:AIClustering-AHCSingleClustering

Also called **Nearest Neighbor** or **SLINK**, it is one of the oldest methods (created approximately in 1950). The method considers the distance of two clusters to be the distance between the closest members of each cluster. This is done basically in two steps: 

- Calculate the distances between the most similar members for each pair of clusters.
- Merge the two clusters for which the distance between the most _similar_ members is the smallest.


```
| df clusty |
df := Datasets loadIris.
clusty := (AIClusterEngine with: df)
	hierarchicalClusteringUsing: #singleLinkage;
	dendrogram.
clusty breakInto: 4.
```


The method `#breakInto:` receives the desired `Number` of groups as argument, and is used to **cut** the tree. The result is an `Array` of dendrogram nodes representing the sub-trees. In practice this method produces sparse clusters. 

The intuitive idea of single linkage can be understood with the Figure *@figHC4@*:

![Single clustering idea.](figures/AISingleClustering.png width=75&label=figHC4)


#### Complete Clustering

@sec:AIClustering-AHCCompleteClustering

Also called **Furthest Neighbor** or **CLINK**. Considers the distance of two clusters to be the distance of the farthest members of each cluster. The method consists tends to produce tight clusters. First it calculates the distances between the most similar members for each pair of clusters, and then merges the two clusters for which the distance between the most _dissimilar_ members is the smallest.

```
| df clusty |
df := Datasets loadIris.
clusty := (AIClusterEngine with: df)
	hierarchicalClusteringUsing: #completeLinkage;
	dendrogram.
clusty breakInto: 4.
```


![Complete linkage method.](figures/AICompleteClustering.png width=75&label=figHC5)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/AICompleteClustering}
% \caption{Complete clustering idea}
% \label{figHC5}
% \end{figure}
% }}}

#### Average Clustering

@sec:AIClustering-AHCAverageClustering

_Work in progress_

**UPGMA** (Unweighted Pair Group Method with Arithmetic Mean). It consists of averaging all distances betweel all pairs of members. This is the default method if none is configured. This method is less affected by outliers.

```
| df clusty |
df := Datasets load....
clusty := (AIClusterEngine with: df)
	hierarchicalClusteringUsing: #averageLinkage;
	dendrogram.
clusty breakInto: 4.
```


![Average linkage method](figures/AIHCAverageClustering.png width=75&label=figHC6)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/AIHCAverageClustering}
% \caption{Average clustering}
% \label{figHC6}
% \end{figure}
% }}}


#### Median Clustering

@sec:AIClustering-AHCMedianClustering

_Work in progress_

The median linkage is a variation of the average linkage which uses the median distance (D'Andrade (1978)). 

```
| df clusty |
df := Datasets load.....
clusty := (AIClusterEngine with: df)
	hierarchicalClusteringUsing: #medianLinkage;
	dendrogram.
clusty breakInto: 4.
```


#### Centroid Clustering

@sec:AIClustering-AHCCentroidClustering

Centroid linkage can be better understood with the Figure *@figHC7@*:

![Centroid clustering](figures/AIHCCentroidlClustering.png width=75&label=figHC7)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/AIHCCentroidlClustering}
% \caption{Centroid clustering}
% \label{figHC7}
% \end{figure}
% }}}

```
| df |
df := Datasets loadIris.
dendron := (AIClusterEngine with: df)
	hierarchicalClusteringUsing: #centroidLinkage;
	dendrogram.
dendron breakInto: 4.
```


_Work in progress_

#### Wards Clustering
@sec:AIClustering-AHCWardsClustering

Computes the sum of squared distances between clusters.
Aggregate clusters with the minimum increase in the overall sum of squares.

_Work in progress_

### Examples
@sec:AIClustering-AHCExamples

The following example opens four dendrogram plots cut at different levels:

```
| input dendron |
input := { 
	0.670 	@ -2.428 .
	-0.970 	@ -0.916 . 
	1.203 	@ -0.039 .
	-1.989 	@  0.361 .
	-2.237  @ -0.096 . 
	0.812 	@ -2.422 }.
dendron := (AIClusterEngine with: input)
	hierarchicalClusteringUsing: #averageLinkage;
	yourself.
(2 to: 5) collect: [ : i | (dendron breakInto: i) plotDendrogram ].
```



### Implementation
@sec:AIClustering-AHCImplementation

The agglomerative hierarchical clustering implementation is based on Hapax, a software analysis tool developed by Adrian Kuhn. `AIClusterEngine` is the main class.

The main entry point class is `AIClusterEngine` instantiated on an input `Collection`. The cluster engine will calculate a distance between all the elements filling a distance matrix (`AIDistanceSquare`). The internal implementation of the cluster engine wraps a "partial matrix": this is a type of optimized matrix which only includes and works on the lower triangular elements, avoiding duplicating the upper triangular ones (all `AISymmetricMatrix`es will contain the same elements).

The most important method here is class side `defaultDistanceBlock`:

```
defaultDistanceBlock
	
	^[ :a :b | a distanceTo: b ]
```


This implementation enables you to subclass `AISymmetricMatrix` and re-implement it - for different types of matrices or input elements - to use a different metric evaluation strategy between data points (See for example `AICorrelationSquare`) which re-implemented as:

```
defaultDistanceBlock
	
	^[ :a :b | a similarity: b ]
```


The `dist:` method is implemented in multiple classes, and it matches the name of the equivalent implementation in R language. The representative implementation is the one in `Point`, but other implementations which could be interesting to use or replicate are `AIFeatureCollection` (hausdorff distance between collections), or the `AIVector` (implements the sum of squares).

As the input `Collection` is iterated, the matrix will be populated in a row-fashioned way with `AIArrayVector` instances. This means that each iteration will be filled by rows. Once the distance matrix is ready, the clustering can be performed using the message `hierarchicalClusteringUsing:`

![Symmetric Matrix class hierarchy.](figures/AIHCSymmetricMatrix.png width=75&label=figHC8)

As mentioned previously, the entry point method of cluster engine instance is `hierarchicalClusteringUsing: aSymbol`(where aSymbol is a selector, specifically a linkageSelector, which specifies the agglomeration method to be used). The available linkage selectors are described in Table 1. The default linkage is `#averageLinkage`, which is described in the next sections. 

The available linkage methods can be listed as follows:

```
AIClusteringData linkageFunctions.
```


Once the agglomeration selector is set, the cluster engine instance is asked for its dendrogram. The dendrogram is obtained by building a distance (a.k.a dissimilarity) matrix, but you may set it manually, and it will look like this:

```
(AIClusteringData onDistanceSquare: distanceMatrix) performClustering: #... 
```


After the formation of a cluster, the distance matrix is updated. This is done by performing row and column permutations using an optimal re-ordering technique called **Seriation**. It is implemented in the method `performSeriation`.

