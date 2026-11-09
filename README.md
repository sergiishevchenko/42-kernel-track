# 42 Kernel Track

Monorepo for the **Kernel** branch of the 42 cursus (42 Lausanne) — from building a Linux distribution by hand, through Linux kernel module development, to writing an operating system kernel from scratch.

Each project lives in its own directory and has its own `README.md` with details.

## Track map

<p align="center">
  <img src="assets/track.svg?v=2" alt="42 Kernel Track map" width="100%">
</p>

## Projects

### 🐧 Linux

<table>
  <tr>
    <th width="50" align="center"></th>
    <th width="210" align="left">Project</th>
    <th width="440" align="left">Topic</th>
    <th width="130" align="center">Status</th>
  </tr>
  <tr>
    <td align="center">🐧</td>
    <td><a href="./ft_linux"><b>ft_linux</b></a></td>
    <td>Custom Linux distribution built from source (Linux From Scratch)</td>
    <td align="center"><img src="https://img.shields.io/badge/Done-00babc?style=flat-square" alt="Done"></td>
  </tr>
  <tr>
    <td align="center">🐣</td>
    <td><b>little-penguin-1</b></td>
    <td>Introduction to Linux kernel development: kernel builds, modules, patches, debugfs</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">⌨️</td>
    <td><b>drivers-and-interrupts</b></td>
    <td>Keyboard driver as a kernel module, interrupt handling</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">🧠</td>
    <td><b>process-and-memory</b></td>
    <td>Custom syscall exposing process and memory information</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">🗂️</td>
    <td><b>filesystem</b></td>
    <td>Filesystem implementation as a kernel module</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">🧭</td>
    <td><b>userspace_digression</b></td>
    <td>Userspace side of the kernel track</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
</table>

### ⚙️ Kernel From Scratch (KFS)

An i386 kernel written in C and assembly, booted by GRUB and run in QEMU.

<table>
  <tr>
    <th width="50" align="center"></th>
    <th width="210" align="left">Project</th>
    <th width="440" align="left">Topic</th>
    <th width="130" align="center">Status</th>
  </tr>
  <tr>
    <td align="center">🚀</td>
    <td><b>kfs-1</b></td>
    <td>Multiboot, GRUB, VGA text mode, basic kernel library</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">🧱</td>
    <td><b>kfs-2</b></td>
    <td>Global Descriptor Table, kernel stack, debug shell</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">💾</td>
    <td><b>kfs-3</b></td>
    <td>Memory: paging, physical and virtual allocators</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">⚡</td>
    <td><b>kfs-4</b></td>
    <td>Interrupts: IDT, signals, keyboard</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">🔀</td>
    <td><b>kfs-5</b></td>
    <td>Processes: scheduling, <code>fork</code>, <code>wait</code>, <code>exit</code></td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">📁</td>
    <td><b>kfs-6</b></td>
    <td>Filesystem: IDE driver, ext2</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">📡</td>
    <td><b>kfs-7</b></td>
    <td>Syscalls, sockets, environment</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">🧩</td>
    <td><b>kfs-8</b></td>
    <td>Kernel modules</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">📦</td>
    <td><b>kfs-9</b></td>
    <td>ELF loading and execution</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
  <tr>
    <td align="center">👑</td>
    <td><b>kfs-x</b></td>
    <td>Complete POSIX-compliant UNIX system</td>
    <td align="center"><img src="https://img.shields.io/badge/Planned-3d4450?style=flat-square" alt="Planned"></td>
  </tr>
</table>
