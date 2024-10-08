## Partitional Clustering
@sec:AIClustering-Basics

Real-world data is complex. To make sense of complex data requires approaches to shape it. While trying to make sense of it we can discover patterns to understand our data better. One of the well-known methods for such a goal is clustering. A cluster is a set of objects that share similar features, while clustering is called the technique that divides the observations (called _data points_ in the Machine Learning vocabulary) into groups to get an insight into this data in an **unsupervised way**. Clustering is also viewed as automatic labeling a dataset, by discovering the groups in it. You can use clustering methods, for example, to identify communities in social networks, group music for different themes, perform customer segmentation, and implement a recommendation system, among many other use cases.

In a more object-oriented sense, a clustering algorithm is an object that can group data points and implement multiple features such as exclusiveness, nesting, completeness, and others such as metrics factors. We will discuss in the next sections its properties, although our main focus will be on how to apply clustering techniques in such a way that you could translate it into your experiments. We start by showing a high-level description of the API and then move to experiment with a toy dataset so you can get an overview of some available methods to play with. 

In the next chapter, you can read how to validate your own Machine Learning clusterings with the help of the MLMetrics package.

### API
@sec:AIClustering-APIIntroduction

The following section will describe a few properties of the clustering algorithms. They are not mandatory to learn or use if the goal is to build a model to make predictions, but they are a good basis for understanding which clustering technique to use in case it is not self-evident for your problem at hand. Sometimes multiple techniques could be tried before reaching a definitive conclusion. It is important to understand the process is highly-dependent on the context, and the properties of the dataset you want to cluster.

### Exclusiveness
@sec:AIClustering-Exclusiveness

A clustering algorithm could consider its observations to be:

- **Exclusive**: Each observation can only belong to one cluster. Answers <true> to the message `isExclusive`.
- **Overlapping**: An observation could be grouped in multiple clusters. Answer <true> to the message `isOverlapping`.
- **Fuzzy**: Maps each observation to its own cluster. Answer <true> to the message `isFuzzy`.


To get which kind of exclusiveness implements the k-mean algorithm:

```
MLKMeans isExclusive
```


#### Nesting
@sec:AIClustering-Nesting

Another distinguishing characteristic is when the algorithm allows clusters to be nested. These types of algorithms are said to implement **Hierarchical Clustering** (examples are the algorithms DBSCAN, OPTICS, and Ward). On the other side, when nesting is not allowed during cluster formation, it is **Partitional Clustering** (algorithms k-means, k-medoids, k-medians, mean-shift, etc). We can obtain which type of nesting implements a class using the following methods:

- **Hierachical Clustering**: Answer <true> to the message `isHierarchical`.
- **Partitional Clustering**: Answer <true> to the message `isPartitional`.


For example to get which type of nesting implements the k-mean algorithm:

```
AIKMeans isPartitional.
```


#### Completeness
@sec:AIClustering-Completeness

It applies to observations that could be left without belonging to any cluster. To query which kind is implemented by a class, we have two methods:

- **Complete**: All observations are assigned to a cluster. Answer _<true>_ to the message `isComplete`.
- **Partial**: There are observations that could have no cluster. Answer _<true>_ to the message `isPartial`.


### k-means Clustering
@sec:AIClustering-KMeansIntroduction

_k-means_ (Sebestyen (1962), MacQueen(1967)) is a clustering prediction method from an unlabeled dataset. It is very popular due to being fast, but as a drawback, it requires a number of clusters (k) to be specified beforehand. In this regard, an inappropriate choice for _k_ may result in a poor clustering performance. 

Another requirement of _k-means_ is that variables to be analyzed must be normalized (standardized). The procedure to ensure the variables are normalized is to scale them so the mean is zero and the standard deviation (the sum of the covariance) is one. Such standardized real numbers are also known as z-scores. Normalization is a common step while doing exploratory analysis, as part of a data wrangling stage before applying any machine learning algorithm.

#### Algorithm Description

@sec:AIClustering-KMeansDescription

The k-means formulation builds **non-overlapping** groups by randomly selecting _k_ prototypes from the input observations. These prototypes are selected by the algorithm itself as centroids to represent each cluster. We will work with now with a simplification to visualize how the iteration proceeds:

Figure *@figKMeans1@* shows the points (observations) in a data space:


![Placing of data points.](figures/KMeans-Stage1.png width=50&label=figKMeans1)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/KMeans-Stage1}
% \caption{k-means Stage 1}
% \label{figKMeans1}
% \end{figure}
% }}}

- Suppose we choose K = 2, so two random points to the data space are placed. We call them "centroids" _1_ and _2_, they can be seen In Fig. *@figKMeans2@*:


![Placing of centroids.](figures/KMeans-Stage2.png width=50&label=figKMeans2)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/KMeans-Stage2}
% \caption{k-means Stage 2}
% \label{figKMeans2}
% \end{figure}
% }}}

- In Figure *@figKMeans3@*, we assign each point to its nearest centroid, in our case, A, B, and C are assigned to the centroid 1, and the points D, E are assigned to the centroid 2.


