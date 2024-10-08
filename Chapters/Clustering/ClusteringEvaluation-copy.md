## Clustering evaluation
@sec:AIClustering-Basics

Every clustering algorithm has its own advantages and drawbacks. Validation of cluster analysis is an important aspect of measuring how well multiple clustering methods performed on a data set. As clustering is more about discovering than an exact prediction method, several indices can be used to determine if the right number of clusters were discovered. This is what the K in clustering algorithms (k-means, k-medians, kNN) is about after all.

Roughly, there are two major strategies to assess clustering quality:

**External cluster evaluation**: This involves comparing the results of a clustering method with already known labels of another reference cluster. This type of assessment is similar to supervised learning, in the sense that at least one of the clustering results is considered to have the ground truth clusters or represents the optimal solution. Examples of this type of metric are the _Rand Index_ (Rand, 1971), the _Adjusted Rand Index_ or _ARI_ (Hubert and Arabie, 1985), the _F-measure_, the _Jaccard Index_ (Anderberg, 1973), the _Dice Index_ (Dice, 1945; Sørensen, 1948) and the _Normalised Mutual Information_ or _NMI_.

**Internal cluster evaluation**: This does not use information outside the dataset, like human annotations, and involves summarization into a single quality score. In many applications ground truth labels are not available (consider for example streaming applications). Examples of this type of metric are the _Root-mean-square standard deviation_ or _RMSSTD/RMSD/RMSE_ and the _R-squared_ or _RS_ (Sharma, 1996), the _Silhouette Coefficient_ (Rousseeuw, 1987), the _Davies-Bouldin Index_ or _DB_ (Theodoridis and Koutroubas, 1999).

### Installation
@chap:AIMetrics-Installation

