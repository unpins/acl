# Changelog

## [Unreleased]

## [2.4.0-1] - 2026-09-26

First release of acl in the unpins catalog: `getfacl`, `setfacl` and `chacl`
in one self-contained binary, built natively for Linux.

- `unpin install acl` creates all three commands; `unpin acl
  --unpin-program=getfacl file` runs one without installing anything.
- The programs' manual pages and `acl.5` (the ACL text format the arguments
  are written against) are embedded — `unpin man acl setfacl`. The 39
  section-3 pages for the libacl C API are not: this binary ships the
  programs, not a linkable library.
- Translations resolve. gettext bakes the build's own prefix in as the
  message directory, which would have sent the lookup to a path that exists
  on no user's machine; it points at `/usr/share/locale` instead, so the nine
  translations acl carries (de, es, fr, gl, ka, pl, sv, …) work where the
  system has them. The binary carries no path into the machine that built it.
