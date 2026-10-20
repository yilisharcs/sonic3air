const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const arch_os = b.fmt("{s}-{s}", .{
        @tagName(target.result.cpu.arch),
        @tagName(target.result.os.tag),
    });

    const devtree_dir = b.fmt("{s}/dev", .{arch_os});
    const release_dir = b.fmt("{s}/sonic3air_game", .{arch_os});

    const game = b.dependency("sonic3air_game", .{
        .target = target,
        .optimize = optimize,
    });
    const exe = game.artifact("sonic3air");
    const exe_name = b.fmt("sonic3air_{s}", .{@tagName(target.result.os.tag)});

    // ---- dev tree ----
    // unpacked sources that the release bundle packs before shipping

    const with_default_config = b.option(bool, "config", "Stage config.json into the dev tree") orelse true;
    if (with_default_config) {
        b.installFile(
            "Oxygen/sonic3air/_master_image_template/config.json",
            b.fmt("{s}/bin/config.json", .{devtree_dir}),
        );
    } else {
        const io = b.graph.io;
        b.root.root_dir.handle.deleteFile(io, b.fmt(
            "zig-out/{s}/bin/config.json",
            .{devtree_dir},
        )) catch |err| switch (err) {
            error.FileNotFound => {},
            else => @panic(@errorName(err)),
        };
    }

    b.installFile(
        "Oxygen/sonic3air/oxygenproject.json",
        b.fmt("{s}/bin/oxygenproject.json", .{devtree_dir}),
    );
    b.installDirectory(.{
        .source_dir = b.path("Oxygen/sonic3air/scripts"),
        .install_dir = .{ .custom = devtree_dir },
        .install_subdir = "bin/scripts",
    });
    b.installDirectory(.{
        .source_dir = b.path("Oxygen/oxygenengine/data"),
        .install_dir = .{ .custom = devtree_dir },
        .install_subdir = "oxygenengine/data",
    });
    b.installDirectory(.{
        .source_dir = b.path("Oxygen/sonic3air/data"),
        .install_dir = .{ .custom = devtree_dir },
        .install_subdir = "bin/data",
    });
    // the exe chdirs to its own folder and loads engine data from "../oxygenengine/"
    //   - Oxygen/sonic3air/source/sonic3air/main.cpp:68
    //   - Oxygen/oxygenengine/source/oxygen/application/EngineMain.cpp:560
    // but i'd rather keep everything neatly in one place under "dev/", hence "dev/bin/"
    b.getInstallStep().dependOn(&b.addInstallFile(
        exe.getEmittedBin(),
        b.fmt("{s}/bin/{s}", .{ devtree_dir, exe_name }),
    ).step);

    const run_cmd = b.addSystemCommand(&.{b.fmt("./{s}", .{exe_name})});
    run_cmd.setCwd(b.path(b.fmt("zig-out/{s}/bin", .{devtree_dir})));
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();

    const run_step = b.step("run", "Run the dev build");
    run_step.dependOn(&run_cmd.step);

    // ---- data run ----
    // runs the staged executable to rebuild the packs, compiled scripts and the nativized code

    const data_cmd = b.addSystemCommand(
        &.{ b.fmt("./{s}", .{exe_name}), "-pack", "-nativize", "-dumpcppdefinitions" },
    );
    data_cmd.setCwd(b.path(b.fmt("zig-out/{s}/bin", .{devtree_dir})));
    data_cmd.step.dependOn(b.getInstallStep());

    // commit-worthy products go back into the source tree
    const source_merge = b.addUpdateSourceFiles();
    source_merge.addCopyFileToSource(
        // -dumpcppfunctions
        b.path(b.fmt("zig-out/{s}/bin/scripts/_reference/cpp_core_functions.lemon", .{devtree_dir})),
        "Oxygen/sonic3air/scripts/_reference/cpp_core_functions.lemon",
    );
    source_merge.addCopyFileToSource(
        // -nativize
        b.path(b.fmt("zig-out/{s}/bin/source/sonic3air/_nativized/NativizedCode.inc", .{devtree_dir})),
        "Oxygen/sonic3air/source/sonic3air/_nativized/NativizedCode.inc",
    );
    source_merge.addCopyFileToSource(
        // -pack
        b.path(b.fmt("zig-out/{s}/bin/data/metadata.json", .{devtree_dir})),
        "Oxygen/sonic3air/data/metadata.json",
    );
    source_merge.step.dependOn(&data_cmd.step);

    const data_step = b.step("data", "Rebuild packs, compiled scripts and the nativized code");
    data_step.dependOn(&data_cmd.step);
    data_step.dependOn(&source_merge.step);

    // ---- release tree ----
    // files and packed data that make up the release bundle

    const dist_step = b.step("dist", "Stage the release bundle");

    // oxygenengine
    const oxygenapp = b.addInstallArtifact(
        b.dependency("oxygenengine", .{
            .target = target,
            .optimize = optimize,
        }).artifact("oxygenapp"),
        .{
            .dest_dir = .{ .override = .{ .custom = b.fmt("{s}/bonus/oxygenengine", .{release_dir}) } },
            .dest_sub_path = b.fmt("oxygenapp_{s}", .{@tagName(target.result.os.tag)}),
        },
    );

    const engine_template = b.addInstallDirectory(.{
        .source_dir = b.path("Oxygen/oxygenengine/_master_image_template"),
        .install_dir = .{ .custom = release_dir },
        .install_subdir = "bonus/oxygenengine",
    });

    const engine_data = b.addInstallDirectory(.{
        .source_dir = b.path("Oxygen/oxygenengine/data"),
        .install_dir = .{ .custom = release_dir },
        .install_subdir = "bonus/oxygenengine/data",
    });

    const run_oxygenapp_cmd = b.addSystemCommand(&.{
        b.fmt("./oxygenapp_{s}", .{@tagName(target.result.os.tag)}),
    });
    run_oxygenapp_cmd.setCwd(b.path(b.fmt("zig-out/{s}/bonus/oxygenengine", .{release_dir})));
    run_oxygenapp_cmd.step.dependOn(&oxygenapp.step);
    run_oxygenapp_cmd.step.dependOn(&engine_template.step);
    run_oxygenapp_cmd.step.dependOn(&engine_data.step);

    const run_oxygenapp_step = b.step("run-oxygenapp", "Run the staged Oxygen App");
    run_oxygenapp_step.dependOn(&run_oxygenapp_cmd.step);

    // final executable
    const release_exe = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = release_dir } },
        .dest_sub_path = exe_name,
    });

    const template = b.addInstallDirectory(.{
        .source_dir = b.path("Oxygen/sonic3air/_master_image_template"),
        .install_dir = .{ .custom = release_dir },
        .install_subdir = "",
        .exclude_extensions = if (target.result.os.tag != .linux) &.{".sh"} else &.{},
    });

    const icon = b.addInstallFile(
        b.path("Oxygen/sonic3air/data/images/icon.png"),
        b.fmt("{s}/data/icon.png", .{release_dir}),
    );

    const dev_scripts = b.addInstallDirectory(.{
        .source_dir = b.path("Oxygen/sonic3air/scripts"),
        .install_dir = .{ .custom = release_dir },
        .install_subdir = "bonus/sonic3air_dev/scripts",
    });

    // the data run's outputs live beside the dev tree
    const audiodata = b.addInstallFile(
        b.path(b.fmt("zig-out/{s}/bin/audiodata.bin", .{devtree_dir})),
        b.fmt("{s}/data/audiodata.bin", .{release_dir}),
    );
    const enginedata = b.addInstallFile(
        b.path(b.fmt("zig-out/{s}/bin/enginedata.bin", .{devtree_dir})),
        b.fmt("{s}/data/enginedata.bin", .{release_dir}),
    );
    const gamedata = b.addInstallFile(
        b.path(b.fmt("zig-out/{s}/bin/gamedata.bin", .{devtree_dir})),
        b.fmt("{s}/data/gamedata.bin", .{release_dir}),
    );
    const scripts = b.addInstallFile(
        b.path(b.fmt("zig-out/{s}/bin/saves/scripts.bin", .{devtree_dir})),
        b.fmt("{s}/data/scripts.bin", .{release_dir}),
    );
    const metadata = b.addInstallFile(
        b.path(b.fmt("zig-out/{s}/bin/data/metadata.json", .{devtree_dir})),
        b.fmt("{s}/data/metadata.json", .{release_dir}),
    );

    audiodata.step.dependOn(&data_cmd.step);
    enginedata.step.dependOn(&data_cmd.step);
    gamedata.step.dependOn(&data_cmd.step);
    scripts.step.dependOn(&data_cmd.step);
    metadata.step.dependOn(&data_cmd.step);

    // archiving
    const archive_cmd = b.addSystemCommand(
        &.{ "tar", "-czf", "sonic3air_game.tar.gz", "sonic3air_game" },
    );
    archive_cmd.setCwd(b.path(b.fmt("zig-out/{s}", .{arch_os})));

    const members = [_]*std.Build.Step{
        &oxygenapp.step,
        &engine_template.step,
        &engine_data.step,

        &release_exe.step,
        &template.step,
        &icon.step,
        &dev_scripts.step,
        &audiodata.step,
        &enginedata.step,
        &gamedata.step,
        &scripts.step,
        &metadata.step,
    };
    for (members) |member| {
        dist_step.dependOn(member);
        archive_cmd.step.dependOn(member);
    }
    dist_step.dependOn(&archive_cmd.step);
}
