# 42 Kernel Track

Monorepo for the **Kernel** branch of the 42 cursus (42 Lausanne) — from building a Linux distribution by hand, through Linux kernel module development, to writing an operating system kernel from scratch.

Each project lives in its own directory and has its own `README.md` with details.

## Track map

<p align="center">
  <img src="assets/track.svg?v=2" alt="42 Kernel Track map" width="100%">
</p>

## Projects

### Linux

<table>
  <tr>
    <th width="200" align="left">Project</th>
    <th width="500" align="left">Topic</th>
    <th width="110" align="left">Status</th>
  </tr>
  <tr><td><a href="./ft_linux">ft_linux</a></td><td>Custom Linux distribution built from source (Linux From Scratch)</td><td>Done</td></tr>
  <tr><td><a href="./little-penguin-1">little-penguin-1</a></td><td>Introduction to Linux kernel development: kernel builds, modules, patches, debugfs</td><td>—</td></tr>
  <tr><td>drivers-and-interrupts</td><td>Keyboard driver as a kernel module, interrupt handling</td><td>—</td></tr>
  <tr><td>process-and-memory</td><td>Custom syscall exposing process and memory information</td><td>—</td></tr>
  <tr><td>filesystem</td><td>Filesystem implementation as a kernel module</td><td>—</td></tr>
  <tr><td>userspace_digression</td><td>Userspace side of the kernel track</td><td>—</td></tr>
</table>

### Kernel From Scratch (KFS)

An i386 kernel written in C and assembly, booted by GRUB and run in QEMU.

<table>
  <tr>
    <th width="200" align="left">Project</th>
    <th width="500" align="left">Topic</th>
    <th width="110" align="left">Status</th>
  </tr>
  <tr><td><a href="./kfs-1">kfs-1</a></td><td>Multiboot, GRUB, VGA text mode, basic kernel library</td><td>—</td></tr>
  <tr><td><a href="./kfs-2">kfs-2</a></td><td>Global Descriptor Table, kernel stack, debug shell</td><td>—</td></tr>
  <tr><td>kfs-3</td><td>Memory: paging, physical and virtual allocators</td><td>—</td></tr>
  <tr><td>kfs-4</td><td>Interrupts: IDT, signals, keyboard</td><td>—</td></tr>
  <tr><td>kfs-5</td><td>Processes: scheduling, <code>fork</code>, <code>wait</code>, <code>exit</code></td><td>—</td></tr>
  <tr><td>kfs-6</td><td>Filesystem: IDE driver, ext2</td><td>—</td></tr>
  <tr><td>kfs-7</td><td>Syscalls, sockets, environment</td><td>—</td></tr>
  <tr><td>kfs-8</td><td>Kernel modules</td><td>—</td></tr>
  <tr><td>kfs-9</td><td>ELF loading and execution</td><td>—</td></tr>
  <tr><td>kfs-x</td><td>Complete POSIX-compliant UNIX system</td><td>—</td></tr>
</table>
