#!/usr/bin/env python3
import cxxfilt
import json
import os
import shutil
import time

from dev import CR_DEFAULT_PROFILE_PATH, CR_DEBLOATING_BUILD_PATH, SLIMIUM_BUILD_CONFIG, SLIMIUM_BUILD_PATH
from elftools.elf.elffile import ELFFile

def get_func_id_token(asm, func_name, token_prefix):
    with open(asm, 'r') as f:
        lines = f.readlines()
        is_in_target_func = False

        for line in lines:
            line = line.strip()
            if line.endswith('):'):
                if is_in_target_func:
                    break
                if func_name in line:
                    is_in_target_func = True
                continue

            if not is_in_target_func:
                continue

            insn_tokens = line.split()
            if not insn_tokens:
                continue

            if 'mov' in insn_tokens and insn_tokens[-4].startswith(token_prefix):
                return insn_tokens[-4]
    return None


def generate_function_boundaries(asms, func_id_tokens):
    func_file_map = {}
    with open(os.path.join(SLIMIUM_BUILD_PATH, 'unique_indexes.txt')) as f:
        for line in f.readlines():
            words = line.split()
            filename = words[0]
            i = 1
            while i < len(words):
                func_file_map[int(words[i])] = filename
                i += 2

    functions = []
    for asm in asms:
        with open(asm, 'r') as f:
            lines = f.readlines()
            line_num = len(lines)

            i = 0
            while i < line_num:
                line = lines[i].strip()
                # found a function head
                if line.endswith('):'):
                    words = line.split()
                    func_addr = int('0x' + words[0], 16)
                    func_name = words[1][1:-1]
                    file_offset = int(words[-1][:-2], 16)

                    insns = []
                    # parse the function body until an empty line
                    j = i + 1
                    while j < line_num:
                        insn_line = lines[j].strip()
                        if len(insn_line) == 0:
                            break

                        tokens = insn_line.split()
                        try:
                            addr = int('0x' + tokens[0][:-1], 16)
                            length = len(insn_line[:105].split()) - 1

                            sub_tokens = insn_line[105:].split()
                            opcode = sub_tokens[0]
                            operands = sub_tokens[1:] if len(sub_tokens) > 1 else []
                            insns.append((addr, length, opcode, operands))
                        except:
                            print(insn_line)

                        j += 1

                    functions.append((func_addr, file_offset, func_name, insns))
                    i = j + 1
                else:
                    i += 1

    with open(os.path.join(SLIMIUM_BUILD_PATH, 'disassembled_functions.txt'), 'w') as f:
        for (func_start, file_offset, func_name, insns) in functions:
            func_end = insns[-1][0] + insns[-1][1]  - 1
            func_ids = []
            i = 0
            found_global_id_ref = False

            while i < len(insns):
                (addr, length, opcode, operands) = insns[i]
                if opcode == 'mov' and len(operands) == 7 and operands[-4] in func_id_tokens:
                    found_global_id_ref = True
                    register = operands[0].split(',')[-1]

                    j = i + 1
                    while j < len(insns):
                        addr, length, opcode, operands = insns[j]
                        if opcode == 'movl' and len(operands) == 1 and operands[0].endswith('(' + register + ')'):
                            func_id = int(operands[0].split(',')[0][1:], 16)
                            func_ids.append(func_id)
                            break
                        j += 1
                    i = j + 1
                else:
                    i += 1

            if found_global_id_ref and len(func_ids) == 0:
                print("WARN: {} {}", hex(func_start), len(func_ids))

            assert len(func_ids) <= 1
            if len(func_ids) == 1:
                func_id = func_ids[0]
                try:
                    demangled_func_name = cxxfilt.demangle(func_name)
                except:
                    demangled_func_name = func_name
                f.write("%d 0x%x 0x%x 0x%x %s %s %s\n" % (func_id, func_start, func_end, file_offset, func_name, func_file_map[func_id], demangled_func_name))


