const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sonic3air_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
        .strip = optimize != .debug,
    });

    sonic3air_mod.addIncludePath(b.path("source"));
    sonic3air_mod.addIncludePath(b.path("source/external"));
    sonic3air_mod.addCSourceFiles(.{
        .root = b.path("source/sonic3air"),
        .flags = &.{"-fno-sanitize=alignment"},
        .files = &.{
            "ConfigurationImpl.cpp",
            "EngineDelegate.cpp",
            "Game.cpp",
            "_nativized/NativizedCode.cpp",
            "audio/AudioOut.cpp",
            "audio/CustomAudioMixer.cpp",
            "audio/RemasteredMusicDownload.cpp",
            "client/GameClient.cpp",
            "client/GhostSync.cpp",
            "client/UpdateCheck.cpp",
            "client/crowdcontrol/CrowdControlClient.cpp",
            "data/PlayerProgress.cpp",
            "data/PlayerRecorder.cpp",
            "data/SharedDatabase.cpp",
            "data/TimeAttackData.cpp",
            "generator/ResourceScriptGenerator.cpp",
            "helper/BlueSpheresRendering.cpp",
            "helper/CommandForwarder.cpp",
            "helper/DiscordIntegration.cpp",
            "helper/DrawingUtils.cpp",
            "helper/GameUtils.cpp",
            "helper/PackageBuilder.cpp",
            "main.cpp",
            "menu/ExtrasMenu.cpp",
            "menu/GameApp.cpp",
            "menu/GameMenuBase.cpp",
            "menu/GameMenuManager.cpp",
            "menu/MainMenu.cpp",
            "menu/MenuBackground.cpp",
            "menu/PauseMenu.cpp",
            "menu/SharedResources.cpp",
            "menu/TimeAttackMenu.cpp",
            "menu/TimeAttackResultsMenu.cpp",
            "menu/context/ApplicationContextMenu.cpp",
            "menu/entries/GeneralMenuEntries.cpp",
            "menu/helper/GameMenuControlsDisplay.cpp",
            "menu/helper/GameMenuScrolling.cpp",
            "menu/mods/ModsMenu.cpp",
            "menu/mods/ModsMenuEntries.cpp",
            "menu/mods/ModsStartPage.cpp",
            "menu/options/ControllerSetupMenu.cpp",
            "menu/options/OptionsConfig.cpp",
            "menu/options/OptionsEntry.cpp",
            "menu/options/OptionsMenu.cpp",
            "menu/options/OptionsMenuEntries.cpp",
            "menu/overlays/SecretUnlockedWindow.cpp",
            "menu/overlays/SkippableCutsceneWindow.cpp",
            "pch.cpp",
            "platform/PlatformSpecifics.cpp",
            "resources/DynamicSprites.cpp",
            "scriptimpl/ScriptImplementations.cpp",
        },
    });

    const librmx_dep = b.dependency("librmx", .{
        .target = target,
        .optimize = optimize,
    });
    sonic3air_mod.addIncludePath(librmx_dep.path("source"));

    const lemonscript_dep = b.dependency("lemonscript", .{
        .target = target,
        .optimize = optimize,
    });
    sonic3air_mod.addIncludePath(lemonscript_dep.path("source"));

    const oxygenengine_dep = b.dependency("oxygenengine", .{
        .target = target,
        .optimize = optimize,
    });
    sonic3air_mod.addIncludePath(oxygenengine_dep.path("source"));

    sonic3air_mod.linkLibrary(oxygenengine_dep.artifact("oxygen"));

    b.installArtifact(b.addExecutable(.{
        .name = "sonic3air",
        .root_module = sonic3air_mod,
    }));
}
