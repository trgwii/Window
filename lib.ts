import linux from "./lib.linux.b.ts";
import win32 from "./lib.win32.b.ts";

export const name = Deno.build.os === "windows" ? "Window.dll" : "libWindow.so";
export const data = await (Deno.build.os === "windows" ? win32 : linux);