![Assignment of data points.](figures/KMeans-Stage3.png width=50&label=figKMeans3)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/KMeans-Stage3}
% \caption{k-means Stage 3}
% \label{figKMeans3}
% \end{figure}
% }}}

- Figure *@figKMeans4@* shows that centroids 1 and 2 were moved. This is a first step of iterative relocation.  


![The key part of k-means algorithm is to "move" each centroid to the average location of its assigned observations. The move causes some of the initial assignments not to be closer to its centroid anymore, and then assignments should be updated.](figures/KMeans-Stage4.png width=50&label=figKMeans4)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/KMeans-Stage4}
% \caption{k-means Stage 4}
% \label{figKMeans4}
% \end{figure}
% }}}

- As centroids 1 and 2 were moved, we should re-calculate the distance from all centroids to all data points like we did in Fig. 3. This is done using a distance metric (more on this below). In Figure *@figKMeans5@* the red arrows show the new assignments. Centroid 1 has now A and B data points, and centroid 2 has C, D, and E.


![Recalculation of distance of data points.](figures/KMeans-Stage5.png width=50&label=figKMeans5)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/KMeans-Stage5}
% \caption{k-means Stage 5}
% \label{figKMeans5}
% \end{figure}
% }}}

- Again, in Figure *@figKMeans6@*, the centroids were moved. We can observe the iteration and refinement patterns here: Reassigning observations continues until the cluster centers stop changing.


![Centroids 1 and 2 were moved again.](figures/KMeans-Stage6.png width=50&label=figKMeans6)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/KMeans-Stage6}
% \caption{k-means Stage 6}
% \label{figKMeans6}
% \end{figure}
% }}}


We mentioned that a distance metric is applied to determine if the centroids should be moved. There are multiple distance algorithms available (like the _Manhattan distance_), but it is common to use the _Euclidean method_ which is the square root of the squared differences between corresponding elements of the rows. Basically it is a value representing the shortest distance between two points.

#### The Iris Dataset
@sec:AIClustering-Iris

Our final goal in this section is to build a **clustering model** to make predictions. We will work with the famous **Iris-Flowers** plants dataset, published by the statistician and biologist Ronald Fisher in 1936. You will see it named the Edgar Anderson's Iris Flowers, because it was the botanic that collected the flowers. It consists of 150 flowers, carefully measured, and divided into 3 species groups of 50 flowers each. We advise to not underestimate the features of this dataset, as it is used as a toy data example as a basis for understanding how clustering works. 

The Iris-Flowers dataset is available in the Datasets package which can be loaded with the expression:

```
Metacello new
  baseline: 'Datasets';
  repository: 'github://PharoAI/Datasets';
  load.
```


We can quickly inspect the dataset contents by evaluating:

```
Dataset loadIris.
```


We can see that the dataset:

- Each row represents a flower.
- It has 3 species of flowers: _Setosa_, _Versicolor_, and _Virginica_.
- It has 5 features: _PetalLength_, _PetalWidth_, _SepalLength_, _SepalWidth_, and _Species_. The sepal and petal parts measures are expressed in centimeters and shown in Figure *@figPetalSepal@*:


![Difference between Sepal and Petal features.](figures/451px-Petal-sepal.png width=40&label=figPetalSepal)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/451px-Petal-sepal}
% \caption{Difference between Sepal and Petal features}
% \label{figPetalSepal}
% \end{figure}
% }}}

We can query here the first observations to get an overview of the dataset:

```
Datasets loadIris head.
```


![Inspector of the first flowers in the Iris Dataset.](figures/Iris_DataFrame_1.png width=100&label=figDFIrisInspect)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/Iris_DataFrame_1}
% \caption{Inspector of the first flowers in the Iris Dataset}
% \label{figDFIrisInspect}
% \end{figure}
% }}}

By quickly checking the data, we can see we are conceding multiple assumptions here: The whole dataset comes from a single experiment under almost perfect laboratory conditions, where variables are in the same measure (in this case centimeters), hence comparable, and even published in a peer-reviewed scientific journal! Real scenarios are not so kind. Variables could have different types and importance, they could contain missing values everywhere, have an undefined or unparseable format, and probably should be combined, scaled, and scored, just to name a few data preprocessing steps.

For now, we can get the first challenge here, namely interpretation. Which variables are the important ones in this dataset to get a predictive model? All of them? It would be nice to plot these observations with the Roassal visualization engine, but we have four real-valued variables and just only 2 or 3 dimensions we can "easily" plot. We will see two dimensions in the next example. In this case, a good idea is to drop the labels column and set all data points with the same colour, so we can get a feel of a real-life dataset. Let's take the y dimension to be the "SepalLength" and the x dimension to be "SepalWidth":

```
MLR2ScatterPlotViz plot: Datasets loadIris.
```


![Initial visualization of two Iris Dataset features (without cluster predictions).](figures/MLScatterPlotViz_1.png width=80&label=figMLIrisViz1)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/MLScatterPlotViz_1}
% \caption{Inspector of the first flowers in the Iris Dataset}
% \label{figMLIrisViz1}
% \end{figure}
% }}}

#### Simple Example

