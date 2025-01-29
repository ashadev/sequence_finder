# README

 * Process Description:
The script checks if the dictionary.txt file exists locally.
If it does not exist, it will download it from the provided Git URL.
The UniqueSequenceFinder class processes each word from the dictionary file:
It sanitizes the word (removes non-alphabet characters and converts it to lowercase).
It checks for sequences of a predefined length (SEQUENCE_LENGTH = 4).
It stores these sequences in a hash, along with the words they were found in.
After processing, it writes:
sequences: Sequences that appear only once.
words: The corresponding words where those sequences appear.
run the code - ruby unique_sequence_finder.rb

 * Notes:
The script works by extracting unique sequences of 4 characters (by default, SEQUENCE_LENGTH = 4).
Words that are shorter than 4 characters are ignored.
If a sequence appears in more than one word, it is not considered "unique."
The output files (sequences and words) are overwritten every time the script runs.
 
 * Testing
To ensure the functionality of the script, you can use RSpec to test various scenarios like:
	Handling an empty dictionary.
	Words shorter than the sequence length.
	Words with special characters.
	Words with no unique sequences.
Wrote unit test cases of several conditions - do checkout in spec/unique_sequence_finder_spec.rb file.

