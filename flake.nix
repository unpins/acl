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
      binName = "acl";
      linuxOnly = true;
      smoke = [ "--unpin-program=getfacl" "--version" ];
      smokePattern = "2\\.3";

      engine = "unpin-llvm";
      multicall = {
        programs = [
          { name = "getfacl"; }
          { name = "setfacl"; }
          { name = "chacl"; }
        ];
      };

      build = pkgs: pkgs.pkgsStatic.acl;
    };
}
