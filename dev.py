#!/usr/bin/env python3
import argparse
import cxxfilt
import debloat
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot
import multiprocessing
import numpy
import os
import platform
import re
import requests
import shutil
import subprocess
import sys
import sysconfig
import time
import validators


PROJECT_ROOT_PATH = os.path.dirname(os.path.abspath(__file__))
SRC_PATH = os.path.normpath(os.path.join(PROJECT_ROOT_PATH, 'src'))
EVAL_PATH = os.path.normpath(os.path.join(PROJECT_ROOT_PATH, 'eval'))
TOOLS_PATH = os.path.normpath(os.path.join(PROJECT_ROOT_PATH, 'tools'))
CR_PATH = os.path.normpath(os.path.join(SRC_PATH, 'chromium', 'src'))
CR_BUILD_PATH = os.path.normpath(os.path.join(CR_PATH, 'out', 'release'))
CR_IR_BUILD_PATH = os.path.normpath(os.path.join(CR_PATH, 'out', 'ir'))
CR_PROFILING_BUILD_PATH = os.path.normpath(os.path.join(CR_PATH, 'out', 'profiling'))
CR_MARKING_BUILD_PATH = os.path.normpath(os.path.join(CR_PATH, 'out', 'marking'))
PROFILER_PATH = os.path.normpath(os.path.join(SRC_PATH, 'profiler'))
PUPPETEER_PATH = os.path.normpath(os.path.join(SRC_PATH, 'puppeteer'))
SAMPLE_PWA_PATH = os.path.normpath(os.path.join(SRC_PATH, 'your-first-pwapp'))
SLIMIUM_PATH = os.path.normpath(os.path.join(SRC_PATH, 'slimium'))
SLIMIUM_BUILD_PATH = os.path.normpath(os.path.join(SLIMIUM_PATH, 'build'))
llVM_PATH = os.path.normpath(os.path.join(SRC_PATH, '11vm'))
llVM_BUILD_PATH = os.path.normpath(os.path.join(llVM_PATH, 'build'))

HOME_PATH = os.path.expanduser('~')
CR_DEFAULT_PROFILE_PATH = os.path.join(HOME_PATH, '.config', 'chromium', 'Default')
CR_PROFILING_PROFILE_PATH = os.path.join(HOME_PATH, '.config', 'chromium-profiling', 'Default')

""" Sample App IDs
AlarmDJ: igmjclednlndjgjifdnigbdecnfcpgnj
AliExpress: lhkiobkckaniiagpmaimjbmldgpcnpgl
ChromeStatus: fedbieoalmbobgfjapopkghdmhgncnaa
Starbucks: oonpikaeehoaiikcikkcnadhgaigameg
Twitter: jgeocpdicgmkeemopbanhokmhcgcflmi
Uber: gijapfmjjfpakmbadajegooepglckjbg
Spotify: pjibgclleladliembfgfagdaldikeohf
Telegram: hadgilakbfohcfcgfbioeeehgpkopaga
Trivago: bbmbfpmmjcblnkdiipfnekpicpoabiho
"""
PWA_DEFAULT_ID = 'oonpikaeehoaiikcikkcnadhgaigameg'

CR_BUILD_CONFIG = [
#    'is_chrome_branded=true',
#    'is_official_build=true',
    'is_debug=false',
    'enable_nacl=false',
    'cc_wrapper="ccache"',
    'is_component_build=true',
    'enable_linux_installer=false',
    'symbol_level=0',
    'blink_symbol_level=0',
    'proprietary_codecs=true',
    'ffmpeg_branding="Chrome"',
]

SLIMIUM_BUILD_CONFIG = [
    'is_debug=false',
    'clang_base_path="' + llVM_BUILD_PATH + '"',
    'clang_use_chrome_plugins=false',
    'enable_nacl=false',
    'is_component_build=true',
    'enable_linux_installer=false',
    'symbol_level=0',
    'blink_symbol_level=0',
    'proprietary_codecs=true',
    'ffmpeg_branding="Chrome"',
]

# Avoid overwhelming cpu resource
CPU_COUNT = multiprocessing.cpu_count() - 1


def subprocess_run(*args, **kwargs):
    major, minor, patch_level = tuple(int(n) for n in platform.python_version_tuple())
    if major >= 3 and minor >= 5:
        return subprocess.run(*args, **kwargs)
    return subprocess.call(*args, **kwargs)


