import { data, name } from "./lib.ts";

await Deno.writeFile(name, data);

const mod = Deno.dlopen("./" + name, {
  openWindow: {
    parameters: ["u32", "u32"],
    result: "u64",
  },
  closeWindow: {
    parameters: ["i32", "i32"],
    result: "void",
  },
  drawText: {
    parameters: ["i32", "i32", "u32", "u32", "buffer", "usize"],
    result: "void",
  },
  drawRect: {
    parameters: ["i32", "i32", "u32", "u32", "u32", "u32"],
    result: "void",
  },
  getEvent: {
    parameters: ["i32", "i32", "buffer", "usize"],
    result: "i32",
  },
});

export const close = () => {
  mod.close();
};

const key = (code: number) =>
  ({
    24: "q",
    65: " ",
    111: "ArrowUp",
    113: "ArrowLeft",
    114: "ArrowRight",
    116: "ArrowDown",
  })[code] ?? "";

enum WindowEvent {
  KeyPress = 2,
  KeyRelease = 3,
  Expose = 12,
}

// deno-lint-ignore camelcase
const i64_i32 = (
  i64: bigint,
) => [Number(i64 >> 32n), Number(i64 & 0xFFFFFFFFn)];

interface WinEvent extends Event {
  key: string;
  _code: number;
}

interface WinEventListener {
  (evt: WinEvent): void | Promise<void>;
}

interface WinEventListenerObject {
  handleEvent(evt: WinEvent): void | Promise<void>;
}

type WinEventListenerOrWinEventListenerObject =
  | WinEventListener
  | WinEventListenerObject;

export class Window extends EventTarget {
  #window: bigint;
  #running = false;
  declare addEventListener: (
    type: string,
    listener: WinEventListenerOrWinEventListenerObject | null,
    options?: boolean | AddEventListenerOptions,
  ) => void;
  #e?: Promise<WindowEvent>;
  constructor(width: number, height: number) {
    super();
    this.#window = BigInt(mod.symbols.openWindow(
      width,
      height,
    ) as number);
  }
  writeText(x: number, y: number, str: string) {
    const buf = new TextEncoder().encode(str);
    mod.symbols.drawText(
      ...i64_i32(this.#window),
      x,
      y,
      buf,
      buf.byteLength,
    );
  }

  fillRectangle(x: number, y: number, width: number, height: number) {
    // await this.setForeground(color);
    mod.symbols.drawRect(
      ...i64_i32(this.#window),
      x,
      y,
      width,
      height,
    );
  }
  async close() {
    this.#running = false;
    await this.#e;
    mod.symbols.closeWindow(...i64_i32(this.#window));
  }
  async start() {
    this.#running = true;
    while (this.#running) {
      const buf = new Uint8Array(4);
      this.#e = mod.symbols.getEvent(
        ...i64_i32(this.#window),
        buf,
        buf.byteLength,
      ) as Promise<WindowEvent>;
      const e = (await this.#e) as WindowEvent;
      if (e === WindowEvent.Expose) {
        this.dispatchEvent(new Event("show"));
        continue;
      }
      if (e === WindowEvent.KeyPress || e === WindowEvent.KeyRelease) {
        this.dispatchEvent(
          Object.assign(
            new Event(e === WindowEvent.KeyPress ? "keydown" : "keyup"),
            { _code: buf[0], key: key(buf[0]) },
          ),
        );
        continue;
      }
    }
  }
  stop() {
    this.#running = false;
  }
}