All algorithms described in this chapter are part of the AIMetrics project which can be found at [https://github.com/pharo-ai/AIMetrics](https://github.com/pharo-ai/AIMetrics). To install AIMetrics, go to the Playground in your Pharo image and execute the following snippet.

```
Metacello new
  baseline: 'AIMetrics';
  repository: 'github://pharo-ai/metrics/src';
  load.
```


### API Definition
@sec:AIMetrics-APIDefinition

We will introduce here general conventions and practices understood by all metrics. These methods are considered stable and supported for all metrics implemented in the `AIMetrics` package. 

Most, if not all, metrics are known with different names. All the metrics subclass `AIClusteringMetric` and implement the #names method answering a `Collection` of sub-collections, where each one contains the synonyms for each metric in English language. You can obtain all the available metrics names with `availableMetricNames` as follows:

```
AIClusteringMetric availableMetricNames.
	"#(
	#('Rand Index' 'RI' 'General Rand Index') 
	#('Adjusted Rand Index' 'HA' 'ARI') 
	#('Jaccard Index' 'Intersection over union' 'Tanimoto coefficient' 'IOU') 
	#('Fowlkes Mallows index' 'FMI' 'FM' 'Gmean' 'G-mean') 
	#('Mirkin Index') 
	#('Rand Index' 'RI' 'General Rand Index')
	)"
```


Also all metrics return a `Float` value. In this case, a utility method to configure the number of wished decimals is provided for any metric:

```
	AIAdjustedRandIndex new numberOfWishedDecimal: 4.
```


To configure the default number of wished decimal for any metric, you may override the `defaultNumberOfWishedDecimal` method in your own class.

The method to obtain the **resulting metric** for any metric implementation is `computeMetric`. This method always returns a `Float`, even for cases where a formula has no defined behavior. In this case, we explicitly state the situation in the method comment.

All clustering metrics implement `clusterA` and `clusterB` accessors (getters and setters) with collections as inputs to be compared. It is not enforced clusterA to represent the _ground truth_, however, it is common practice to configure the collection with "truth labels" as the first parameter, and the second collection to be interpreted as the collection with predictions (predictions are the result of your clustering algorithm).

### Rand Index
@sec:AIMetrics-RandIndex

A "Rand Index" (RI) is a Float between 0.0 and 1.0 representing the number of agreements between two data clusterings, presumably from two different methods on the same data set. You may use the Rand Index score to compare how two partitions (clustering results) agreed. A value of 1.0 means that clusterings between two methods were the same, and these partitions agree perfectly, and 0.0 means that the two data clusterings disagree on any pair of points.

#### Formal Definition
@sec:AIMetrics-Definition

Let $C_1$ and $C_2$ be two sets, the $Rand Index(R)$ is defined by the formula:

$$
R(C_1,C_2) = \frac{a+b}{a+b+c+d} = \frac{a+b}{{n \choose 2 }}
$$


where:

- $a$ is the number of pairs of elements that are in the same subset in both sets $C_1$ and $C_2$.
- $b$ is the number of pairs of elements that are in different subsets in both sets $C_1$ and $C_2$.
- $c$ is the number of pairs of elements that are in the same subset in $C_1$ but in different ones in $C_2$
- $d$ is the number of pairs of elements that are in different subsets in $C_1$ but in the same in $C_2$
- $a + b$ the number of correct similar pairs plus the number of correct dissimilar pairs.
- $n \choose 2 $ is the number of total possible pairs (without ordering).


If one of the partitions is considered to have the ground truth labels, the index can be also analyzed as counting the _True Positives_ (TP), _True Negatives_ (TN), _False Positives_ (FP), and _False Negatives_ (FN) with the following equivalent formula:
$$
RI = \frac {TP + TN}{TP + FP + FN + TN} 
$$


In such a case, it is common to refer to the first set as having "true clusterings" and the second set as representing the "predicted clusterings". The interpretation of terms under such a view of the index is:


| TP | Pairs of elements which belong to class positive and we clustered it as positive |
| FP | Pairs of elements which belong to class negative and we clustered it as positive |
| FN | Pairs of elements which belong to class positive and we clustered it as negative |
| TN | Pairs of elements which belong to class negative and we clustered it as negative |

#### Algorithm Description
@sec:AIMetrics-RIAlgorithmDescription

The algorithm is based on counting pairs of elements from both sets. It builds every possible unordered pair of elements in each cluster result. Which pairs? The answer is the binomial coefficient and you can easily print this combination for any Collection by evaluating:

```
Transcript open.
#(A B C)
	combinations: 2 
	atATimeDo: [ :each | each traceCr ].
```


Then it counts the number of pairs, **in terms of indices**, which are in both clustering methods, and the number of pairs which are in different clusters. We will see this in detail in the following partial example.

#### Simple Example
@sec:AIMetrics-RISimpleExample

We begin considering the most basic cases, to get an overview of the API. We can obtain the Rand index in Pharo using the `AIRandIndex` class. In this case we will be passing two clusterings (Collections) of 5 assignments each one. Notice both input collections must have the same number of assignments, and each one could take a value of 1, 2 or 3. Conceptually, each assignment represents a pair, but this will be more clear in a follow-up example. For now, let's check two exact clusterings (both sets have the same assignments):

```
AIRandIndex 
    clusterA: #(1 1 2 3 3) 
    clusterB: #(1 1 2 3 3).
```

The result in the Rand Index is 1.0. If we consider two partitions without any pair in common:

```
AIRandIndex 
    clusterA: #(0 0 0 0 0 0) 
    clusterB: #(0 1 2 3 4 5).
```

Results in 0.0, as every pair of points are in different clusters. The index is also symmetric:

```
AIRandIndex 
    clusterA: #(0 1 2 3 4 5)
    clusterB: #(0 0 0 0 0 0).
```


yields the same result as above of 0.0.

#### Partial Agreement Example
@sec:AIMetrics-RIUserExample

Imagine your application has queried five famous philosophers. One clustering method (such as k-means, k-medians, DBSCAN, or other) discovered three clusters (say 1, 2, and 3), and these are stored in $clusterResult1$. Another method discovered also three clusters, storing them to $clusterResult2$ respectively. Notice that, in common tasks, one of these clusterings may be considered the reference cluster, for example, if one of them has a column which assigned the true labels. 

We may represent the clustering as follows:

```
| clusterResult1 clusterResult2 |

clusterResult1 := { 
	'Spinoza'  -> 1 . 'Bentham' -> 1 . 
	'Kant'     -> 2 . 
	'Foucault' -> 3 . 'Plato'   -> 3 } collect: #value.

clusterResult2 := { 
	'Spinoza'  -> 1 . 'Bentham'  -> 1 . 
	'Kant'     -> 2 . 'Foucault' -> 2 .
	'Plato'    -> 3 } collect: #value.
```


Our collection has 5 elements, which results in 10 possible pairs of points for each clustering: 

$$
\begin{split}
pairsClusterResult1 \Rightarrow \{ \\
Pair \{1, 2\} = (Spinoza, Bentham) = (Cluster 1, Cluster 1) \\
Pair \{1, 3\} = (Spinoza, Kant) = (Cluster 1, Cluster 2)   \\
Pair \{1, 4\} = (Spinoza, Foucault) = (Cluster 1, Cluster 3) \\
Pair \{1, 5\} = (Spinoza, Plato) = (Cluster 1, Cluster 3) \\
Pair \{2, 3\} = (Bentham, Kant) = (Cluster 1, Cluster 2) \\
Pair \{2, 4\} = (Bentham, Foucault) = (Cluster 1, Cluster 3) \\
Pair \{2, 5\} = (Bentham, Plato) = (Cluster 1, Cluster 3) \\
Pair \{3, 4\} = (Kant, Foucault) = (Cluster 2, Cluster 3) \\
Pair \{3, 5\} = (Kant, Plato) = (Cluster 2, Cluster 3) \\
Pair \{4, 5\} = (Foucault, Plato) = (Cluster 3, Cluster 3) \\ \}
\end{split}
$$


And now we define the pairs for the second clustering results:

$$
\begin{split}
pairsClusterResult2 \Rightarrow \{ 
Pair \{1, 2\} = (Spinoza, Bentham) = (Cluster 1, Cluster 1) \\
Pair \{1, 3\} = (Spinoza, Kant) = (Cluster 1, Cluster 2) \\
Pair \{1, 4\} = (Spinoza, Foucault) = (Cluster 1, Cluster 2) \\ 
Pair \{1, 5\} = (Spinoza, Plato) = (Cluster 1, Cluster 3) \\
Pair \{2, 3\} = (Bentham, Kant) = (Cluster 1, Cluster 2) \\ 
Pair \{2, 4\} = (Bentham, Foucault) = (Cluster 1, Cluster 2) \\
Pair \{2, 5\} = (Bentham, Plato) = (Cluster 1, Cluster 3) \\
Pair \{3, 4\} = (Kant, Foucault) = (Cluster 2, Cluster 2  \\
Pair \{3, 5\} = (Kant, Plato) = (Cluster 2, Cluster 3) \\
Pair \{4, 5\} = (Foucault, Plato) = (Cluster 2, Cluster 3) \\
\end{split}
$$

Now let's proceed to count pairs of indices, summing up 1 as each case appears according to the four cases in the Rand Index formula. 
Our initial state for the four cases is a = 0, b = 0, c = 0 and d = 0. To follow the next iterations, recall the formula we previously defined in the Formal Definition section:

- Pair {1, 2} in $pairsClusterResult1$ and $pairsClusterResult2$ both have (1,1) -> they are assigned to the same cluster in $pairsClusterResult1$ and $pairsClusterResult2$. $a$ is incremented \$a\$ = 1
- Pair {1, 3} in $pairsClusterResult1$ and $pairsClusterResult2$ both have (1,2) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 1)
- Pair {1, 4} in $pairsClusterResult1$ is (1,3) and in $pairsClusterResult2$ is (1,2) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 2)
- Pair {1, 5} in $pairsClusterResult1$ and $pairsClusterResult2$ both have (1,3) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 3)
- Pair {2, 3} in $pairsClusterResult1$ and $pairsClusterResult2$ both have (1,2) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 4)
- Pair {2, 4} in $pairsClusterResult1$ is (1,3) and in $pairsClusterResult2$ is (1,2) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 5)
- Pair {2, 5} in $pairsClusterResult1$ and $pairsClusterResult2$ both have (1,3) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 6)
- Pair {3, 4} in $pairsClusterResult1$ is (2,3) and in $pairsClusterResult2$ is (2,2) -> they are assigned to different cluster in $pairsClusterResult1$ and the same cluster in $pairsClusterResult2$, $d$ is incremented (d = 1)
- Pair {3, 5} in $pairsClusterResult1$ and $pairsClusterResult2$ both have (2,3) -> they are assigned to different cluster in $pairsClusterResult1$ and different cluster in $pairsClusterResult2$, $b$ is incremented (b = 7)
- Pair {4, 5} in $pairsClusterResult1$ is (3,3) and in Y is (2,3) -> they are assigned to ths same cluster in $pairsClusterResult1$ and different cluster in Y, $c$ is incremented (c = 1)


