defmodule RakeTest do
  use ExUnit.Case

  @text """
  Compatibility of systems of linear constraints over the set of natural numbers Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered. Upper bounds for components of a minimal set of solutions and algorithms of construction of minimal generating sets of solutions for all types of systems are given. These criteria and the corresponding algorithms for constructing a minimal supporting set of solutions can be used in solving all the considered types of systems and systems of mixed types.
  """

  test "generate candidates" do
    candidates = ["mixed types", "systems", "systems", "considered types", "solving", "solutions", "minimal supporting set", "constructing", "algorithms", "criteria", "systems", "types", "solutions", "minimal generating sets", "construction", "algorithms", "solutions", "minimal set", "components", "upper bounds", "considered", "nonstrict inequations", "strict inequations", "linear diophantine equations", "system", "compatibility", "natural numbers criteria", "set", "linear constraints", "systems", "compatibility"]
    assert candidates == Rake.prepare_text(@text) |> Rake.get_phrases([], "", 1)
  end

  test "calculate word cooccurrance" do
    phrases = Rake.prepare_text(@text) |> Rake.get_phrases([], "", 1)
    { cooccurrance, _counts } = phrases |> Rake.cooccurrence_and_counts(HashDict.new, HashDict.new)
    
    assert HashDict.get(cooccurrance, "numbers") |> HashDict.to_list == [{"natural", 1}, {"criteria", 1}]
    assert HashDict.get(cooccurrance, "bounds") |> HashDict.to_list == [{"upper", 1}]
    assert HashDict.get(cooccurrance, "minimal") |> HashDict.to_list == [{"supporting", 1}, {"generating", 1}, {"set", 2}, {"sets", 1}]
    assert HashDict.get(cooccurrance, "criteria") |> HashDict.to_list == [{"natural", 1}, {"numbers", 1}]
  end

  test "calculate word counts" do
    phrases = Rake.prepare_text(@text) |> Rake.get_phrases([], "", 1)
    { _cooccurrance, counts } = phrases |> Rake.cooccurrence_and_counts(HashDict.new, HashDict.new)
    
    assert HashDict.get(counts, "solutions") == 3
    assert HashDict.get(counts, "upper") == 1
    assert HashDict.get(counts, "nonstrict") == 1
    assert HashDict.get(counts, "systems") == 4
  end

  test "correct scores" do
    results = [{"minimal generating sets", 8.666666666666666}, {"linear diophantine equations", 8.5}, {"natural numbers criteria", 8.0}, {"minimal supporting set", 7.666666666666666}, {"minimal set", 4.666666666666666}, {"linear constraints", 4.5}, {"upper bounds", 4.0}, {"nonstrict inequations", 4.0}, {"strict inequations", 4.0}, {"mixed types", 3.666666666666667}, {"considered types", 3.166666666666667}, {"criteria", 2.0}, {"set", 2.0}, {"types", 1.6666666666666667}, {"considered", 1.5}, {"systems", 1.0}, {"solving", 1.0}, {"solutions", 1.0}, {"constructing", 1.0}, {"algorithms", 1.0}, {"construction", 1.0}, {"components", 1.0}, {"system", 1.0}, {"compatibility", 1.0}]
    assert results == Rake.get(@text, 1, 0, 3, 1)
  end

  test "maximum word length" do
    results = [{"considered", 1.0}, {"supporting", 1.0}, {"constructing", 1.0}, {"algorithms", 1.0}, {"generating", 1.0}, {"construction", 1.0}, {"components", 1.0}, {"inequations", 1.0}, {"diophantine", 1.0}, {"compatibility", 1.0}, {"constraints", 1.0}]
    assert Rake.get(@text, 10, 0, 3, 1) == results
  end
  
  test "minimum keyword appearance count" do
    results = [{"minimal supporting set", 4.666666666666666}, {"minimal set", 4.666666666666666}, {"minimal generating sets", 2.6666666666666665}, {"set", 2.0}, {"mixed types", 1.6666666666666667}, {"considered types", 1.6666666666666667}, {"types", 1.6666666666666667}, {"systems", 1.0}, {"solutions", 1.0}]
    assert Rake.get(@text, 1, 0, 3, 3) == results
  end

end