def build_chromium(env):
    if not os.path.isdir(CR_BUILD_PATH) or not os.path.isfile(CR_BUILD_PATH + '/args.gn'):
        subprocess_run(['gn', 'gen', 'out/release', '--args=' + ' '.join(CR_BUILD_CONFIG)], cwd=CR_PATH)

    # ccache setup
    env['CCACHE_BASEDIR'] = CR_PATH
    env['CCACHE_CPP2'] = 'yes'
    env['CCACHE_SLOPPINESS'] = 'time_macros'
    ccache_path = os.path.join(CR_PATH, 'third_party', 'llvm-build', 'Release+Asserts', 'bin')
    env['PATH'] = ccache_path + os.pathsep + env['PATH']
    subprocess_run(['autoninja', '-C', 'out/release', 'chrome', '-j' + str(CPU_COUNT)],
        cwd=CR_PATH, env=env)

    if sys.platform == 'darwin':
        print("Singing Chromium.app asks for your permission...")
        subprocess_run(['sudo', 'codesign', '--force', '--deep', '--sign', '-', 'Chromium.app'], cwd=CR_BUILD_PATH)


def generate_unique_function_ids(env):
    if not os.path.isdir(SLIMIUM_BUILD_PATH):
        os.mkdir(SLIMIUM_BUILD_PATH)

    env['LLVM_BUILD'] = llVM_BUILD_PATH
    index_file_path = os.path.join(SLIMIUM_BUILD_PATH, 'index.txt')
    devirt_path = os.path.join(SLIMIUM_PATH, 'src', 'static_analysis', 'customized_devirt')
    subprocess_run(['make'], cwd=devirt_path, env=env)
    bitcode_path = os.path.join(CR_IR_BUILD_PATH, 'bitcode')
    subprocess_run(['./build/Devirt', bitcode_path + '/', SLIMIUM_BUILD_PATH], cwd=devirt_path)

    file_functions_file_path = os.path.join(SLIMIUM_BUILD_PATH, 'file_functions.txt')
    group_functions_path = os.path.join(SLIMIUM_PATH, 'src', 'static_analysis', 'group-functions')
    subprocess_run(['make'], cwd=group_functions_path, env=env)
    subprocess_run(['./build/GroupFunctions', bitcode_path + '/', index_file_path, SLIMIUM_BUILD_PATH], cwd=group_functions_path)

    unique_index_file_path = os.path.join(SLIMIUM_BUILD_PATH, 'unique_indexes.txt')
    static_analysis_path = os.path.join(SLIMIUM_PATH, 'src', 'static_analysis')
    with open(unique_index_file_path, 'w') as f:
        subprocess_run(['python', 'generate_unique_indexes.py', index_file_path, file_functions_file_path], cwd=static_analysis_path, stdout=f)


def build_chromium_ir(env):
    if not os.path.isdir(CR_IR_BUILD_PATH) or not os.path.isfile(CR_IR_BUILD_PATH + '/args.gn'):
        cr_config = SLIMIUM_BUILD_CONFIG + ['enable_slimium_ir=true']
        subprocess_run(['gn', 'gen', 'out/ir', '--args=' + ' '.join(cr_config)], cwd=CR_PATH)

    bitcode_path = os.path.join(CR_IR_BUILD_PATH, 'bitcode')
    if not os.path.isdir(bitcode_path):
        os.mkdir(bitcode_path)

    env['llVM_IR_DUMP_PATH'] = bitcode_path
    subprocess_run(['autoninja', '-C', 'out/ir', 'chrome', '-j' + str(CPU_COUNT)], cwd=CR_PATH, env=env)
    generate_unique_function_ids(env)


