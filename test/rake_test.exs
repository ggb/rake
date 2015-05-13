defmodule RakeTest do
  use ExUnit.Case

  @text """
  The Aleph is a short story by the Argentine writer and poet Jorge Luis Borges. First published in September 1945, it was reprinted in the short story collection, The Aleph and Other Stories, in 1949, and revised by the author in 1974.
  In Borges' story, the Aleph is a point in space that contains all other points. Anyone who gazes into it can see everything in the universe from every angle simultaneously, without distortion, overlapping or confusion. The story continues the theme of infinity found in several of Borges' other works, such as The Book of Sand.
  """


  test "rake splits the text in sentences" do
    correct = ["\n", "The Aleph is a short story by the Argentine writer and poet Jorge Luis Borges", " First published in September 1945", " it was reprinted in the short story collection", " The Aleph and Other Stories", " in 1949", " and revised by the author in 1974", "\n", "In Borges", " story", " the Aleph is a point in space that contains all other points", " Anyone who gazes into it can see everything in the universe from every angle simultaneously", " without distortion", " overlapping or confusion", " The story continues the theme of infinity found in several of Borges", " other works", " such as The Book of Sand", "\n", ""]
    sentences = @text |> Rake.split_sentences
    assert correct = sentences
  end 
  
  test "rake calculates candidate phrases" do
    correct = ["aleph", "short story", "argentine writer", "poet jorge luis borges", "published", "september 1945", "reprinted", "short story collection", "aleph", "stories", "1949", "revised", "author", "1974", "borges", "story", "aleph", "point", "space", "points", "gazes", "universe", "angle simultaneously", "distortion", "overlapping", "confusion", "story continues", "theme", "infinity found", "borges", "works", "book", "sand"]
    phrases = @text |> Rake.split_sentences 
                    |> Rake.generate_candidate_keywords(Rake.build_stop_word_regexp())
    assert correct = phrases
  end 

end
