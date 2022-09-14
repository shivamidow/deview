DeView
======
*This repo is a placeholder for the submission of academic work.*

DeView is a debloating system that eliminates unnecessary web features from a
PWA (Progressive Web App). It identifies necessary web APIs (i.e., HTML, CSS,
JavaScript) through exercising a PWA. It generates custom-fit web
engine binaries for the PWA by wiping out unnecessary web APIs from the
binaries.

System Environment
------------------
We mainly developed and tested DeView on the following systems.
* Fedora 32 ([VM Download](http://jack.gtisc.gatech.edu/deview/fedora_32.ova))
* Ubuntu 20.04 LTS ([VM Download](http://jack.gtisc.gatech.edu/deview/ubuntu_20-04_lts.ova))

Version Info
------------
* Clang / LLVM: 10.0.0 (pre-release, c2443155a0fb245c8f17f2c1c72b6ea391e86e81)
* Chromium 80.0.3987.0 (r722234, 65d20b8e6b1e34d2687f4367477b92e89867c6f5)
  + depot_tools (fe18a43d590a5eac0d58e7e555b024746ba290ad)
* puppeteer: v2.1.1

Getting the Code
----------------
This repository has a git submodule for instrumented Chromium.
```bash
$ git clone --recurse-submodules https://github.com/shivamidow/deview.git
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
Install dependencies, including ones for Chromium.
```bash
$ tools/install-dependencies
$ python3 dev.py init
```

### Build ###
We build LLVM with custom passes, instrumented Chromium, and web API profiler in order.
Chromium build scripts use `python2`, so make sure the default `python` indicates `python2`
when running `$ python --version`.

We can build everything with a single instruction. The build takes hours, so please be patient.
Using `ccache` can save many hours when re-build is needed.
```bash
$ python3 dev.py build
```
That instruction is the same effect as invoking the following commands in order.
```bash
$ python3 dev.py build 11vm
$ python3 dev.py build cr-ir
$ python3 dev.py build cr-profiling
$ python3 dev.py build cr-debloating
$ python3 dev.py build profiler
```

Profiling a PWA
---------------
Using the Starbucks PWA, we explain the rest of the procedures.
The app-id of the Starbucks PWA is `oonpikaeehoaiikcikkcnadhgaigameg`.

### Install a PWA into the profiling browser profile
Run the instrumented browser for profiling and visit the landing page of a PWA.
```bash
$ python3 dev.py run profiling http://app.starbucks.com
```
Install the PWA by clicking the '+' button in the address bar. Then close the window.

### Create tests by recording behaviors
We can use existing tests that
[Headless Recorder](https://chrome.google.com/webstore/detail/headless-recorder/djeegiggegleadkkbgopoonhjimgehda?hl=en)
generated. Otherwise, we need to create new tests by using that extension.
Install the Headless Recorder, record, and save behaviors as tests in a directory.

### Profiling web API by Replaying
```bash
$ python3 dev.py --app-id=oonpikaeehoaiikcikkcnadhgaigameg run profiling [test_path]
```
This command starts profiling a PWA's web APIs
by replaying all tests in the `[test_path]` directory.
We specify which PWA to profile with '--app-id'.

### Profiling web API by Manual Control
Even without replaying tests, we can manually test the PWA like the following.
```bash
$ python3 dev.py --app-id=oonpikaeehoaiikcikkcnadhgaigameg run profiling
```
Also, we can open the PWA in the full browser by putting its landing address.
```bash
$ python3 dev.py run profiling http://app.starbucks.com
```
Once profiling is complete, close the window. Then, the profiling stops.

Debloating a PWA
----------------
### Install a PWA into the debloating browser profile
Run the instrumented browser for debloating and visit the landing page of a PWA.
```bash
$ src/chromium/src/out/debloating/chrome http://app.starbucks.com
```
Install the PWA by clicking the '+' button in the address bar. Then close the window.

### Debloating
Using the command below, we debloat web API from the chrome binary based on the profile result.
```bash
$ python3 dev.py --app-id=oonpikaeehoaiikcikkcnadhgaigameg run debloating [path_to_profile_result]
```
The `[path_to_profile_result]` is optional. If that is not specified, a profile result
located in the same directory of the `chrome` binary is used as default.
The debloated binaries reside in
`~/.config/chromium/Default/Extensions/$APP_ID/$VERSION/lib/`.
When a PWA is updated, the debloating job is automatically re-performed.

### Launch a PWA with Confined web APIs
Launch a PWA in the instrumented chromium. For instance,
we can launch the Starbucks PWA like the following.
```bash
$ src/chromium/src/out/debloating/chrome --app-id=oonpikaeehoaiikcikkcnadhgaigameg
```

License
-------
The own source code for this project is licensed under *the MIT license*,
which you can find in the LICENSE file. The external resources follow their licenses.
