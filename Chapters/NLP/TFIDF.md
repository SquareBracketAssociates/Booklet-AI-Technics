## Term Frequency - Inverse Document Frequency

@chap:TFIDF

Imagine that you have a library filled with books and you want to summarize each one of them with several keywords - words that are most representative of its contents.

You can count the occurrences of each word and select the top 10 most commonly used words. Turns out that for all significantly big English texts, those words will be roughly the same: _the, and, to of, a, I, in, was, he, that_. These are the most used words in English language. Of course, they can't tell you what your book is about and how is it from other pieces of writing.

Let us take a different approach. Instead of looking for the most frequent words in the given book, we will find words that appear often in this particular book and rarely in others.

Take an Art book for example. Words such as _"painter"_, _"masterpiece"_, _"color"_ will appear in it more frequently than in books on Medicine. The latter will have high frequency of words _"disease"_, _"treatment"_, _"patient"_, etc. As for generic words such as _"this"_ or _"the"_, they will be frequent in all books and therefore they will not be representative of any of them. 
Identifying most significant terms of a document in a corpus is what _Term Frequency - Inverse Document Frequency_ is about. 

### What is it?

@sec:TFIDF-WhatIsIt

The idea that we have just described is called **Term Frequency - Inverse Document Frequency (TF-IDF)**. It is a metric that represents the importance of a word in a document compared to the words that occur in all the documents of the corpus under analysis.

TF-IDF is basically the product of two metrics. 
One metric TF represents the frequency of a term \(often this is just the occurrence of that term\) in a given document. 
And the other metric, IDF, measures the importance of a term in the complete document corpus.

### Applications

@sec:TFIDF-Applications

TF-IDF has many uses, most importantly in automated text analysis, and is very useful for scoring words in machine learning algorithms for Natural Language Processing (NLP).
TF-IDF was invented for document search and information retrieval.

The intuition upon which TF-IDF is built is that the global frequency of a word over the total amount of documents does not give much information about one specific document. 
Most frequent words represent a kind of noise.
TF-IDF intuition captures that frequent words over the total number of documents are less significant than frequent words in a specific document. It helps remove the noise and focus on relevant information per document (a local context).

For example, given a set of documents, words that are common in every document, such as this, a, the, and that, will rank low even though they may appear many times since they don’t mean much to that document in particular. On the other side if a word for example 'visual' appears many times in a specific document, (and does not appear many times in others), it probably means that it’s relevant to this particular document.

### Formal Definition
@sec:TFIDF-Definition

Given the collection of documents $C$ (we call it a corpus):

$$
C = \{ d_1, d_2, \dots, d_n \}
$$


where each document is a sequence of words:

$$
d = \{ w_1, w_2, \dots, w_m \}
$$


#### Term Frequency


Let $f_{w,d}$ be the number of occurences of word $w$ in document $d$:

$$
f_{w,d} = |\{ w_i \in d | w_i = w \}| 
$$


**Term frequency \(TF\)** of word $w$ in document $d$ is the number of times $w$ appers in $d$ divided by the total number of words in document $|d|$:

$$
tf(w, d) = \frac{count_{w,d}}{|d|}
$$


Therefore, $tf(w, d)$ tells us what percent of words in document $d$ are equal to $w$. This number does not depend on the size of the docuement. 


#### Document Frequency 


Similarly, let $f_{w,C}$ be the number of documents in corpus $C$ that contain word $w$:

$$
f_{w,C} = |\{ d \in C | w \in d \}| 
$$


**Document frequency \(DF\)** of word $w$ in corpus $C$ is the number of documents in $C$ that contain the word $w$ normalized by the total number of documents $|C|$ -- i.e., the size of corpus C.

$$
df(w, C) = \frac{f_{w,C}}{|C|} 
$$


#### Inverse Document Frequency


**Inverse document frequency** is 1 divided by the document frequency. We also scale this number on the logarithmic scale:

$$
idf(w, C) = \log\frac{1}{df(w,C)}
$$


!!todo Why do we use the logarithmic scale?

