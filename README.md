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
* Fedora 32
* Ubuntu 20.04 LTS

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
```bash
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ cd depot_tools
$ git checkout -b deview fe18a43d590a5eac0d58e7e555b024746ba290ad
```

### Install dependencies ###
Install dependencies including ones for chromium. This should be enough to do it once.
```bash
$ python3 dev.py init
```

### Build ###
We can build everything with a single instruction.
```bash
$ python3 dev.py build
```
This instruction is the same effect as invoking the following commands in order.
```bash
$ python3 dev.py build 11vm
$ python3 dev.py build cr-ir
$ python3 dev.py build cr-profiling
$ python3 dev.py build cr-marking
$ python3 dev.py build profiler
```

Profiling a PWA
---------------
### Create tests by recording behaviors
We can use existing tests that
[Headless Recorder](https://chrome.google.com/webstore/detail/headless-recorder/djeegiggegleadkkbgopoonhjimgehda?hl=en)
generated. Otherwise, we can create new tests by using the extension.
Install the browser extension, record, and save behaviors as tests in a directoroy.

### Profiling by Replaying
```bash
$ python3 dev.py run profiling [test_path]
```
This command starts profiling web APIs a PWA (indicated by `PWA_DEFAULT_ID` in `dev.py`) uses
by replaying all tests in the given directory. We can specify a PWA to profile with '--app-id'.
```bash
$ python3 dev.py --app-id=oonpikaeehoaiikcikkcnadhgaigameg run profiling [test_path]
```

Debloating a PWA
----------------
Launch a PWA in the instrumented chromium. For instance,
we can launch the Starbucks PWA like folloiwng.
```bash
$ out/marking/chrome --app-id=oonpikaeehoaiikcikkcnadhgaigameg
```
When a PWA is updated, the instrumented chromium automatically generates
debloated blink libraries and saves them under
`~/.config/chromium/Default/Extensions/$APP_ID/$VERSION/lib/`.

We can manually trigger the debloating process by using a command below.
```bash
$ python3 dev.py --app-id=oonpikaeehoaiikcikkcnadhgaigameg run debloating
```
