const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = if (target.isWindows()) b: {
        const lib = b.addSharedLibrary("Window", "src/win32.zig", b.version(0, 0, 1));
        lib.linkSystemLibrary("gdi32");
        break :b lib;
    } else b: {
        const lib = b.addSharedLibrary("Window", "src/linux.zig", b.version(0, 0, 1));
        lib.linkSystemLibrary("X11");
        break :b lib;
    };
    lib.linkLibC();
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.install();

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