def build_chromium_profiling(env):
    shm_size = None
    total_function_num = None
    with open(os.path.join(SLIMIUM_BUILD_PATH, 'unique_indexes.txt')) as f:
        last_line = f.readlines()[-1]
        total_function_num = int(last_line.split()[-2]) + 1
        shm_size = (int(total_function_num / 32) + 1) * 4
        print('total_function_num: {}, shm_size: {}'.format(total_function_num, shm_size))

    env['SLIMIUM_SHM_SIZE'] = str(shm_size)
    env['SLIMIUM_UNIQUE_INDEX_PATH'] = os.path.join(SLIMIUM_BUILD_PATH, 'unique_indexes.txt')
    subprocess_run(['make', '-j' + str(CPU_COUNT)], cwd=llVM_BUILD_PATH, env=env)

    shm_path = os.path.join(SLIMIUM_PATH, 'src', 'shm')
    subprocess_run(['make', 'clean'], cwd=shm_path)
    subprocess_run(['make', 'CFLAGS=-DTOTAL_FUNCTION_NUM=%d' % total_function_num], cwd=shm_path)
    subprocess_run(['./shm_create'], cwd=os.path.join(SLIMIUM_PATH, 'src', 'shm'))

    if not os.path.isdir(CR_PROFILING_BUILD_PATH) or not os.path.isfile(CR_PROFILING_BUILD_PATH + '/args.gn'):
        cr_config = SLIMIUM_BUILD_CONFIG + ['enable_slimium_web_api_profiling=true']
        subprocess_run(['gn', 'gen', 'out/profiling', '--args=' + ' '.join(cr_config)], cwd=CR_PATH)

    subprocess_run(['autoninja', '-C', 'out/profiling', 'chrome', '-j' + str(CPU_COUNT)], cwd=CR_PATH, env=env)


def build_chromium_marking(env):
    env['SLIMIUM_UNIQUE_INDEX_PATH'] = os.path.join(SLIMIUM_BUILD_PATH, 'unique_indexes.txt')
    subprocess_run(['make', '-j' + str(CPU_COUNT)], cwd=llVM_BUILD_PATH, env=env)

    if not os.path.isdir(CR_MARKING_BUILD_PATH) or not os.path.isfile(CR_MARKING_BUILD_PATH + '/args.gn'):
        cr_config = SLIMIUM_BUILD_CONFIG + ['enable_slimium_web_api_marking=true']
        subprocess_run(['gn', 'gen', 'out/marking', '--args=' + ' '.join(cr_config)], cwd=CR_PATH)
    subprocess_run(['autoninja', '-C', 'out/marking', 'chrome', '-j' + str(CPU_COUNT)],
        cwd=CR_PATH, env=env)

    is_component_build = False
    for config in SLIMIUM_BUILD_CONFIG:
        if config.startswith('is_component_build') and config.split('=')[1] == 'true':
            is_component_build = True

    func_id_tokens = []
    asms = []
    if is_component_build:
        target_func_map = {
            'libblink_core.so': [
                '<_ZN5blink18V8DocumentFragment28GetElementByIdMethodCallbackERKN2v820FunctionCallbackInfoINS1_5ValueEEE>',
                '<_ZN5blinkL19HTMLBodyConstructorERNS_8DocumentE18CreateElementFlags>',
                '<_ZNK5blink12css_longhand10FontFamily10ApplyValueERNS_18StyleResolverStateERKNS_8CSSValueE>',
                '<_ZN5blink20document_v8_internalL11Open1MethodERKN2v820FunctionCallbackInfoINS1_5ValueEEE>',
                '<_ZNK5blink12css_longhand14AnimationDelay15GetPropertyNameEv>',
            ],
            'libblink_modules.so': [
                '<_ZN5blink29V8AnimationWorkletGlobalScope30RegisterAnimatorMethodCallbackERKN2v820FunctionCallbackInfoINS1_5ValueEEE>',
                '<_ZN5blink39canvas_rendering_context_2d_v8_internalL19SetTransform2MethodERKN2v820FunctionCallbackInfoINS1_5ValueEEE>',

            ]
        }

        for target_bin in ['libblink_core.so', 'libblink_modules.so']:
            asm = os.path.join(CR_MARKING_BUILD_PATH, target_bin + '.asm')
            asms.append(asm)

            with open(asm, 'w') as f:
                subprocess_run(['objdump', '-d', '-w', '-z', '-F', '--insn-width=32', target_bin],
                    cwd=CR_MARKING_BUILD_PATH, stdout=f)

            token = None
            target_func_names = target_func_map[target_bin]
            for target_func_name in target_func_names:
                token = debloat.get_func_id_token(asm, target_func_name, '<cx_global_function_id')
                if token:
                    func_id_tokens.append(token)
                    break
    else:
        chrome_asm = os.path.join(CR_MARKING_BUILD_PATH, 'chrome.asm')
        asms.append(chrome_asm)
        with open(chrome_asm, 'w') as f:
            subprocess_run(['objdump', '-d', '-w', '-z', '-F', '--insn-width=32', 'chrome'],
                cwd=CR_MARKING_BUILD_PATH, stdout=f)

        target_func_name = '<_ZN5blinkL19HTMLBodyConstructorERNS_8DocumentE18CreateElementFlags>'
        token = debloat.get_func_id_token(chrome_asm, target_func_name, '<_DYNAMIC')
        if token:
            func_id_tokens.append(token)

    print('func_id_tokens: {}'.format(func_id_tokens))
    if asms and func_id_tokens:
        debloat.generate_function_boundaries(asms, func_id_tokens)


