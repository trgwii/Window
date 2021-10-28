const std = @import("std");
const c = @cImport({
    @cInclude("windows.h");
});

const cast = std.zig.c_translation.cast;

fn windowCallback(hWnd: c.HWND, Msg: c.UINT, wParam: c.WPARAM, lParam: c.LPARAM) callconv(.C) c.LRESULT {
    if (Msg == c.WM_SIZE or Msg == c.WM_PAINT) {
        return 0;
    }
    return c.DefWindowProcA(hWnd, Msg, wParam, lParam);
}

export fn openWindow(width: u32, height: u32) callconv(.C) u64 {
    const windowClass = c.WNDCLASSA{
        .style = c.CS_HREDRAW | c.CS_VREDRAW | c.CS_OWNDC,
        .lpfnWndProc = windowCallback,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = c.GetModuleHandleA(0),
        .hIcon = 0,
        .hCursor = c.LoadCursorA(0, 32512),
        .hbrBackground = 0,
        .lpszMenuName = 0,
        .lpszClassName = "trgwiiWindowClass",
    };
    _ = c.RegisterClassA(&windowClass);

    const window = c.CreateWindowA(windowClass.lpszClassName, // lpClassName
        "", // lpWindowName
        0x10CF0000, // dwStyle
        c.CW_USEDEFAULT, // X
        c.CW_USEDEFAULT, // Y
        @intCast(i32, width), // nWidth
        @intCast(i32, height), // nHeight
        0, // hWndParent
        0, // hMenu
        c.GetModuleHandleA(0), // hInstance
        c.NULL // lpParam
    );
    return @ptrToInt(window);
}

export fn closeWindow(w_h: i32, w_l: i32) callconv(.C) void {
    const w = (@intCast(i64, w_h) << 32) + w_l;
    const window = cast(c.HWND, @intCast(usize, w));
    _ = c.DestroyWindow(window);
}

export fn drawText(w_h: i32, w_l: i32, x: u32, y: u32, buf: [*]u8, len: usize) callconv(.C) void {
    const w = (@intCast(i64, w_h) << 32) + w_l;
    const window = cast(c.HWND, @intCast(usize, w));
    const dc = c.GetDC(window);
    _ = c.TextOutA(dc, @intCast(i32, x), @intCast(i32, y), &(buf[0]), @intCast(i32, len));
    _ = c.ReleaseDC(window, dc);
}

export fn drawRect(w_h: i32, w_l: i32, x: u32, y: u32, width: u32, height: u32) callconv(.C) void {
    const w = (@intCast(i64, w_h) << 32) + w_l;
    const window = cast(c.HWND, @intCast(usize, w));
    var rect = c.RECT{
        .left = @intCast(i32, x),
        .top = @intCast(i32, y),
        .right = @intCast(i32, x + width),
        .bottom = @intCast(i32, y + height),
    };
    const dc = c.GetDC(window);
    const brush = c.CreateSolidBrush(0x00000000);
    _ = c.FillRect(dc, &rect, brush);
    _ = c.DeleteObject(brush);
    _ = c.ReleaseDC(window, dc);
}

export fn getEvent(w_h: i32, w_l: i32, buf: [*]u8, len: usize) callconv(.C) i32 {
    const w = (@intCast(i64, w_h) << 32) + w_l;
    const window = cast(c.HWND, @intCast(usize, w));
    var m: c.MSG = undefined;
    if (c.PeekMessageA(&m, window, 0, 0, c.PM_REMOVE) == 0) {
        return 0;
    }
    _ = c.TranslateMessage(&m);
    _ = c.DispatchMessageA(&m);
    _ = buf;
    _ = len;
    return @intCast(i32, m.message);
}
