require 'fileutils'
require 'open-uri'
require 'unique_sequence_finder'

RSpec.describe UniqueSequenceFinder do
  let(:dictionary_url) { 'https://gist.githubusercontent.com/seanbiganski/8c657690b75a830e28557480690bb437/raw/061441e9a3253d6e890be410d0352eeeea40010a/dictionary%2520words' }
  let(:dictionary_file) { 'spec/dictionary.txt' }
  let(:sequences_file) { 'spec/sequences' }
  let(:words_file) { 'spec/words' }
  let(:finder) { UniqueSequenceFinder.new(dictionary_file, sequences_file, words_file) }

  before do
    # Create a mock dictionary file before each test
    File.write(dictionary_file, "carrots\ngive\narrows\ncarrots\ngive\narrows")
    # Mocking the URI.open to avoid an actual network call
    allow(URI).to receive(:open).with(dictionary_url).and_return("carrots\ngive\narrows\ncarrots\ngive\narrows")
  end

  after do
    # Clean up after tests
    FileUtils.rm_f([dictionary_file, sequences_file, words_file])
  end

  describe '#sanitize_word' do
    it 'removes non-alphabet characters and downcases the word' do
      expect(finder.send(:sanitize_word, 'CaRRoTs')).to eq('carrots')
      expect(finder.send(:sanitize_word, 'GivE')).to eq('give')
      expect(finder.send(:sanitize_word, 'ArRoWs')).to eq('arrows')
      expect(finder.send(:sanitize_word, 'ArRoWs')).to eq('arrows')
    end

    it 'removes special characters and downcases the word' do
      expect(finder.send(:sanitize_word, 'G!vE')).to eq('gve')
      expect(finder.send(:sanitize_word, 'Arrow$')).to eq('arrow')
    end
  end

  describe '#process' do
    it 'processes the dictionary and writes sequences to the output files' do
      finder.process

      expect(File.exist?(sequences_file)).to be_truthy
      expect(File.exist?(words_file)).to be_truthy

      sequences = File.read(sequences_file).split("\n")
      words = File.read(words_file).split("\n")

      expect(sequences).to include('carr')
      expect(sequences).to include('rrow')
      expect(words).to include('carrots')

      expect(sequences.uniq.size).to eq(sequences.size)
    end

    context 'when dictionary file is empty' do
      it 'will return empty sequences and words' do
        File.write(dictionary_file, "")

        finder.process

        sequences = File.read(sequences_file).split("\n")
        words = File.read(words_file).split("\n")

        expect(sequences).to be_empty
        expect(words).to be_empty
      end
    end

    context 'when dictionary file have only one duplicate word' do
      it 'will return only one uniq sequences' do
        File.write(dictionary_file, "give\ngive\ngive\ngive")

        finder.process

        sequences = File.read(sequences_file).split("\n")
        words = File.read(words_file).split("\n")

        expect(sequences).to eq(['give'])
        expect(words).to eq(['give'])
      end
    end

    context 'when dictionary file have only 3digit words' do
      it 'will not return any sequence' do
        File.write(dictionary_file, "giv\ncat\ntom")

        finder.process

        sequences = File.read(sequences_file).split("\n")
        words = File.read(words_file).split("\n")

        expect(sequences).to be_empty
        expect(words).to be_empty
      end
    end
  end
end