def build_11vm(env):
    build_path = os.path.join(llVM_PATH, 'build')
    if not os.path.isdir(build_path):
        os.mkdir(build_path)
        subprocess_run(['cmake', '-G', 'Unix Makefiles', '-DLLVM_ENABLE_PROJECTS=clang;lld;compiler-rt',
            '-DCMAKE_BUILD_TYPE=Release', '-DLLVM_TARGETS_TO_BUILD=X86', '../llvm'],
            cwd=build_path)

    subprocess_run(['make', '-j' + str(CPU_COUNT)], cwd=build_path, env=env)


def build_node_module(env, path):
    if not os.path.isdir(path + '/node_modules'):
        env['PUPPETEER_SKIP_CHROMIUM_DOWNLOAD'] = '1'
        subprocess_run(['npm', 'install'], cwd=path, env=env)
#    subprocess_run(['npm', 'run-script', 'build'], cwd=path)


def run_profiling(env):
    shm_path = os.path.join(SLIMIUM_PATH, 'src', 'shm')
    if not os.path.isfile(shm_path + '/shm_clear') or not os.path.isfile(shm_path + '/shm_decode'):
        return False

    subprocess_run(['./shm_create'], cwd=shm_path)
    subprocess_run(['./shm_clear'], cwd=shm_path)

    with open(os.path.join(CR_PROFILING_PROFILE_PATH, 'Preferences')) as f:
        try:
            app_path = json.load(f)['extensions']['settings'][PWA_DEFAULT_ID]['path']
        except:
            print('{} is not found in the preference'.format(PWA_DEFAULT_ID))
            return False
    replay_abs_path = os.path.join(CR_PROFILING_PROFILE_PATH, 'Extensions', app_path, 'replay')

    tests = []
    if os.path.isdir(replay_abs_path):
        for filename in os.listdir(replay_abs_path):
            if filename.endswith('.js'):
                tests.append(os.path.join(replay_abs_path, filename))
        tests.sort()

    profiling_count = 1
    now = time.time()
    while profiling_count > 0:
#        subprocess_run(['./chrome', '--app-id=%s' % PWA_DEFAULT_ID], cwd=CR_PROFILING_BUILD_PATH)
#        subprocess_run(['./chrome', '--incognito', 'http://app.starbucks.com'], cwd=CR_PROFILING_BUILD_PATH)
        for test in sorted(tests):
            subprocess_run(['node', './replay.js', test, '--app-id=%s' % PWA_DEFAULT_ID, '--wait-for=2000'], cwd=PROFILER_PATH)
        # Monkey test