We replace a, b, c and d with the values into the RI formula:
$$
R(C_1,C_2) = \frac{1+7}{1+7+1+1} = \frac{1+7}\{{5 \choose 2 \}} = 0.8 
$$


You can confirm the result by evaluating:

```
AIRandIndex 
    clusterA: #(1 1 2 3 3) " clusterResult1 "
    clusterB: #(1 1 2 2 3). " clusterResult2 "
```


The Rand Index results is "0.8", and it represents the fraction of all pairs of points on which the two clusterings agree. 

In practice, the RI do not use the full range of possible values, and most of them lies between \[0.5, 1\] concentrating near the extremes. The problem is the classic RI is highly dependent upon the number of clusters: When the data set used is small or the number of clusters increases, there is a higher chance of agreements are overlapped just due to chance. Most applications fix this by applying one or several corrected versions of the RI. A variation of RI should enable to adjust the amount of agreement in the cluster solutions with chance normalization, this means measuring **proportions of agreements** between the two partitions, and ignoring permutations, meaning that renaming labels does not affecting the score.

This is what we will see in the next section.

### Adjusted Rand Index

@sec:AIMetrics-ArjustedRandIndex

The "Adjusted Rand Index" (ARI) is a Float between -1.0 and 1.0, where positive values mean that pairs in the known clusters and predicted clusters are similar, being 1.0 the perfect agreement and 0.0 a chance agreement, and negative values mean that pairs in the known clusters and predicted clusters are highly different. In short, the higher the value of ARI, the better the predictive ability of the evaluated clustering method. The "adjusted" part comes from the fact that a random result is scored as 0.

