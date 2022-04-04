with builtins;

rec {
  Left = value: {
    type = "Either";
    left = value;
  };
  Right = value: {
    type = "Either";
    right = value;
  };
  pure = Right;
  map = f: value: if !isRight value then value else Right (f value.right);
  mapLeft = f: value: if !isLeft value then value else Left (f value.left);
  flatMap = f: value: if !isRight value then value else f value.right;
  isRight = value: isEither value && hasAttr "right" value && !hasAttr "left" value;
  isLeft = value: isEither value && !isRight value;
  isEither = value: isAttr value && hasAttr "type" value && value.type == "Either";
  collectRight = map get (filter isRight);
  get = value: if !isRight value then throw "Expected right value" else value.right;
}
