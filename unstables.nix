# just write what packages will be unstable/forked
# using syntax:
#
#   name-i-want-to-use-in-environment.systemPackages = <unstable/forked>.actual-name-of-package;
#

unstable: forked: {

  plex                    = unstable.plex;
  jetbrains.idea-ultimate = unstable.jetbrains.idea-ultimate;
  appflowy                = unstable.appflowy;

}
