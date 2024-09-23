{ nixgl, ... }:
{
  process-recipe = _: { modules = [ (_: { nixpkgs.overlays = [ nixgl.overlays.default ]; }) ]; };
}
