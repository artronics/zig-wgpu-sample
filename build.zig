const std = @import("std");
const zgpu = @import ("./zig-gamedev/libs/zgpu/build.zig");
const zmath = @import("./zig-gamedev/libs/zmath/build.zig");
const zpool = @import("./zig-gamedev/libs/zpool/build.zig");
const zglfw = @import("./zig-gamedev/libs/zglfw/build.zig");
const zgui = @import ("./zig-gamedev/libs/zgui/build.zig");

// TODO: run zig-gamedev build, otherwise submodule won't be present and it will cause error
pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("wgpu-ui-hello", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    const zgpu_options = zgpu.BuildOptionsStep.init(b, .{});
    const zgpu_pkg = zgpu.getPkg(&.{ zgpu_options.getPkg(), zpool.pkg, zglfw.pkg });

    exe.addPackage(zgpu_pkg);
    exe.addPackage(zgui.pkg);
    exe.addPackage(zmath.pkg);
    exe.addPackage(zglfw.pkg);

    zgpu.link(exe, zgpu_options);
    zglfw.link(exe);
    zgui.link(exe);

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
