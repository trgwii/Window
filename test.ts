import { close, Window } from "./pane2.ts";
const win = new Window(800, 600);

win.addEventListener("show", () => {
  // console.log("show");
});

let x = 10;
let y = 10;

const keys: Record<string, boolean> = {};

win.start();

const interval = setInterval(() => {
  if (keys.ArrowLeft) x -= 1;
  if (keys.ArrowRight) x += 1;
  if (keys.ArrowUp) y -= 1;
  if (keys.ArrowDown) y += 1;
  if (keys[" "]) {
    win.clear();
  }
  win.fillRectangle(x + 100, y, 4, 4);
  if (keys.q) {
    clearInterval(interval);
    win.close().then(() => close());
  }
}, 15);

win.addEventListener("keydown", (e) => {
  keys[e.key] = true;
});

win.addEventListener("keyup", (e) => {
  keys[e.key] = false;
});