#### TF-IDF score


$$
tfidf(w,d,C) = tf(w,d) \cdot idf(w,C)
$$


Remark. Document $d$ that is used to compute the term frequency is not necessarily from the corpus $C$. This means that we can train the TF-IDF model on a collection of documents and then apply it to previously unseen documents.

### Simple Example

@sec:TFIDF-SimpleExample

Let's train a TF-IDF model on the following three sentences \(documents\) - we will refer to them as the _training corpus_:

1. _"I am Sam"_
1. _"Sam I am"_
1. _"I don't like green eggs and ham"_


We will then apply this model to get the scores of words from a new sentence:

4. _"I am green green ham"_

This means than we will calculate the **inverse document frequency \(IDF\)** of each word from sentence 4 based on sentences 1-3. Then we calculate the **term frequency \(TF\)** of each word from sentence 4. 
So **IDF** comes from the corpus of training sentences and **TF** comes from the sentence that we want to score. 
In the following table, you can see the IDF score of every word from the training corpus:


|  | count | DF | 1/DF | IDF = log\(1/DF\) |
| --- | --- | --- | --- | --- |
| I | 3 | 1 | 1 | 0 |
| am | 2 | 0.667 | 1.5 | 0.406 |
| Sam | 2 | 0.667 | 1.5 | 0.406 |
| don't | 1 | 0.333 | 3 | 1.099 |
| like | 1 | 0.333 | 3 | 1.099 |
| green | 1 | 0.333 | 3 | 1.099 |
| eggs | 1 | 0.333 | 3 | 1.099 |
| and | 1 | 0.333 | 3 | 1.099 |
| ham | 1 | 0.333 | 3 | 1.099 |

Now let's calculate the TF score of every word of sentence 4 and multiply it by the corresponding IDF score to get the final TF-IDF value:


|  | count | TF | TF * IDF = TF-IDF |
| --- | --- | --- | --- |
| I | 1 | 0.2 | 0 |
| am | 1 | 0.2 | 0.081 |
| green | 2 | 0.4 | 0.440 |
| ham | 1 | 0.2 | 0.220 |

Notice that the highest score was assigned to the word _"green"_ - it appears twice in sentence 4 and only once in the training corpus.
After it comes the word _"ham"_ which has the same frequency in the training corpus but lower frequency in the sentence under analysis.
Word _"am"_ has low score because it appeared in the training corpus twice. And the score of word _"I"_ is 0 because it was present in every single sentence of the training corpus.

We can ask ourselves what will happen if we apply it to the new sentence: _"I am green green fruit"_.
The only difference is for **fruit**.
Since "fruit" did not appear in the training corpus, its document frequency is zero, its IDF scores will be infinite and its TF-IDF too.
Now what infinity means is left to the implementation.
Implementors can apply maximum values, smoothing or other approaches.
There are other solutions that are discussed in following Sections.


|  | count | TF | TF * IDF = TF-IDF |
| --- | --- | --- | --- |
| fruit | 1 | 0.2 | infinity |


We can also use TF-IDF to get the vector representation of a document. 
Let us image that we have a new document \(a sentence\): _"I", "am", "Sam", "don't", "like", "green", "eggs", "and", "ham"_.
We do this in two steps:

1. Take vocabulary of all words used in the documents from our training corpus: _"I", "am", "Sam", "don't", "like", "green", "eggs", "and", "ham"_.
1. For every word in that vocabulary, find its TF-IDF score in the document under analysis. This will give us 9 scores \(size of the training vocabulary\) which form a vector representation of the document. 



| I | am | Sam | don't | like | green | eggs | and | ham |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 0.081 | 0 | 0 | 0 | 0.44 | 0 | 0 | 0.22 |

Notice that  words _"Sam", "don't", "like", "eggs", "and"_ did not appear in the reference sentence. This means that their count \(and TF\) is 0. Therefore, the TF-IDF of these words is also 0. 


#### Practical aspects

