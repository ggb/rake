defmodule Rake do

  # stopword list
  @stopwords File.read!("SmartStoplist.txt") |> String.split("\n", trim: true) |> Enum.into(HashSet.new)
  
  # I added some parameters as suggested by Alyona Medelyan
  # s. https://www.airpair.com/nlp/keyword-extraction-tutorial
  #                           -- MEDELYAN -- off
  #
  # min word char count       -- 5        -- 0
  @min_word_char_count 1
  # min phrase length 3       -- nil      -- 0
  @min_phrase_length 0
  # max phrase length         -- 3        -- 1000
  @max_phrase_length 3
  # keyword appearence count  -- 4        -- 0
  @min_keyword_appearence_count 1
  
  #
  defp update_counts(counts, words) do
    Enum.reduce(words, counts, fn word, dict ->
      Dict.update(dict, word, 1, fn old -> old + 1 end)
    end)
  end  
  
  #
  defp update_cooccurence(cooccurence, words) do
    Enum.reduce(words, cooccurence, fn word, dict ->
      without = List.delete(words, word)
      if Dict.has_key?(dict, word) do
        # update inner dict
        Dict.put(dict, word, update_counts(Dict.get(dict, word), without))
      else
        new_val = Enum.map(without, fn word -> { word, 1 } end) |> Enum.into(HashDict.new)
        Dict.put(dict, word, new_val)
      end
    end)
  end 
  
  @doc """
  Creates a tuple of two Dicts, where the first Dict contains information of the 
  cooccurrances, in which each word from the text appears and the second Dict contains
  the frequence of appearance for each word.
  """
  def cooccurrence_and_counts([ head | rest ], cooccurence, counts) do
    words = String.split(head, " ")
    cooccurrence_and_counts(rest, 
                            update_cooccurence(cooccurence, words), 
                            update_counts(counts, words))
  end  
  
  def cooccurrence_and_counts([], cooccurence, counts), do: { cooccurence, counts }
  
  # helper function
  defp phrase_helper("", tail, phrases, min_word_char_count) do 
    get_phrases( tail, phrases, "", min_word_char_count )
  end
  
  defp phrase_helper(words, tail, phrases, min_word_char_count) do
    get_phrases( tail, [ words | phrases ], "", min_word_char_count )
  end
  
  @doc """
  Gets a list of words and determines by special characters or stop words, if a current 
  word is part of a phrase. So, this function creates from a list of words a list of
  phrases.
  """
  def get_phrases( [ head | tail ], phrases, words, min_word_char_count ) do
    if Set.member?(@stopwords, String.downcase(head)) or head == "||" or String.length(head) < min_word_char_count do
      phrase_helper(words, tail, phrases, min_word_char_count)
    else
      get_phrases( tail, phrases, "#{words} #{head}", min_word_char_count )
    end
  end
  
  @doc """
  If there are no more words in the word list, the resulting list of phrases
  gets mapped to a list of downcase phrases, where additional whitespaces are removed.
  """
  def get_phrases([], phrases, "", _min_word_char_count) do 
    phrases
    |> Enum.map(fn phrase ->
      phrase |> String.downcase |> String.strip 
    end)
  end
    
  def get_phrases([], phrases, phrase, _min_word_char_count), do: [ phrase | phrases ]
  
  @doc """
  The function replaces punctuation with special characters to mark sentence borders. It removes 
  numbers and splits the text by the white spaces.
  """
  def prepare_text(text) do
    pattern = :binary.compile_pattern([".", ",", ":", ";", "!", "?", "(", ")", "'", "\"", "\t", "\n"])
  
    text
    |> String.replace(pattern, " || ")
    |> String.replace(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], " ")
    |> String.split(" ", trim: true)
  end
  
  @doc """
  Creates a score for each word by its degree (# number of cooccurrances)
  and frequence (# of appearances in the text).
  """
  def calculate_word_scores({ cooc, counts }) do
    Enum.reduce(cooc, HashDict.new, fn { key, inner }, dict -> 
      freq = Dict.get(counts, key)
      deg = freq + Enum.reduce(Dict.values(inner), 0, fn ele, acc -> ele + acc end)
      deg_per_freq = deg / freq
      Dict.put(dict, key, { deg, freq, deg_per_freq })
    end) 
  end

  @doc """
  Creates a score for each phrase. Therefore the word scores -- long story short -- 
  are added to one single score.
  """  
  def calculate_phrase_scores(word_scores, min_phrase_length, max_phrase_length, min_keyword_appearence_count, phrases) do
    Enum.reduce(phrases, [], fn phrase, list ->
      words = String.split(phrase, " ", trim: true)
      if length(words) < min_phrase_length or length(words) > max_phrase_length do
        list
      else
        [{ phrase, Enum.reduce(words, 0, fn word, acc ->
          { _deg, freq, deg_per_freq } = Dict.get(word_scores, word)
          if freq < min_keyword_appearence_count do
            acc
          else
            acc + deg_per_freq 
  # wow, five end's... what a mess...
          end
        end) } | list ]
      end
    end)
  end
  
  @doc """
  The 'main'-function: Gets a text and some additional parameters to calculate the rake scores.
  """
  def get(text, min_word_char_count, min_phrase_length, max_phrase_length, min_keyword_appearence_count) when is_binary(text) do    
    phrases = prepare_text(text)
    |> get_phrases([], "", min_word_char_count)
    |> Enum.map(fn phrase ->
      phrase |> String.downcase |> String.strip 
    end)
    
    phrases
    |> cooccurrence_and_counts(HashDict.new, HashDict.new)
    |> calculate_word_scores    
    |> calculate_phrase_scores(min_phrase_length, max_phrase_length, min_keyword_appearence_count, phrases |> Enum.uniq)
    |> Enum.filter(fn { _phrase, score } -> score > 0.0 end)
    |> Enum.sort(fn { _, fst}, { _, scd } -> fst > scd end) 
  end
  
  @doc """
  Gets a text and takes the predefined default parameters to calculate the rake scores.  
  """
  def get(text) do
    get(text, @min_word_char_count, @min_phrase_length, @max_phrase_length, @min_keyword_appearence_count)
  end

end
