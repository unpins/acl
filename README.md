# acl

[acl](https://savannah.nongnu.org/projects/acl/) — the POSIX.1e Access Control List programs: `getfacl`, `setfacl` and `chacl`. A single self-contained binary, built natively for Linux.

[![CI](https://github.com/unpins/acl/actions/workflows/acl.yml/badge.svg)](https://github.com/unpins/acl/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install acl`.

Linux-only: the tools read and write POSIX.1e ACLs through the Linux extended-attribute interface (`system.posix_acl_*` xattrs), which macOS and Windows do not provide.

## Usage

Run a program with [unpin](https://github.com/unpins/unpin):

```bash
unpin acl --unpin-program=getfacl file                    # show a file's ACL
unpin acl --unpin-program=setfacl -m u:alice:rw file      # grant alice read/write
unpin acl --unpin-program=setfacl -x u:alice file         # remove alice's entry
```

To install the programs onto your PATH:

```bash
unpin install acl
```

`unpin install acl` creates `getfacl`, `setfacl` and `chacl`, and once they are on your PATH you can call them by name — `getfacl file`. `unpin info acl` lists every command.

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
- **Man pages:** the three program pages and `acl.5` are embedded; read with `unpin man acl getfacl`. The `libacl` C API pages are not — this binary ships the programs, not a linkable library.
