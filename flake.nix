{
  description = "acl (getfacl + setfacl + chacl) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # acl ships three tools (getfacl, setfacl, chacl), each linking the shared
  # libacl.a + libmisc.a (proper POSIX-ACL libraries, no callbacks into the
  # programs). Program objects are plain .o; only the libs are libtool archives
  # in .libs/. We fold with the cpp-rename recipe (lib.cppRenameMulticall), keeping a single
  # copy of each .a, and let the package's own (libtool) $(LINK) rule do the
  # final static link. The real ELF
  # is bin/acl; every tool name is an argv[0] alias.
  outputs = { self, unpins-lib }:
    let lib = unpins-lib.lib;
    in
    lib.mkStandaloneFlake {
      inherit self;
      name = "acl";
      binName = "acl";
      linuxOnly = true; # POSIX.1e ACL xattr — nixpkgs meta.platforms is linux-only
      smoke = [ "--unpin-program=getfacl" "--version" ];
      smokePattern = "2\\.3";
      build = pkgs:
        lib.cppRenameMulticall {
          inherit pkgs;
          basePkg = pkgs.pkgsStatic.acl;
          primary = "acl";
          makeSubdir = ".";
          linkExtra = "$(top_builddir)/.libs/libacl.a $(top_builddir)/.libs/libmisc.a $(LTLIBINTL)";
          programs = [
            { name = "getfacl"; objs = [ "tools/getfacl.o" "tools/user_group.o" ]; }
            {
              name = "setfacl";
              objs = [ "tools/do_set.o" "tools/parse.o" "tools/sequence.o" "tools/setfacl.o" ];
            }
            { name = "chacl"; objs = [ "tools/chacl.o" ]; }
          ];
          extraInstall = ''
            mkdir -p "$out/share/man/man1"
            for m in getfacl setfacl chacl; do
              if [ -f "man/man1/$m.1" ]; then install -m644 "man/man1/$m.1" "$out/share/man/man1/$m.1"; fi
            done
          '';
        };
    };
}
