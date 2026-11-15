#!/bin/bash
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

LLD="$ROOT/xnu-deps/host/zig/zig ld.lld"
CFLAGS="--target=aarch64-linux-gnu -ffreestanding -nostdlib -fno-builtin -mgeneral-regs-only -mstrict-align -Os -Wall -Wextra"

if [ ! -f "$HERE/touchfw.h" ]; then
	printf "#define TOUCH_FW_SIZE 16\nstatic const unsigned char touch_fw[16] = {0};\n" > "$HERE/touchfw.h"
fi
[ -f "$HERE/font8x16.h" ] || swift "$HERE/../tools/mkfont8x16.swift" > "$HERE/font8x16.h"

clang $CFLAGS "$@" -c "$HERE/start.S" -o "$HERE/start.o"
clang $CFLAGS "$@" -c "$HERE/mtkloader.c" -o "$HERE/mtkloader.o"
$LLD -T "$HERE/link.ld" --oformat binary "$HERE/start.o" "$HERE/mtkloader.o" -o "$HERE/mtkloader.bin"
ls -la "$HERE/mtkloader.bin"
