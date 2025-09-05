module MeanLibSpec {

  type R   = real
  type Vec = seq<R>

  predicate NonEmpty(xs: Vec) { |xs| > 0 }

  // Helpers (to be implemented later)
  function method Sum(xs: Vec): R
  function method Min(xs: Vec): R
    requires NonEmpty(xs)
  function method Max(xs: Vec): R
    requires NonEmpty(xs)

  // Arithmetic mean (average)
  // Formula: Mean(xs) = Sum(xs) / |xs|
  function method Mean(xs: Vec): R
    requires NonEmpty(xs)
    ensures Mean(xs) == Sum(xs) / |xs|
    ensures Min(xs) <= Mean(xs) <= Max(xs)
}
