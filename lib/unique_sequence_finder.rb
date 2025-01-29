require 'open-uri'

class UniqueSequenceFinder
  SEQUENCE_LENGTH = 4
  attr_accessor :dictionary_file, :sequences_file, :words_file

  def initialize(dictionary_file, sequences_file, words_file)
    @dictionary_file = dictionary_file
    @sequences_file = sequences_file
    @words_file = words_file
    @sequences = Hash.new { |hash, key| hash[key] = [] }
  end

  def process
    File.foreach(dictionary_file) do |line|
      word = sanitize_word(line)
      word_leng = word.length
      next if word_leng < SEQUENCE_LENGTH

      seen_sequences = []
      (0..word_leng - SEQUENCE_LENGTH).each do |i|
        seq = word[i, SEQUENCE_LENGTH]
        next if seen_sequences.include?(seq)

        seen_sequences << seq
        @sequences[seq] << word
      end
    end
    file_output
  end

  private
  def sanitize_word(word)
    word.downcase.gsub(/[^a-z]/, '')
  end

  def file_output
    File.open(sequences_file, 'w') do |seq_file|
      File.open(words_file, 'w') do |word_file|
        @sequences.each do |sequence, words|
          if words.uniq.size == 1
            seq_file.puts sequence
            word_file.puts words.first
          end
        end
      end
    end
  end
end

options = {
  dictionary_file: 'dictionary.txt',
  sequences_file: 'sequences',
  words_file: 'words'
}

# Ensure the dictionary file exists
dictionary_url = 'https://gist.githubusercontent.com/seanbiganski/8c657690b75a830e28557480690bb437/raw/061441e9a3253d6e890be410d0352eeeea40010a/dictionary%2520words'

unless File.exist?(options[:dictionary_file])
  puts 'Downloading dictionary file...'
  File.write(options[:dictionary_file], URI.open(dictionary_url).read)
end

# Process the dictionary and write results
puts 'Processing dictionary file...'
UniqueSequenceFinder.new(options[:dictionary_file], options[:sequences_file], options[:words_file]).process
puts 'Processing complete. Check output files.'
