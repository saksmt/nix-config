with builtins;

{
  sortBy = f: sort (a: b: f a < f b);
  reverseSortBy = f: sort (a: b: f a > f b);
}
