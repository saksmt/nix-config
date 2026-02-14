{
  pkgs,
  features,
  lib,
  ...
}:
with features;
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals dev.k8s.isEnabled [
      kubectl
      kubernetes-helm
      kind
    ];

  programs.zsh.shellAliases = {
    k = "kubectl";
    kg = "kubectl get";
    kd = "kubectl describe";

    kgy = "kubectl get -o yaml";

    kgsy = "kubectl get -o yaml svc";
    kgpy = "kubectl get -o yaml pod";
    kgssy = "kubectl get -o yaml ss";
    kgdy = "kubectl get -o yaml deployment";
    kgjy = "kubectl get -o yaml job";
    kgcjy = "kubectl get -o yaml cj";

    kexec = "kubectl exec";

    kcn = "k8s-interactive-choose namespace";
    kcc = "k8s-interactive-choose context";
    kcuc = "k8s-interactive-choose context";
  };
  shells.zsh.rc-extra.bottom = ''
    if command -v k8sps1 &>/dev/null; then
      export K8SPS1_SESSION_ID="''${RANDOM}"
      PROMPT+='$(k8sps1 get)'
    fi
    alias kps1=k8sps1
  '';
}
