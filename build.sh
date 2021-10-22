zig build -Drelease-fast
deno run --allow-read=zig-out/lib/libPane2.so.0.0.1 --allow-write=lib.b.ts https://raw.githubusercontent.com/trgwii/bundler/8684f6d43b59d43f206f5edc99ee6d82c0334597/bundler.ts ts-bundle zig-out/lib/libPane2.so.0.0.1 lib.b.ts
./run.sh