@sec:AIClustering-KMeansSimpleExample

For this example, we create a clustering using:

```
| df kmeans |
df := Datasets loadIris.
kmeans := KMeans numberOfClusters: 3.
```


We use the message `numberOfClusters:` to specify the _k_. Your _k_ value could be already fixed, consider for example if you want to open four pizza delivery places. But in other cases, the selection of a "good value" of _k_ usually requires a good understanding of the domain model, for example, one may choose _k_ = 3 under the knowledge that the domain model has three kinds of diagnostics (whatever they are), or _k_ = 2 when there are two types of insurances, players, or any other object. You can easily run KMeans with several values of _k_, but at some point, the refinement makes no difference to the final predictions, and comparing results between different values of _k_ is time-consuming.

Of course, we already know there are three real clusters in the Iris-Flowers dataset but let us pretend, for the sake of learning _k-means_, to ignore the "species" column which contains the three clusters. We will see later there are methods to guess a good number of clusters, for example, the "elbow method".

So far we have a k-means object, which does nothing but gets instantiated. To start building the k-means cluster model, it should be "fitted" or " trained". To build the model, we select the features we would like to use to predict our target variable.

```
kmeans fit: df.
```


We can also set up the maximum number of iterations to take when the centroids do not coincide:

```
kmeans maxIterations: 20.
```


Now that we predicted a value for K, let's get back to the Roassal visualization, this time we configure a value of K:

```
MLR2ScatterPlotViz plot: Datasets loadIris.
```



![Plot Petal Length versus Petal Width features.](figures/petal_length-vs-petal_width.png width=95&label=figPlotIris)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/petal_length-vs-petal_width}
% \caption{Plot Petal Length versus Petal Width in Iris Dataset}
% \label{figPlotIris}
% \end{figure}
% }}}

In Figure *@figPlotIris@*, we can see that the comparison of two features, "Sepal Length" versus "Sepal Width", does not seem to be good predictors for cluster recognition. We could try combinations of different features by changing _featureASelector_ and _featureBSelector_ to select other features (#second versus #third, #third versus #fourth, etc.) however there is a useful plot for these cases, the scatter matrix:

```
AIR2ScatterMatrixViz plot: Datasets loadIris.
```


![Scatter matrix of Iris features](figures/scatterplot-iris.png width=90&label=figScatterIris)

% {{{
% \begin{figure}[H]
% \centering
% \includegraphics[width=\textwidth]{Chapters/Clustering/figures/scatterplot-iris}
% \caption{Plot Petal Length versus Petal Width in Iris Dataset}
% \label{figScatterIris}
% \end{figure}
% }}}

If we want to get a scatter plot of two features for some K, and setting colors of the data points, we could do it this way:

```
AIR2ScatterPlotViz new
	k: 3;	
	featureASelector: #second;
	featureBSelector: #third;
	colors: { 
		'virginica' 	-> Color blue .
		'versicolor'	-> Color green .
		'setosa' 	-> Color red } asDictionary;
	initializeWithDataFrame: Datasets loadIris;
	plot.
```



How to use the prediction model?

_Work in progress_

### Variations of k-means

@sec:AIClustering-KMeansVariations

We have seen what is known as LLoyd's algorithm for k-means, published in 1982. The other variants are:

- Gonzalez algorithm (fork-center). This biases too much to outlier points.
- Hartigan-Wong which is often the fastest.
- A recent algorithm (from Arthur and Vassilvitskii) called k-means++


_Work in progress_


#### Bibliography


Davies, D., Bouldin, D.: A cluster separation measure. IEEE PAMI 1(2), 224–227 (1979)

Dice, Lee R. (1945). "Measures of the Amount of Ecologic Association Between Species". Ecology. 26 (3): 297–302. doi:10.2307/1932409. JSTOR 1932409.

R. A. Fisher (1936). "The use of multiple measurements in taxonomic problems". Annals of Eugenics. 7 (2): 179–188. doi:10.1111/j.1469-1809.1936.tb02137.x. hdl:2440/15227

Fowlkes, E. B.; Mallows, C. L. (1 September 1983). "A Method for Comparing Two Hierarchical Clusterings". Journal of the American Statistical Association 78 (383): 553.

Hubert, L. and Arabie, P. 1985. Comparing partitions. Journal of Classification. 2: 193~218.

Rand, W.M. 1971. Objective criteria for the evaluation of clustering methods. Journal of the American Statistical Association 66: 846~850.

Peter J. Rousseeuw (1987). "Silhouettes: a Graphical Aid to the Interpretation and Validation of Cluster Analysis". Computational and Applied Mathematics. 20: 53–65. doi:10.1016/0377-0427(87)90125-7.

Sharma, S.C. (1996). Applied Multivariate Techniques. John Wiley and Sons.

Sørensen, T. (1948). "A method of establishing groups of equal amplitude in plant sociology based on similarity of species and its application to analyses of the vegetation on Danish commons". Kongelige Danske Videnskabernes Selskab. 5 (4): 1–34.

Theodoridis, S. and Koutroubas, K. (1999). Pattern Recognition. Academic Press.
