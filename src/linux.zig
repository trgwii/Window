const std = @import("std");
const c = @cImport({
    @cInclude("X11/Xlib.h");
});

const cast = std.zig.c_translation.cast;

var display: ?*c.Display = undefined;

export fn openWindow(width: u32, height: u32) callconv(.C) u64 {
    // TODO: Handle all errors
    display = c.XOpenDisplay(0);
    if (display == null) {
        return 0;
    }
    const privDisplay = cast(c._XPrivDisplay, display);
    const s: i32 = privDisplay.*.default_screen;
    const screen = privDisplay.*.screens[@intCast(usize, s)];
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
    return @intCast(u64, window);
}

export fn closeWindow(w_h: i32, w_l: i32) callconv(.C) void {
    // TODO: handle all errors
    const w: i64 = (@intCast(i64, w_h) << 32) + w_l;
    const window: c.Window = cast(c.Window, @intCast(usize, w));
    _ = c.XDestroyWindow(display, window);
}

export fn drawText(w_h: i32, w_l: i32, x: u32, y: u32, buf: [*]u8, len: usize) callconv(.C) void {
    // TODO: handle all errors
    const w: i64 = (@intCast(i64, w_h) << 32) + w_l;
    const window: c.Window = cast(c.Window, @intCast(usize, w));
    var text: []u8 = undefined;
    text.ptr = buf;
    text.len = len;
    const privDisplay = cast(c._XPrivDisplay, display);
    const s: i32 = privDisplay.*.default_screen;
    const screen = privDisplay.*.screens[@intCast(usize, s)];
    _ = c.XDrawString(
        display,
        window,
        screen.default_gc,
        @intCast(i32, x),
        @intCast(i32, y),
        text.ptr,
        @intCast(c_int, text.len),
    );
}

export fn drawRect(w_h: i32, w_l: i32, x: u32, y: u32, width: u32, height: u32) callconv(.C) void {
    // TODO: handle all errors
    const w: i64 = (@intCast(i64, w_h) << 32) + w_l;
    const window: c.Window = cast(c.Window, @intCast(usize, w));
    const privDisplay = cast(c._XPrivDisplay, display);
    const s: i32 = privDisplay.*.default_screen;
    const screen = privDisplay.*.screens[@intCast(usize, s)];
    _ = c.XFillRectangle(display, window, screen.default_gc, @intCast(i32, x), @intCast(i32, y), width, height);
}

inline fn setInt32(buf: []u8, offset: u32, value: i32) void {
    buf[offset + 0] = @intCast(u8, value & 0xFF);
    buf[offset + 1] = @intCast(u8, (value >> 8) & 0xFF);
    buf[offset + 2] = @intCast(u8, (value >> 16) & 0xFF);
    buf[offset + 3] = @intCast(u8, (value >> 24) & 0xFF);
}

export fn getEvent(w_h: i32, w_l: i32, buf: [*]u8, len: usize) callconv(.C) i32 {
    // TODO: handle all errors
    var out: []u8 = undefined;
    out.ptr = buf;
    out.len = len;
    var event: c.XEvent = undefined;
    const w: i64 = (@intCast(i64, w_h) << 32) + w_l;
    const window: c.Window = cast(c.Window, @intCast(usize, w));
    if (c.XCheckWindowEvent(display, window, 0xFFFFFFFF, &event) == 0) {
        return 0;
    }
    setInt32(out, 0, @intCast(i32, event.xkey.keycode));
    return event.type;
}