#        subprocess_run(['node', './monkey.js', '--app-id=%s' % PWA_DEFAULT_ID, '--wait-for=240000'], cwd=PROFILER_PATH)
        profiling_count -= 1
    print('elapsed time: {} seconds'.format(round(time.time() - now, 2)))

    func_id_map = {}
    with open(os.path.join(SLIMIUM_BUILD_PATH, 'unique_indexes.txt')) as f:
        for line in f.readlines():
            words = line.split()
            filename = words[0]
            i = 1
            while i < len(words):
                func_id_map[words[i]] = [filename, words[i + 1]]
                i += 2

    output = subprocess_run(['./shm_decode'], cwd=shm_path, stdout=subprocess.PIPE).stdout
    profile_result_path = os.path.join(PROFILER_PATH, 'shm_decode.txt')
    with open(profile_result_path, 'w') as f:
        for line in output.splitlines()[:-1]:
            line = line.decode('utf-8')
            filename = func_id_map[line][0]
            mangled_func = func_id_map[line][1]
            try:
                func = cxxfilt.demangle(mangled_func)
            except:
                func = mangled_func
            f.write('{:<7} {} {} {}\n'.format(line, filename, mangled_func, func))
        print('{}'.format(output.splitlines()[-1].decode('utf-8')))

    install_path = os.path.join(CR_MARKING_BUILD_PATH, 'shm_decode.txt')
    shutil.copyfile(profile_result_path, install_path)
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", type=str, help="Available command {init, build, clean, run}.")
    parser.add_argument("command_args", nargs='*', type=str, default='',
        help="command arguments or sub-commands")

    args = parser.parse_args()
    command = args.command
    environment = os.environ.copy()
    environment['PATH'] += os.pathsep + sysconfig.get_paths()['scripts']
    if command == 'init':
        subprocess_run([TOOLS_PATH + '/install-dependencies'])

        environment['DEPOT_TOOLS_UPDATE'] = '0'
        subprocess_run(['gclient', 'sync', '-D', '--force', '--reset', '--jobs=' + str(CPU_COUNT)],
            cwd=CR_PATH, env=environment)
    elif command == 'build':
        if len(args.command_args) >= 1:
            if 'cr' in args.command_args:
                build_chromium(environment)
            if 'cr-ir' in args.command_args:
                build_chromium_ir(environment)
            if 'cr-profiling' in args.command_args:
                build_chromium_profiling(environment)
            if 'cr-marking' in args.command_args:
                build_chromium_marking(environment)
            if 'cr-config' in args.command_args:
                if not os.path.isdir(CR_BUILD_PATH) or not os.path.isfile(CR_BUILD_PATH + '/args.gn'):
                    subprocess_run(['gn', 'gen', 'out/release', '--args=' + ' '.join(CR_BUILD_CONFIG)], cwd=CR_PATH)
            if 'cr-ir-config' in args.command_args:
                cr_config = SLIMIUM_BUILD_CONFIG + ['enable_slimium_ir=true']
                subprocess_run(['gn', 'gen', 'out/ir', '--args=' + ' '.join(cr_config)], cwd=CR_PATH)
            if 'profiler' in args.command_args:
                build_node_module(environment, PUPPETEER_PATH)
                build_node_module(environment, PROFILER_PATH)
            if '11vm' in args.command_args:
                build_11vm(environment)
        else:
            build_11vm(environment)
            build_chromium_ir(environment)
            build_chromium_profiling(environment)
            build_chromium_marking(environment)
            build_node_module(environment, PUPPETEER_PATH)
            build_node_module(environment, PROFILER_PATH)
    elif command == 'clean':
        subprocess_run(['rm', '-rf', CR_BUILD_PATH])
        for path in [PUPPETEER_PATH]:
            subprocess_run(['rm', '-rf', path + '/node_modules'])
    elif command == 'run':
        if len(args.command_args) == 1:
            arg = args.command_args[0]

            cr_exe = './chrome'
            if sys.platform == 'darwin':
                cr_exe = './Chromium.app/Contents/MacOS/Chromium'

            if arg == 'debloating':
                shm_decode = os.path.join(CR_MARKING_BUILD_PATH, 'shm_decode.txt')
                if len(args.command_args) >= 2:
                    shm_decode = os.path.abspath(args.command_args[1])
                debloat.chromium(environment, shm_decode, app_id=PWA_DEFAULT_ID)
            elif arg == 'profiling':
                run_profiling(environment)
            elif validators.url(arg):
                subprocess_run([cr_exe, '--remote-debugging-port=9222',
                    '--disk-cache-dir=/dev/null',
                    '--disk-cache-size=1',
                    '--media-cache-size=1',
                    arg],
                    cwd=CR_BUILD_PATH)
            elif os.path.exists(arg):
                subprocess_run([cr_exe, '--remote-debugging-port=9222',
                    '--disk-cache-dir=/dev/null',
                    '--disk-cache-size=1',
                    '--media-cache-size=1',
                    os.path.abspath(arg)],
                    cwd=CR_BUILD_PATH)
            else:
                print('Error: {} is not a valid target to run.'.format(arg))
        else:
            print("Error: Put one target to run. (e.g., server, a test path)")
    else:
        print("One command is mandatory. You put a wrong command. See help with -h")


if __name__ == "__main__":
    main()
