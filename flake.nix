{
  description = "acl (getfacl + setfacl + chacl) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # acl ships three tools (getfacl, setfacl, chacl). The unpin-llvm engine
  # compiles pkgsStatic.acl to bitcode and the standalone self-folds the three
  # into one `acl` binary (like coreutils — no hand-rolled fold). Pure C, no
  # requires.cxx. Linux-only: POSIX.1e ACL xattr, nixpkgs meta.platforms is
  # linux-only, so no windows/darwin path.
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "acl";
      linuxOnly = true;
      smoke = [ "--unpin-program=getfacl" "--version" ];
      # Anchored on the program name: the point of this smoke is that
      # --unpin-program=getfacl selects getfacl, and a bare version number
      # matches setfacl's output just as well.
      smokePattern = "^getfacl 2\\.3";

      engine = "unpin-llvm";
      multicall = {
        programs = [
          { name = "getfacl"; }
          { name = "setfacl"; }
          { name = "chacl"; }
        ];
      };

      # The man output carries 39 section-3 pages for the libacl C API — 55 KB
      # of the shipped binary documenting an interface it does not expose (we
      # ship the three programs, not a linkable library). embedMan harvests the
      # whole man output, so prune at the source. man1 and acl.5 stay: the
      # format page is what setfacl/getfacl arguments are written against.
      build = pkgs: pkgs.pkgsStatic.acl.overrideAttrs (old: {
        # gettext bakes the build's own prefix in as LOCALEDIR, so the nine
        # translations these tools carry are looked up under a `/nix/store/...`
        # path that exists on no user's machine — dead weight and a dead
        # reference. Point the lookup at the conventional location (upstream's
        # own default under prefix=/usr) and keep installing the catalogs under
        # $out. Nix never saw the string: under the engine the fold's inputs are
        # the module archives, not acl's `out`, so `--references` reports
        # nothing and only a `strings` of the binary finds it.
        configureFlags = (old.configureFlags or [ ]) ++ [ "--localedir=/usr/share/locale" ];
        installFlags = (old.installFlags or [ ]) ++ [ "localedir=${placeholder "out"}/share/locale" ];
        postInstall = (old.postInstall or "") + ''
          rm -rf "$man/share/man/man3"
        '';
      });
    };
}
