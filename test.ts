import { close, Window } from "./Window.ts";
const win = new Window(800, 600);

win.start();

win.writeText(50, 50, "Hello World");

win.fillRectangle(100, 100, 100, 100);

win.addEventListener("show", () => {
  console.log("show");
  win.writeText(50, 50, "Hello World");

  win.fillRectangle(100, 100, 100, 100);
});

// win.addEventListener('event', console.log);

setInterval(() => console.log("4"), 4000);