The case of word external to the corpus like **fruit** in the previous example is an important point to be presented when implementing for real the algorithm. 
There are several approches to deal with the _infinity_ effect of a word outside of the training corpus. 


We present two solutions: rerunning the training corpus and introducing a reasonable unknown term. 

Here more..

### Designing the API
@sec:TFIDF-API

We want to have an instance of TF-IDF algorithm that can be trained on a collection of documents and then applied either to score words in a given document or to produce a vector representation of a document.

```
documents := #(
	(I am Sam)
	(Sam I am)
	(I 'don''t' like green eggs and ham)
)
```


#### Instance creation


```
tfidf := TermFrequencyInverseDocumentFrequency new
```


#### Training

```
tfidf trainOn: documents
```


#### TF-IDF score of word in a document


```
tfidf scoreOf: 'ham' in: #(I am green green ham). "0.22"
tfidf scoreOf: 'green' in: #(I am green green ham).  "0.44"
tfidf scoreOf: 'I' in: #(I am green green ham).  "0"
```


#### TF-IDF vector for a document


```
tfidf vectorFor: #(I am Bob)
```


### Writing tests

@sec:TFIDF-Tests

```language=smalltalk
TestCase << #TermFrequencyInverseDocumentFrequencyTest
	slots: {#documents . #tfidf};
	package: 'TF-IDF-Tests'
```


```
setUp 
	trainDocuments := #(
		(I am Sam)
		(Sam I am)
		(I 'don''t' like green eggs and ham)).

	referenceDocument := #(I am green green ham).
		
	tfidf := PGTermFrequencyInverseDocumentFrequency new.
	tfidf trainOn: trainDocuments
```


```
testScoreOfI
	self
		assert: (tfidf scoreOf: 'I' in: referenceDocument)
		closeTo: 0

testScoreOfAm
	self
		assert: (tfidf scoreOf: 'am' in: referenceDocument)
		closeTo: 0.081

testScoreOfGreen
	self
		assert: (tfidf scoreOf: 'green' in: referenceDocument)
		closeTo: 0.44

testScoreOfHam
	self
		assert: (tfidf scoreOf: 'ham' in: referenceDocument)
		closeTo: 0.22
```


### Implementation

@sec:TFIDF-Implementation

Now let's implement TF-IDF in Pharo. We start by creating a class `TermFrequencyInverseDocumentFrequency` with two instance variables:

1. `numberOfDocuments` - total number of docuements.
1. `perWordDocumentCount` - a `Bag` of words from all documents where each word is counted only once per document. This collection will allow us to count documents that include a given word.


```
Object << #TermFrequencyInverseDocumentFrequency
	slots: {#totalWordCounts . #perWordDocumentCount . #numberOfDocuments};
	package: 'TF-IDF'
```




```
trainOn: aCollectionOfDocuments
	numberOfDocuments := aCollectionOfDocuments size.
	perWordDocumentCount := ((aCollectionOfDocuments collect: [ :document | document asSet asArray ]) flatCollect: #yourself) asBag
```


```
scoreOf: aWord in: aDocument
	| tf idf |
	tf := self termFrequencyOf: aWord in: aDocument.
	idf := self inverseDocumentFrequencyOf: aWord.
	^ tf * idf
```


```
termFrequencyOf: aWord in: aDocument
	^ aDocument occurrencesOf: aWord
```


```
log: aNumber
	"Natural logarithm used o compute IDF. Can be overriden by subclasses"
	^ aNumber ln
```


```
inverseDocumentFrequencyOf: aWord
	^ self log: (numberOfDocuments / (self numberOfDocumentsThatContainWord: aWord)).
```


```
numberOfDocumentsThatContainWord: aWord
	^ perWordDocumentCount occurrencesOf: aWord
```


```
vocabulary
	^ totalWordCounts asSet sorted
```


```
vectorFor: aDocument
	^ self vocabulary collect: [ :word | self scoreOf: word in: aDocument ].
```

### Conclusion

TFIDF is a simple technique to get most important words out of a corpus. 
It is handy and easy to use. 