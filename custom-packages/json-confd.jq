def deep_merge($a; $b):
  if ($a | type) == "object" and ($b | type) == "object" then
    reduce ([[ $a, $b ][] | keys[]] | unique[]) as $k ({}; .[$k] = deep_merge($a[$k]; $b[$k]))
  elif ($a | type) == "array" and ($b | type) == "array" then
    $a + $b
  else
    $b // $a
  end;

reduce inputs as $item (null; deep_merge(.; $item))
