# Rake

An Python implementation of the Rapid Automatic Keyword Extraction (RAKE) algorithm as described in: Rose, S., Engel, D., Cramer, N., & Cowley, W. (2010). Automatic Keyword Extraction from Individual Documents. In M. W. Berry & J. Kogan (Eds.), Text Mining: Theory and Applications: John Wiley & Sons.

There exists also an excellent [Python implementation](https://github.com/aneesha/RAKE).

## How to use

Download or clone the repository, cd into the mix-project and fire up an elixir-shell using 

```bash
$ iex -S mix
```

Now you can automatically extract keyphrases by calling the Rake-modules get-function:

```bash
iex(1)> s = "Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered."
"Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered."
iex(2)> Rake.get(s)
[{"linear diophantine equations", 9.0}, {"nonstrict inequations", 4.0},
 {"strict inequations", 4.0}, {"considered", 1.0}, {"system", 1.0},
 {"compatibility", 1.0}, {"criteria", 1.0}]

```

## Additional parameters

This implementation includes parameters that were introduced by [Alyona Medelyan](https://github.com/zelandiya) in [this blogpost](https://www.airpair.com/nlp/keyword-extraction-tutorial). The values are set as static module parameters. In contrast to Medelyans Python-Implementation there is no optimization applied (at the moment).

