const std = @import("std");

pub const BuildOptions = struct {
    enable_debug_layer: bool = false,
};

pub const BuildOptionsStep = struct {
    options: BuildOptions,
    step: *std.build.OptionsStep,

    pub fn init(b: *std.Build, options: BuildOptions) BuildOptionsStep {
        const bos = .{
            .options = options,
            .step = b.addOptions(),
        };
        bos.step.addOption(bool, "enable_debug_layer", bos.options.enable_debug_layer);
        return bos;
    }

    pub fn getPkg(bos: BuildOptionsStep) std.Build.Pkg {
        return bos.step.getPackage("zxaudio2_options");
    }

    fn addTo(bos: BuildOptionsStep, target_step: *std.Build.CompileStep) void {
        target_step.addOptions("zxaudio2_options", bos.step);
    }
};

pub fn getPkg(dependencies: []const std.Build.Pkg) std.Build.Pkg {
    return .{
        .name = "zxaudio2",
        .source = .{ .path = thisDir() ++ "/src/zxaudio2.zig" },
        .dependencies = dependencies,
    };
}

pub fn build(_: *std.Build) void {}

pub fn link(exe: *std.Build.CompileStep, bos: BuildOptionsStep) void {
    bos.addTo(exe);

    if (bos.options.enable_debug_layer) {
        exe.step.dependOn(
            &exe.builder.addInstallFile(
                .{ .path = thisDir() ++ "/../zwin32/bin/x64/xaudio2_9redist_debug.dll" },
                "bin/xaudio2_9redist.dll",
            ).step,
        );
    } else {
        exe.step.dependOn(
            &exe.builder.addInstallFile(
                .{ .path = thisDir() ++ "/../zwin32/bin/x64/xaudio2_9redist.dll" },
                "bin/xaudio2_9redist.dll",
            ).step,
        );
    }
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
