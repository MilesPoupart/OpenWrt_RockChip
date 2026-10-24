#!/usr/bin/env python3
"""Temporary GN and netspeedtest compatibility fixes; run in the OpenWrt root."""
from pathlib import Path
import re

root = Path.cwd()
if not (root / 'include/package.mk').is_file():
    raise SystemExit('Run this script from the OpenWrt source root')

def unique_dirs(paths):
    return sorted({p.resolve() for p in paths if p.is_dir()})

for gn in unique_dirs([root / 'feeds/helloworld/gn', root / 'package/community/helloworld/gn', root / 'package/feeds/helloworld/gn']):
    makefile = gn / 'Makefile'
    text = makefile.read_text()
    original = '\t$(PYTHON) $(HOST_BUILD_DIR)/build/gen.py'
    fixed = '\tCXX="$(HOSTCXX)" $(PYTHON) $(HOST_BUILD_DIR)/build/gen.py'
    compiler_fixed = bool(re.search(r'CXX=[^\n]*\$\(HOSTCXX\)[^\n]*build/gen\.py', text))
    # Current upstream supplies the Result fallback fix; only select the host compiler.
    if compiler_fixed:
        print(f'GN already uses HOSTCXX, skip: {gn}')
        continue
    if text.count(original) != 1:
        raise SystemExit(f'{makefile}: unexpected Host/Configure')
    makefile.write_text(text.replace(original, fixed, 1))
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
