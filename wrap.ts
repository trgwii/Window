while (
  !(await Deno.run({
    cmd: [
      "deno",
      "run",
      "--allow-write=libWindow.so",
      "--unstable",
      "--allow-ffi",
      (await Deno.stat('test.ts').then(() => true, () => false)) ? 'test.ts' : "https://raw.githubusercontent.com/trgwii/Window/master/test.ts",
    ],
  }).status()).success
);
