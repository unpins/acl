# acl

[acl](https://savannah.nongnu.org/projects/acl/) — the POSIX.1e Access Control List utilities: `getfacl`, `setfacl` and `chacl`. A single self-contained binary.

[![CI](https://github.com/unpins/acl/actions/workflows/acl.yml/badge.svg)](https://github.com/unpins/acl/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install acl`.

Linux-only: the tools read and write POSIX.1e ACLs through the Linux extended-attribute interface (`system.posix_acl_*` xattrs), which macOS and Windows do not provide.

## Usage

Run a program with [unpin](https://github.com/unpins/unpin):

```bash
unpin acl getfacl file                      # show a file's ACL
unpin acl setfacl -m u:alice:rw file        # grant alice read/write
unpin acl setfacl -x u:alice file           # remove alice's entry
```

To install the programs onto your PATH:

```bash
unpin install acl
```

`unpin install acl` creates `getfacl`, `setfacl` and `chacl`. `unpin info acl` lists every command.

## Build locally

```bash
nix build github:unpins/acl
./result/bin/acl --unpin-program=getfacl --version
```

Or run directly:

```bash
nix run github:unpins/acl -- --unpin-program=getfacl --version
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/acl/releases) page has standalone binaries for manual download.

## Build notes

- **Platform:** Linux only (POSIX.1e ACL xattrs).
- **Multicall:** the three tools are folded into one ELF via a source-level `main` → `<tool>_main` rename (`lib.cppRenameMulticall`), keeping a single copy of the shared `libacl.a`/`libmisc.a` and letting the package's own libtool link rule do the final static link.
- **Man pages:** the section-1 pages are embedded; read with `unpin man acl getfacl`.
