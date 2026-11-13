# Little Penguin

Linux kernel development project (42). Login: `sshevche`.

All kernel and module work runs on **ft_linux** (LFS in UTM), as required by
the subject. The Mac is only used for editing, git and committing.

Step-by-step guide (Russian): [docs/ru/GUIDE.md](docs/ru/GUIDE.md).

## Quick reference

On the Mac:

```bash
scripts/fetch-bootstrap.sh            # curl/git sources + CA bundle for ft_linux
```

On ft_linux, as root, from the project directory:

```bash
scripts/install-git.sh                # curl + git with HTTPS
useradd -m penguin                    # unprivileged user for proofs
scripts/check-env.sh

scripts/build-kernel.sh torvalds      # reboot into it, then: assignment-00/collect.sh
scripts/build-kernel.sh thor          # reboot into it, then: assignment-02/collect.sh
scripts/build-kernel.sh linux-next    # reboot into it, then: assignment-06/collect.sh

scripts/build-all-modules.sh
scripts/test-module.sh assignment-01
assignment-04/proof.sh
assignment-05/proof.sh
assignment-07/proof.sh

scripts/verify-submission.sh
scripts/pack-artifacts.sh             # artifacts to copy back to the Mac
```

`build-kernel.sh` starts from the running ft_linux kernel config, installs
`/boot/vmlinuz-<release>` and appends a `little-penguin <release>` entry to
`/boot/grub/grub.cfg`. Each `collect.sh` refuses to save anything unless
`uname -r` matches the release built from the corresponding tree.

## Submission layout

- `assignment-00/` — `kern.log`, `.config`
- `assignment-01/` — `main.c`, `Makefile`
- `assignment-02/` — `kern.log`, `Makefile.patch`
- `assignment-03/` — `fixed.c`
- `assignment-04/` — `main.c`, `Makefile`, `99-keyboard.rules`, `proof.log`
- `assignment-05/` — `main.c`, `Makefile`, `proof.log`
- `assignment-06/` — `kern.log`
- `assignment-07/` — `main.c`, `Makefile`, `proof.log`
- `assignment-08/` — `fixed.c`
- `assignment-09/` — `main.c`, `Makefile`

`include/`, `compile_flags.txt` and `bootstrap/` are local-only (clangd stubs
and ft_linux bootstrap sources) and are git-ignored.
