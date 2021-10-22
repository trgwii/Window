const std = @import("std");
const testing = std.testing;
const c = @cImport({
    @cInclude("X11/Xlib.h");
});

const cast = std.zig.c_translation.cast;

fn getDisplay(d_h: i32, d_l: i32) *c.Display {
    const d: i64 = (@intCast(i64, d_h) << 32) + d_l;
    const display: *c.Display = @intToPtr(*c.Display, @intCast(usize, d));
    return display;
}
fn getWindow(w_h: i32, w_l: i32) c.Window {
    const d: i64 = (@intCast(i64, w_h) << 32) + w_l;
    const window: c.Window = cast(c.Window, @intCast(usize, d));
    return window;
}

fn getScreen(display: *c.Display) c.Screen {
    const privDisplay = cast(c._XPrivDisplay, display);
    const s: i32 = privDisplay.*.default_screen;
    const screen = privDisplay.*.screens[@intCast(usize, s)];
    return screen;
}

export fn openDisplay() callconv(.C) i64 {
    const d: ?*c.Display = c.XOpenDisplay(0);
    if (d == null) {
        return 0;
    }
    return @intCast(i64, @ptrToInt(c.XOpenDisplay(0)));
}

export fn closeDisplay(d_h: i32, d_l: i32) callconv(.C) void {
    const display = getDisplay(d_h, d_l);
    _ = c.XCloseDisplay(display);
}

export fn createWindow(d_h: i32, d_l: i32, width: u32, height: u32) callconv(.C) i64 {
    const display = getDisplay(d_h, d_l);
    const screen = getScreen(display);
    const window: c.Window = c.XCreateSimpleWindow(
        display,
        screen.root,
        10,
        10,
        width,
        height,
        0,
        screen.black_pixel,
        screen.white_pixel,
    );
    _ = c.XSelectInput(
        display,
        window,
        c.ExposureMask | c.KeyPressMask | c.KeyReleaseMask | c.StructureNotifyMask,
    );
    _ = c.XMapWindow(display, window);
    return @intCast(i64, window);
}

fn setInt32(buf: []u8, offset: u32, value: i32) void {
    buf[offset + 0] = @intCast(u8, value & 0xFF);
    buf[offset + 1] = @intCast(u8, (value >> 8) & 0xFF);
    buf[offset + 2] = @intCast(u8, (value >> 16) & 0xFF);
    buf[offset + 3] = @intCast(u8, (value >> 24) & 0xFF);
}

export fn writeText(d_h: i32, d_l: i32, w_h: i32, w_l: i32, x: i32, y: i32, buf: [*]u8, len: usize) callconv(.C) void {
    const display = getDisplay(d_h, d_l);
    const window = getWindow(w_h, w_l);
    var text: []u8 = undefined;
    text.ptr = buf;
    text.len = len;
    _ = c.XDrawString(
        display,
        window,
        getScreen(display).default_gc,
        x,
        y,
        text.ptr,
        @intCast(c_int, text.len),
    );
}

export fn clearWindow(d_h: i32, d_l: i32, w_h: i32, w_l: i32) callconv(.C) void {
    _ = c.XClearWindow(getDisplay(d_h, d_l), getWindow(w_h, w_l));
}

export fn fillRectangle(d_h: i32, d_l: i32, w_h: i32, w_l: i32, x: i32, y: i32, width: u32, height: u32) callconv(.C) void {
    const display = getDisplay(d_h, d_l);
    const window = getWindow(w_h, w_l);
    _ = c.XFillRectangle(display, window, getScreen(display).default_gc, x, y, width, height);
}

export fn setForeground(d_h: i32, d_l: i32, color: u32) callconv(.C) void {
    const display = getDisplay(d_h, d_l);
    _ = c.XSetForeground(display, getScreen(display).default_gc, color);
}

export fn getEvent(d_h: i32, d_l: i32, buf: [*]u8, len: usize) callconv(.C) i32 {
    var out: []u8 = undefined;
    out.ptr = buf;
    out.len = len;
    const display = getDisplay(d_h, d_l);
    var event: c.XEvent = undefined;
    while (c.XPending(display) == 0) {}
    _ = c.XNextEvent(display, &event);
    setInt32(out, 0, @intCast(i32, event.xkey.keycode));
    return event.type;
}