def chromium(env, profile, app_id):
    if not os.path.isfile(profile):
        print('A profiling result is not found.')
        return
    if not app_id:
        print('No app id of PWA to debloat is provided.')
        return

    is_component_build = False
    for config in SLIMIUM_BUILD_CONFIG:
        if config.startswith('is_component_build') and config.split('=')[1] == 'true':
            is_component_build = True

    target_bin_names = []
    if is_component_build:
        target_bin_names.extend(['libblink_core.so', 'libblink_modules.so'])
    else:
        target_bin_names.append('chrome')

    target_bins = {}
    for name in target_bin_names:
        bin_path = os.path.join(CR_DEBLOATING_BUILD_PATH, name)
        if not os.path.isfile(bin_path):
            print('{} is not found.'.format(name))
            return
        target_bins[name] = { 'path': bin_path, 'offset': 0 }

    disasm_funcs = os.path.join(SLIMIUM_BUILD_PATH, 'disassembled_functions.txt')
    if not os.path.isfile(disasm_funcs):
        print('disassembled_functions.txt is not found.')
        return

    used_func_ids = []
    with open(profile, 'r') as f:
        for line in f.readlines():
            used_func_ids.append(int(line.split()[0]))

    func_ids = []
    func_ranges = {}
    with open(disasm_funcs, 'r') as f:
        for line in f.readlines():
            line = line.strip()
            if line.startswith('#'):
                continue
            words = line.split()
            func_id = int(words[0])
            func_ids.append(func_id)
            func_ranges[func_id] = (int(words[1], 16), int(words[2], 16), int(words[3], 16), words[4], words[5])


    #removable_func_ids = list(filter(lambda i : i not in used_func_ids, func_ids))
    removable_func_ids = list(set(func_ids) - set(used_func_ids))
    if not removable_func_ids:
        return

    for name in target_bins:
        bin_dbt = os.path.join(CR_DEBLOATING_BUILD_PATH, name + '.dbt')
        target_bin = target_bins[name]['path']
        shutil.copyfile(target_bin, bin_dbt)
        shutil.copymode(target_bin, bin_dbt)


    # FIXME: This block may be unnecessary.
    for name in target_bins:
        with open(target_bins[name]['path'], 'rb') as f:
            elf_file = ELFFile(f)
            for section in elf_file.iter_sections():
                if section.name == '.text':
                    offset = section['sh_addr'] - section['sh_offset']
                    offset = 0 if offset < 0 else offset
                    target_bins[name]['offset'] = offset
                    break

    removed_size = 0
    removed_funcs = os.path.join(CR_DEBLOATING_BUILD_PATH, 'removed_funcs.txt')
    if is_component_build:
        blink_core_dbt = os.path.join(CR_DEBLOATING_BUILD_PATH, 'libblink_core.so.dbt')
        blink_modules_dbt = os.path.join(CR_DEBLOATING_BUILD_PATH, 'libblink_modules.so.dbt')
        with open(blink_core_dbt, 'rb+') as c, open(blink_modules_dbt, 'rb+') as m, open(removed_funcs, 'w') as f:
            for func_id in removable_func_ids:
#                assert func_id not in used_func_ids
                start_addr, end_addr, file_offset, func_name, filename = func_ranges[func_id]
                func_size = end_addr - start_addr + 1
                removed_size += func_size

                if 'core' in filename:
#                    c.seek(start_addr - target_bins['libblink_core.so']['offset'], 0)
                    c.seek(file_offset, 0)
                    c.write(bytes([int('0xcc', 0)] * func_size))    # original code: '0x6d'
                elif 'modules' in filename:
#                    m.seek(start_addr - target_bins['libblink_modules.so']['offset'], 0)
                    m.seek(file_offset, 0)
                    m.write(bytes([int('0xcc', 0)] * func_size))    # original code: '0x6d'
                else:
                    assert True

                try:
                    demangled_func_name = cxxfilt.demangle(func_name)
                except:
                    demangled_func_name = func_name
                f.write('{} {:x} {:x} {} {} {}\n'.format(func_id, start_addr, end_addr, func_name, demangled_func_name, filename))
    else:
        chrome_dbt = os.path.join(CR_DEBLOATING_BUILD_PATH, 'chrome.dbt')
        with open(chrome_dbt, 'rb+') as c, open(removed_funcs, 'w') as f:
            for func_id in removable_func_ids:
#                assert func_id not in used_func_ids
                start_addr, end_addr, func_name, filename = func_ranges[func_id]
                func_size = end_addr - start_addr + 1
                removed_size += func_size

                c.seek(start_addr - target_bins['chrome']['offset'], 0)
                c.write(bytes([int('0xcc', 0)] * func_size))    # original code: '0x6d'

                try:
                    demangled_func_name = cxxfilt.demangle(func_name)
                except:
                    demangled_func_name = func_name
                f.write('{} {:x} {:x} {} {} {}\n'.format(func_id, start_addr, end_addr, func_name, demangled_func_name, filename))
    print("Removed: {} MB".format(removed_size / (1024 * 1024)))

    with open(os.path.join(CR_DEFAULT_PROFILE_PATH, 'Preferences')) as f:
        app_path = json.load(f)['extensions']['settings'][app_id]['path']

    app_abs_path = os.path.join(CR_DEFAULT_PROFILE_PATH, 'Extensions', app_path)
    install_path = os.path.join(app_abs_path, 'lib' if is_component_build else 'bin')
    if not os.path.isdir(install_path):
        os.makedirs(install_path, exist_ok=True)

    for name in target_bins:
        bin_dbt = os.path.join(CR_DEBLOATING_BUILD_PATH, name + '.dbt')
#        shutil.move(bin_dbt, os.path.join(install_path, name))
        shutil.copyfile(bin_dbt, os.path.join(install_path, name))
        shutil.copymode(bin_dbt, os.path.join(install_path, name))
