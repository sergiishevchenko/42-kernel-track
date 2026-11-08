# 42 Kernel Track

Monorepo for the **Kernel** branch of the 42 cursus (42 Lausanne) — from building a Linux distribution by hand, through Linux kernel module development, to writing an operating system kernel from scratch.

Each project lives in its own directory and has its own `README.md` / `PLAN.md` with details.

## Track map

```mermaid
%%{init: {"theme": "base", "themeVariables": {"fontFamily": "Inter, Helvetica, Arial, sans-serif", "fontSize": "15px", "lineColor": "#8b949e", "titleColor": "#c9d1d9", "clusterBkg": "#161b2280", "clusterBorder": "#30363d"}, "flowchart": {"curve": "basis", "nodeSpacing": 25, "rankSpacing": 50, "padding": 12}}}%%
flowchart LR
    ft_linux(["🐧 ft_linux"]):::done
    lp1(["little-penguin-1"]):::done

    subgraph LINUX ["Linux Kernel Development"]
        direction LR
        ud(["userspace_digression"]):::todo
        di(["drivers-and-interrupts"]):::done
        pm(["process-and-memory"]):::done
        fs(["filesystem"]):::todo
        di --> fs
        pm --> fs
    end

    subgraph KFS ["Kernel From Scratch"]
        direction TB
        subgraph KFS_A [" "]
            direction LR
            kfs1(["kfs-1"]):::wip --> kfs2(["kfs-2"]):::wip --> kfs3(["kfs-3"]):::locked --> kfs4(["kfs-4"]):::locked --> kfs5(["kfs-5"]):::locked
        end
        subgraph KFS_B [" "]
            direction LR
            kfs6(["kfs-6"]):::locked --> kfs7(["kfs-7"]):::locked --> kfs8(["kfs-8"]):::locked --> kfs9(["kfs-9"]):::locked --> kfsx(["⭐ kfs-x"]):::locked
        end
        KFS_A --> KFS_B
    end

    ft_linux ==> lp1
    lp1 ==> LINUX
    lp1 ==> KFS

    classDef done fill:#0d3b40,stroke:#00babc,stroke-width:3px,color:#e6fffe
    classDef wip fill:#3d2a1f,stroke:#e8b38f,stroke-width:3px,color:#fff4ec
    classDef todo fill:#2d2a26,stroke:#e8b38f,stroke-width:2px,stroke-dasharray:5 3,color:#e8b38f
    classDef locked fill:#2b2d31,stroke:#6e7681,stroke-width:2px,color:#9da5ae
    style KFS_A fill:none,stroke:none
    style KFS_B fill:none,stroke:none
```

<sub>🟦 Done &nbsp;·&nbsp; 🟧 In progress &nbsp;·&nbsp; ⬜ Locked &nbsp;·&nbsp; dashed — available</sub>

## Projects

### Linux

| Project | Topic | Status |
|---------|-------|--------|
| [ft_linux](./ft_linux) | Custom Linux distribution built from source (Linux From Scratch) | Done |
| [little-penguin-1](./little-penguin-1) | Introduction to Linux kernel development: kernel builds, modules, patches, debugfs | Done |
| drivers-and-interrupts | Keyboard driver as a kernel module, interrupt handling | — |
| process-and-memory | Custom syscall exposing process and memory information | — |
| filesystem | Filesystem implementation as a kernel module | — |
| userspace_digression | Userspace side of the kernel track | — |

### Kernel From Scratch (KFS)

An i386 kernel written in C and assembly, booted by GRUB and run in QEMU.

| Project | Topic | Status |
|---------|-------|--------|
| [kfs-1](./kfs-1) | Multiboot, GRUB, VGA text mode, basic kernel library | In progress |
| [kfs-2](./kfs-2) | Global Descriptor Table, kernel stack, debug shell | In progress |
| kfs-3 | Memory: paging, physical and virtual allocators | — |
| kfs-4 | Interrupts: IDT, signals, keyboard | — |
| kfs-5 | Processes: scheduling, `fork`, `wait`, `exit` | — |
| kfs-6 | Filesystem: IDE driver, ext2 | — |
| kfs-7 | Syscalls, sockets, environment | — |
| kfs-8 | Kernel modules | — |
| kfs-9 | ELF loading and execution | — |
| kfs-x | Complete POSIX-compliant UNIX system | — |

## Repository layout

```
.
├── ft_linux/            # LFS build scripts, configs, docs
├── little-penguin-1/    # Kernel assignments 00–09
├── kfs-1/               # KFS: boot + screen
├── kfs-2/               # KFS: GDT + stack
└── ...                  # Next projects are added as separate directories
```
