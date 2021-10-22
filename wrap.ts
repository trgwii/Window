while (
  !(await Deno.run({
    cmd: [
      "deno",
      "run",
      "--allow-write=libPane2.so",
      "--unstable",
      "--allow-ffi",
      "https://raw.githubusercontent.com/trgwii/Window/master/test.ts",
    ],
  }).status()).success
);
