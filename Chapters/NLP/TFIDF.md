## Term Frequency - Inverse Document Frequency
\\[ C = \{ d\_1, d\_2, \dots, d\_n \} \\]

\\[ d = \{ w\_1, w\_2, \dots, w\_m \} \\]

\\[ f\_{w,d} = |\{ w\_i \in d | w\_i = w \}| \\]

\\[ tf\(w, d\) = \frac{count\_{w,d\}}{|d|} \\]

\\[ f\_{w,C} = |\{ d \in C | w \in d \}| \\]

\\[ df\(w, C\) = \frac{f\_{w,C\}}{|C|} \\]

\\[ idf\(w, C\) = \log\frac{1}{df\(w,C\)} \\]

\\[ tfidf\(w,d,C\) = tf\(w,d\) \cdot idf\(w,C\) \\]

	(I am Sam)
	(Sam I am)
	(I 'don''t' like green eggs and ham)
)
tfidf scoreOf: 'green' in: #(I am green green ham).  "0.44"
tfidf scoreOf: 'I' in: #(I am green green ham).  "0"
	instanceVariableNames: 'documents tfidf'
	classVariableNames: ''
	package: 'TF-IDF-Tests'
	trainDocuments := #(
		(I am Sam)
		(Sam I am)
		(I 'don''t' like green eggs and ham)).

	referenceDocument := #(I am green green ham).
		
	tfidf := PGTermFrequencyInverseDocumentFrequency new.
	tfidf trainOn: trainDocuments
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
	instanceVariableNames: 'totalWordCounts perWordDocumentCount numberOfDocuments'
	classVariableNames: ''
	package: 'TF-IDF'
	numberOfDocuments := aCollectionOfDocuments size.
	perWordDocumentCount := ((aCollectionOfDocuments collect: [ :document | document asSet asArray ]) flatCollect: #yourself) asBag
	| tf idf |
	tf := self termFrequencyOf: aWord in: aDocument.
	idf := self inverseDocumentFrequencyOf: aWord.
	^ tf * idf
	^ aDocument occurrencesOf: aWord
	"Natural logarithm used o compute IDF. Can be overriden by subclasses"
	^ aNumber ln
	^ self log: (numberOfDocuments / (self numberOfDocumentsThatContainWord: aWord)).
	^ perWordDocumentCount occurrencesOf: aWord
	^ totalWordCounts asSet sorted
	^ self vocabulary collect: [ :word | self scoreOf: word in: aDocument ].