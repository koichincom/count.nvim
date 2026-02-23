const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("prose_gauge", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const md4c = b.dependency("md4c", .{});
    mod.addCSourceFile(.{
        .file = md4c.path("src/md4c.c"),
        .flags = &.{},
    });
    mod.addIncludePath(md4c.path("src"));

    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "prose_gauge",
        .root_module = mod,
    });
    b.installArtifact(lib);

    const run_mod_tests = b.addRunArtifact(mod_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
