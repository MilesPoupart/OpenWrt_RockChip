#!/usr/bin/env python3
"""Temporary GN and netspeedtest compatibility fixes; run in the OpenWrt root."""
from pathlib import Path
import re

root = Path.cwd()
if not (root / 'include/package.mk').is_file():
    raise SystemExit('Run this script from the OpenWrt source root')

patch = (
    'Subject: [PATCH] gn: support converting values in the Result fallback\n'
    '\n'
    'The libstdc++ fallback must accept values constructible as T, just as the\n'
    'std::expected-backed implementation does. Otherwise returning a lambda\n'
    'as Result<std::function<...>> requires two user-defined conversions and\n'
    'fails in edit_subcommands.cc. Exclude Result and Err so copy/move and\n'
    'error-state construction retain their existing behavior.\n'
    '\n'
    '--- a/src/gn/err.h\n'
    '+++ b/src/gn/err.h\n'
    '@@ -210,6 +210,14 @@ class Result {\n'
    ' \n'
    '   Result(T&& value) : storage_(std::move(value)) {}\n'
    ' \n'
    '+  template <typename U,\n'
    '+            std::enable_if_t<\n'
    '+                !std::is_same_v<std::decay_t<U>, Result> &&\n'
    '+                !std::is_same_v<std::decay_t<U>, Err> &&\n'
    '+                std::is_constructible_v<T, U&&>, int> = 0>\n'
    '+  Result(U&& value)\n'
    '+      : storage_(std::in_place_type<T>, std::forward<U>(value)) {}\n'
    '+\n'
    '   // Implicit conversion from Err (always creates an error state).\n'
    '   Result(Err err) : storage_(std::move(err)) {\n'
    '     DCHECK(error().has_error());\n'
).encode()

def unique_dirs(paths):
    return sorted({p.resolve() for p in paths if p.is_dir()})

for gn in unique_dirs([root / 'feeds/helloworld/gn', root / 'package/community/helloworld/gn', root / 'package/feeds/helloworld/gn']):
    makefile = gn / 'Makefile'
    text = makefile.read_text()
    original = '\t$(PYTHON) $(HOST_BUILD_DIR)/build/gen.py'
    fixed = '\tCXX="$(HOSTCXX)" $(PYTHON) $(HOST_BUILD_DIR)/build/gen.py'
    compiler_fixed = bool(re.search(r'CXX=[^\n]*\$\(HOSTCXX\)[^\n]*build/gen\.py', text))
    # Inspect added/context lines, never removed lines, including renamed upstream patches.
    patches = list((gn / 'patches').glob('*.patch'))
    effective = '\n'.join(
        line[1:] for file in patches for line in file.read_text().splitlines()
        if line.startswith((' ', '+')) and not line.startswith('+++')
    )
    result_fixed = bool(re.search(r'Result\s*\(\s*U\s*&&\s*value\s*\)', effective)) and 'std::forward<U>(value)' in effective
    dest = gn / 'patches/050-fix-result-fallback-converting-constructor.patch'
    if compiler_fixed and result_fixed:
        print(f'GN already fixed, skip: {gn}')
        continue
    # Unknown revisions/layouts need review; do not blindly apply an old source patch.
    if 'PKG_SOURCE_VERSION:=356ee8a865882bb3615422539ef262e32b102030' not in text:
        raise SystemExit(f'{gn}: unknown GN revision; review temporary fix')
    if not compiler_fixed:
        if text.count(original) != 1:
            raise SystemExit(f'{makefile}: unexpected Host/Configure')
        text = text.replace(original, fixed, 1)
    if not result_fixed:
        if 'Result(T&& value)' not in effective:
            raise SystemExit(f'{gn}: expected Result fallback missing; review temporary fix')
        if dest.exists():
            raise SystemExit(f'{dest}: unrecognized existing patch; review before replacing')
        dest.write_bytes(patch)
        print(f'Added Result compatibility patch: {gn}')
    if makefile.read_text() != text:
        makefile.write_text(text)
        print(f'Configured GN to use HOSTCXX: {gn}')

candidates = [root / 'package/community/netspeedtest/luci-app-netspeedtest']
for base in [root / 'feeds', root / 'customfeeds', root / 'package/feeds']:
    if base.exists():
        for feed in base.iterdir():
            candidates.extend([feed / 'luci-app-netspeedtest', feed / 'applications/luci-app-netspeedtest'])
for package in unique_dirs(candidates):
    makefile = package / 'Makefile'
    text = makefile.read_text()
    if '+python3-pkg-resources' not in text:
        print(f'netspeedtest dependency already fixed: {package}')
        continue
    # Do not drop a runtime dependency if a future version actually uses its API.
    for source in (package / 'root').rglob('*'):
        if source.is_file() and b'pkg_resources' in source.read_bytes():
            raise SystemExit(f'{source}: uses pkg_resources; dependency removal needs review')
    fixed, count = re.subn(r'\+python3-pkg-resources(?=\s|$)', '', text)
    if count != 1:
        raise SystemExit(f'{makefile}: unexpected dependency declaration')
    makefile.write_text(fixed)
    print(f'Removed obsolete netspeedtest dependency: {package}')