A word of caution: There are several measures of ARI, and actually the first two initial implementations are used in the literature with similar names: The _Morey and Agresti_ (1984) is usually referred as MA or $ARI_{ma}$, and a corrected version from _Hubert and Arabie_ (1985) known as HA or $ARI_{ha}$. Variations of these ARI were further developed, among the most popular ones we may find the _Fowlkes–Mallows Index_ or FMI and the _Mirkin Metric_ (Mirkin, 1996).

In this section we will describe first the $ARI_{ha}$ formula.

#### Formal Definition

@sec:AIMetrics-ARIDefinition

The $ARI_{ha}$ is defined by the equation:
\\[	ARI\_{ha} = \dfrac{\sum\_{i,j}{n\_{ij} \choose 2} - \sum\_{i}{n\_{i.} \choose 2}\sum\_{j}{n\_{.j} \choose 2} / {n \choose 2\}}{\frac{1}{2}\[\sum\_{i}{n\_{i.} \choose 2}+\sum\_{j}{n\_{.j} \choose 2}\]-\sum\_{i}{n\_{i.} \choose 2}\sum\_{j}{n\_{.j} \choose 2} / {n \choose 2\}} \\]


This form is commonly used to explain the details of the distribution which models the randomness (called the hyper-geometric distribution). Also it allows to describe the typical implementation of the algorithm, which uses a contingency table. 

- $n_ij$ is the diagonal sums (when i = j).
- $a_i$ is the row sums.
- $b_j$ is the column sums.


Another notation for the formula is often expressed with the following representation of terms:

 
\\[ ARI\_{ha} = \frac{\text{RI} - E\[\text{RI}\]}{\max(\text{RI}) - E\[\text{RI}\]} \\]


where:

- The numerator RI is the (General) Rand Index.
- The denominator max(RI) represents the maximum possible RI, defined as the permutation sum of rows plus sum of columns divided then by 2:  \\[ Max(RI)=\frac{\sum{a\_i\choose2}+\sum{b\_j\choose2\}}{2} \\] 
- E(RI) is the Expected Maximum Index, which is used to obtain a correction to the Rand Index:  \\[ E(RI)=\sum\_{i}{n\_{i.} \choose 2}\sum\_{j}{n\_{.j} \choose 2} / {n \choose 2} \\] 


#### Algorithm Description

@sec:AIMetrics-ARIAlgorithmDescription

The algorithm constructs a contingency table (also known as a cross tabulation) by counting the co-occurrences of both cluster results. In general terms, a contingency table is used to describe data which has more than one categorical variable. The rows represents categorical variables with the truth values, say from $clusterResult1$, and columns represents values from predictions, for example in $clusterResult2$. This kind of matrix usually includes an extra row and a right-most column representing the **marginals**, used to asses statistical significance. Each cell in the matrix, i.e. each intersection, is the number of times an element appears in the combination of the particular row and column intersected. The right-bottom cell represents the total number of elements involved and is called the **grand total**. 

The contingency table for our example with philosophers is:
\\[ \mathbf{CTAB}=\begin{bmatrix}2 & 0 & 0\\
0 & 1 & 0\\
0 & 1 & 1\\
\end{bmatrix} \\]


