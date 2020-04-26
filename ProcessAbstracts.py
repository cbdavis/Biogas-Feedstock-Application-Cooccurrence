#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import glob, os
import spacy
import textacy
import csv
en_nlp = spacy.load('en')

# this code reads two files, and creates a third file:

# include stopwords, this file is included in the repo
stopWordsFile = "en.txt"

# this is a CSV file where the first column is the identifier for the article, and the second is the abstract
article_ids_txt_file = "Article_IDs_Text.csv"

# this is a tab delimited file where the first column is the article ID
# and the second is the cleaned sentence text with punctuation removed, 
# lowercase text, and noun chunks indicated with underscores between
processed_file = "Processed_Abstracts.txt"


def cleanTokens(text, outfile, id):
    text = text.replace('\n', ' ')
    # html encoded newline character?
    text = text.replace('&#13', ' ')
    # remove numbers by themselves
    text = re.sub(r'\b[0-9]+\b', '', text)
    en_doc = en_nlp(text)
    cleanedTokens = [str(token) for token in en_doc]
    sentence_start_locations = []
    for sent in en_doc.sents:
        sentence_start_locations.append(sent.start)
    for chunk in textacy.extract.noun_chunks(en_doc, drop_determiners=True):
	# here we create noun chunks such as "wheat_straw"
        normalized_chunk = re.sub('[ -]+', '_', str(chunk))
        cleanedTokens[chunk.start] = normalized_chunk
        for i in range(chunk.start+1, chunk.end):
            cleanedTokens[i] = ''
    # split up tokens based on sentence boundaries
    locations = sentence_start_locations[1:]
    locations.append(len(cleanedTokens))
    start_loc = 0
    for end_loc in locations:
        tmp_cleaned_tokens = cleanedTokens[start_loc:end_loc]
        filtered_tokens = [x for x in tmp_cleaned_tokens if ((x not in punct_list) and (not x.isdigit()) and (x.lower() not in stoplist))]
        cleaned_sentence_text = ' '.join(filtered_tokens) + ' '
        start_loc = end_loc
        outfile.writerow([id, cleaned_sentence_text.lower()])

with open(stopWordsFile) as f:
    stoplist = [x.strip('\n') for x in f.readlines()]
punct_list = [':', '-', ';', '.', ',', ' ', '', '"', '(', ')', '\n', '\t', '\r', "'", "“", "”"]


with open(processed_file, "a") as myfile:
    txtwriter = csv.writer(myfile, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    with open(article_ids_txt_file, "r") as f:
        reader = csv.reader(f, delimiter=',')
        for row in reader:
            id = row[0]
            print(id)
            text = row[1]
            cleanTokens(text, txtwriter, id)
