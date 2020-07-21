# N-gram Language Models

In the field of natural language processing, a **language model** is a probability distribution over a sequence of words. It can be used to predict the next word in a sequence or calculate probability of the entire sequence. For example, if we take a language model that was trained on English texts and give it the beginning of a sentence _"Pillar is ..."_, the probability of a word _"cool"_ will be higher than the probability of a word _"was"_. 

More formally, given the sequence of m words $w_1, w_2, \\dots. w_m$, a language model will calculate the probability of every word based on all previous words in the sequence.

$P(w_1), P(w_2|w_1), P(w_3|w_1, w_2),  \\dots, P(w_m|w_1, \\dots, w_{m-1})$

The simplest case of a language model is **n-gram language model**. It makes a restrictive assumption that every word in the sequence depends only on n-1 previous words. Therefore,

$P(w_m|w_1, \\dots, w_{m-1}) \\approx P(w_m|w_{m-1}, \\dots w_{m-n+1})$