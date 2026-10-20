def deep_merge($a; $b):
  if ($a | type) == "object" and ($b | type) == "object" then
    reduce ([[ $a, $b ][] | keys[]] | unique[]) as $k ({}; .[$k] = deep_merge($a[$k]; $b[$k]))
  elif ($a | type) == "array" and ($b | type) == "array" then
    $a + $b
  elif ($a | type) == "boolean" and $b == null then
    $a
  elif ($b | type) == "boolean" and $a == null then
    $b
  else
    $b // $a
  end;

reduce inputs as $item (null; deep_merge(.; $item))
