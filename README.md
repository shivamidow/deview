DeView
======
*This repo is a placeholder for anonymous submission of academic work.*

DeView is a debloating system that eliminates unnecessary web features from a PWA
(Progressive Web App). It identifies necessary web APIs (i.e., HTML, CSS, JavaScript)
through exercising a PWA and generates custom-fit web engine binaries for the PWA
by wiping out unused web APIs.

Environment
-----------
We tested DeView on following systems.
* Fedora 36
* Ubuntu 22.04 LTS

Version Info
------------
* Clang / LLVM: 10.0.0 (pre-release, c2443155a0fb245c8f17f2c1c72b6ea391e86e81)
* Chromium 80.0.3987.0 (r722234, 65d20b8e6b1e34d2687f4367477b92e89867c6f5)
  + depot_tools (fe18a43d590a5eac0d58e7e555b024746ba290ad)
* puppeteer: v2.1.1

Getting the Code
----------------
This repository has a git submodule for modified Chromium.
```bash
$ git clone --recurse-submodules git@github.com:shivamidow/deview.git
```

Building DeView
---------------
### Install depot_tools ###
Download depot_tool, check out `fe18a43d590a5eac0d58e7e555b024746ba290ad`, then
make it accessible in the terminal.
[This tutorial](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up) is helpful.

### Install dependencies ###
Install dependencies including ones for chromium.
```bash
$ python3 dev.py init
```

### Build ###
We can build slimium and chromium by running commands below in order.
```bash
$ python3 dev.py build 11vm
$ python3 dev.py build cr-ir
$ python3 dev.py build cr-profiling
$ python3 dev.py build cr-marking
$ python3 dev.py build puppeteer
$ python3 dev.py build profiler
```
If we omit a target (i.e., `$ python3 dev.py build`), the build script automatically triggers all commands.

Debloating a PWA
----------------
### Profiling ###
```bash
$ python3 dev.py run profiling
```

### Debloat ###
```bash
$ python3 dev.py run debloating
```
