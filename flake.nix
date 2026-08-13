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
        postInstall = (old.postInstall or "") + ''
          rm -rf "$man/share/man/man3"
        '';
      });
    };
}
