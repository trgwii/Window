zig build -Drelease-fast
zig build -Drelease-fast -Dtarget=x86_64-windows
deno run --allow-read=zig-out/lib/libWindow.so.0.0.1 --allow-write=lib.linux.b.ts https://raw.githubusercontent.com/trgwii/bundler/8684f6d43b59d43f206f5edc99ee6d82c0334597/bundler.ts ts-bundle zig-out/lib/libWindow.so.0.0.1 lib.linux.b.ts
deno run --allow-read=zig-out/lib/Window.dll --allow-write=lib.win32.b.ts https://raw.githubusercontent.com/trgwii/bundler/8684f6d43b59d43f206f5edc99ee6d82c0334597/bundler.ts ts-bundle zig-out/lib/Window.dll lib.win32.b.ts
./run.sh
