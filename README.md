# Biogas-Feedstock-Application-Cooccurrence

This is code accompanying the paper _Can multiple uses of biomass limit the availability for future biogas production? - An overview of biogas feedstocks and their alternative uses_

The code is used to analyze co-occurence statistics of words which are found together in the same scientific article abstracts

[ProcessAbstracts.py](./ProcessAbstracts.py) is used for pre-processing text and processes a CSV file where the first column is an identifier for the article, and the second column contains the text of the abstract.  All text is converted to lowercase, punctuation and stop words are removed, and noun chunks such as "wheat straw" are converted into single tokens such as "wheat_straw".

[Calculate_CoOccurrence_Metrics.R](./Calculate_CoOccurrence_Metrics.R) is then used to calculate the co-occurrence statistics between all of the words found in the same abstract.  Multiple statistics are provided to evaluate the co-occurrences.  The input to this function is a dataframe where the first column is an identifier for the article, and the second column is composed of single words found in the abstract.