A decomposition of the equation terms with substitution of variables:
\\[ \sum\_{ij} \binom{n\_{ij\}}{2}  = \binom{2}{2} + \binom{1}{2} + \binom{1}{2} = 4 \\]

\\[ \sum\_i \binom{a\_j}{2} = \binom{2}{2} + \binom{1}{2} + \binom{1}{2} = 4 \\]

\\[ \sum\_j \binom{b\_j}{2} = \binom{2}{2} + \binom{2}{2} + \binom{1}{2} = 5 \\]


Therefore
\\[ ARI = \frac{1 - 2 * 2 / 10}{(2 + 2)/2 - 2 * 2 / 10} =  0.375 \\]


Which can be verified with:

```
AIAdjustedRandIndex 
    clusterA: #(1 1 2 3 3) " clusterResult1 "
    clusterB: #(1 1 2 2 3). " clusterResult2 "
```


We can observe 0.375 is much lower than the Rand Index result of 0.8, which is expected and a common situation, considering the Adjusted Rand Index can result in negative values for very dissimilar clusterings. To follow a standard interpretation of the result, Steinley (2004) indicates the following levels of agreement:

- An index greater than 0.90 are considered excellent recovery
- An index greater than 0.80 are considered good recovery 
- An index greater than 0.65 are considered moderate recovery 
- An index less than 0.65 are considered poor recovery


### Fowlkes–Mallows Index

@sec:AIMetrics-FMI

The _Fowlkes–Mallows Index_, also known as G-measure or FM, is a Float value between 0.0 and 1.0. It is an external evaluation method which is the geometric mean of precision and recall between two clusterings. The index can be used either for comparing flat and hierarchical clusterings.

#### Formal Definition

@sec:AIMetrics-FMIDefinition

The FM index is commonly defined using information extraction terms:
\\[ \text{FMI} = \frac{\text{TP\}}{\sqrt{(\text{TP} + \text{FP}) (\text{TP} + \text{FN})\}} \\]


You may obtain the index in Pharo with the following expression:

```
	AIFowlkesMallowsIndex
		clusterA: #(1 1 2 3 3) " clusterResult1 "
		clusterB: #(1 1 2 2 3) " clusterResult2 "
```


### Jaccard Coefficient

@sec:AIMetrics-Jaccard

The Jaccard Index, also known as the Jaccard similarity coefficient, is a Float value between 0.0 and 1.0. It was originally designed as a general similarity measure between two non-empty sets, but it can be used as an evaluation measure of the degree of overlap between vectors. Intuitively, it can be thought as the size of the intersection divided by the size of the union. As usual, the closer to 1.0, the more similar the two datasets, the closer to 0.0 the more dissimilar. This metric should not be confused with the **Jaccard distance**, which gives a **dissimilarity** measure.

This metric is also known as "IoU" or Intersection over Union, specially in image detection contexts. 

#### Formal Definition

@sec:AIMetrics-JaccardDefinition

The formal definition for the set-based version is:
\\[ J(A,B) = \{{|A \cap B|}\over{|A \cup B|\}} = \{{|A \cap B|}\over{|A| + |B| - |A \cap B|\}} \\]	


and it could appears also as:
\\[ J = TP / (TP + FP + FN) \\]


This formula is mostly used for binary classification tasks, i.e. elements in each input set are present or absent.

We will see below there is generalized version of the original formula. The formal definition for This version is:
\\[ J\_\mathcal{W}(\mathbf{x}, \mathbf{y}) = \frac{\sum\_i \min(x\_i, y\_i)}{\sum\_i \max(x\_i, y\_i)} \\]


#### Algorithm Description

@sec:AIMetrics-JaccardDescription

It is important to remark there are actually two versions of the Jaccard similarity index: A set-based version, and a vector-based (weighted) version. Both formulas are equivalent, but the vector-based version is just another method which was later implemented as a generalized version of the set-based one. The set-based version accept as input _instance sets_ such as flat Collections of different sizes, while the vector-based version has the requirement of both input collections to have the same size. Also, under the weighted/vector-based variation, the elements of the union of both collections are considered as features, and a binary-vector is built where 0 means absence and 1 means presence of a feature, for both the numerator (with the minimum 1 or 0 at each feature) and denominator (with the maximum 1 or 0 at each feature). Finally both numerator and denominator are summed.

To better understand the difference between the set-based and vector-based versions, let's consider the set version first with inputs:

