(import ./_self.nix) // {
  Either = import ./Either.nix;
  string = import ./string.nix;
  list = import ./list.nix;
  attrs = import ./builtins.nix;
}