const c = @cImport({
    @cInclude("windows.h");
});

pub fn main() void {
    const Window: c.HWND = c.CreateWindowA("BUTTON", // lpClassName
        "Thomas Game", // lpWindowName
        0x10CF0000, // dwStyle
        c.CW_USEDEFAULT, // X
        c.CW_USEDEFAULT, // Y
        c.CW_USEDEFAULT, // nWidth
        c.CW_USEDEFAULT, // nHeight
        0, // hWndParent
        0, // hMenu
        c.GetModuleHandleA(0), // hInstance
        c.NULL // lpParam
    );
    _ = Window;
}