```
	cluster1 := { 'Plato' . 'Foucault' . 'Kant' }.
	cluster2 := { 'Plato' . 'Foucault' . 'Spinoza' . 'Bentham' }.
```


We should note here we do not have the cluster assignment information for any philosopher, but it is important to understand why it could be easier to apply the set-based version formula:
\\[ {|cluster1 \cap cluster2|} = \{ Plato, Foucault, Kant \} = 3 \\]
\\[ {|cluster1 \cup cluster2|} = \{ Plato, Foucault, Kant, Spinoza, Bentham \} = 5 \\]
\\[ J(cluster1,cluster2) = {3 \over 5 } = 0.6 \\]


Under the vector-based version, we "binarize" the features marking for presence/absence at each element position of the collection. And the sum of each vector divided give us the same result as expected:

```
	cluster1 := { 1 . 1 . 1 . 0 . 0 }.
	cluster2 := { 1 . 1 . 1 . 1  .1 }.
	(cluster1 sum / cluster2 sum) asFloat. "0.6"
```


#### Simple Example

@sec:AIMetrics-JaccardSimpleExample

It is clear now that if we have assignment information for each philosopher, we should use the weighted Jaccard version. In such case, the `AIWeightedJaccardIndex` explicitly uses the vector-based version:

```
	AIWeightedJaccardIndex
		clusterA: #(0 0 0 0)
		clusterB: #(0 1 2 3) " 0.25 "
```


If we interpret clusterA and clusterB as instance sets (flat collections), we can obtain the Jaccard coefficient with the following expression:

```
	AIJaccardIndex
		clusterA: #(0 0 0 0)
		clusterB: #(0 1 2 3) " 0.25 "
```


As can be seen, both versions are equivalent and it is the interpretation of the input data what could change.


### Mirkin Index

@sec:AIMetrics-Mirkin

The Mirkin Index is an adjusted variation of the Rand Index, 

_This metric is possibly outdated_

### Normalised Mutual Information (NMI)

@sec:AIMetrics-NMI

Mutual information (MI) is a concept from information theory, which involves the outcomes of two random variables (such as flipping coins). The idea is that when you know the value of one the variables, then you can measure the reduction of the uncertainty for predicting the outcome of another one. The MI is a measure of such reduction. NMI is a specialization of MI, and it is a `Float` number between 0.0 and 1.0. When its value is 0.0, means that knowing the value of a variable implies that there is no reduction in uncertainity for another one, so it is completely uncorrelated. It can be thought as the information a variable has about another variable.

_How to describe this metrics in terms of clustering evaluation_

Both NMI and MI are not adjusted against chance.

##### Formal Definition

@sec:AIMetrics-NMIDefinition

 
\\[ \text{NMI}(U, V) = \frac{\text{MI}(U, V)}{\text{mean}(H(U), H(V))} \\]


#### Simple Example

@sec:AIMetrics-NMISimpleExample

```
	AINMIIndex
		clusterA: #(0 0 0 0)
		clusterB: #(0 1 2 3)
```



### Silhouette Coeffecient

@chap:AIMetrics-Silhouette

The Silhouette Coeffecient (also known as the Silhouette Index) is a Float value between -1.0 and 1.0 and represents a measure of how well observations are separated from neighboring clusters. A high value means that the object is well suited to its own cluster, and poorly suited to the adjacent cluster. It is useful when ground-truth labels are not known, which makes this metric an intrinsic evaluation type. Advantages of the Silhouette Index are that can used with any clustering algorithm, and may provide a concise graphical representation of how well each object has been categorized.

#### Formal Definition

@sec:AIMetrics-SilhouetteDefinition

The Silhouette Coeffecient, for a single sample, is defined by:
\\[ s = \frac{b - a}{max(a, b)} \\]


where:

- $a$ (also called the **cluster cohesion**) represents the average intra-cluster distance, i.e. the distance between a data point and all other points in the same cluster.
- $b$ (also called the **cluster separation**) represents the average inter-cluster distance, i.e. the distance between a data point and all other points in the cluster nearest to the data point's cluster.


#### Algorithm Description

@sec:AIMetrics-SilhouetteDescription

The method is based on the average distance from one given object to those of the same cluster as that object, compared with the similar average distance from the best alternative cluster. Roughly, the steps involved in the algorithm are:

- Calculate the average distance within the cluster.
- Each cluster member has its own average distance from all other members of the same cluster.
- The average of these averages is the dissimilarity score for the cluster.


_Work in Progress_
