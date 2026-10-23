const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // oxygen_netcore
    const oxygen_netcore_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    oxygen_netcore_mod.addIncludePath(b.path("source"));
    oxygen_netcore_mod.addCSourceFiles(.{
        .root = b.path("source/oxygen_netcore"),
        .files = &.{
            "network/ConnectionManager.cpp",
            "network/NetConnection.cpp",
            "network/RequestBase.cpp",
            "network/Sockets.cpp",
            "network/internal/CryptoFunctions.cpp",
            "network/internal/ReceivedPacketCache.cpp",
            "network/internal/SentPacketCache.cpp",
            "network/internal/WebSocketClient.cpp",
            "network/internal/WebSocketWrapper.cpp",
            "pch.cpp",
        },
    });

    const librmx_dep = b.dependency("librmx", .{
        .target = target,
        .optimize = optimize,
    });
    oxygen_netcore_mod.addIncludePath(librmx_dep.path("source"));
    oxygen_netcore_mod.linkLibrary(librmx_dep.artifact("rmxbase"));

    const oxygen_netcore = b.addLibrary(.{
        .name = "oxygen_netcore",
        .linkage = .static,
        .root_module = oxygen_netcore_mod,
    });
    b.installArtifact(oxygen_netcore);

    // oxygen_core
    const oxygen_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    oxygen_mod.addIncludePath(b.path("source"));
    oxygen_mod.addCSourceFiles(.{
        .root = b.path("source/oxygen"),
        .flags = &.{"-fno-sanitize=alignment"},
        .files = &.{
            "application/Application.cpp",
            "application/Configuration.cpp",
            "application/EngineMain.cpp",
            "application/GameLoader.cpp",
            "application/GameProfile.cpp",
            "application/audio/AudioCollection.cpp",
            "application/audio/AudioOutBase.cpp",
            "application/audio/AudioPlayer.cpp",
            "application/audio/AudioSourceBase.cpp",
            "application/audio/AudioSourceManager.cpp",
            "application/audio/EmulationAudioSource.cpp",
            "application/audio/OggAudioSource.cpp",
            "application/gameview/GameView.cpp",
            "application/input/ControlsIn.cpp",
            "application/input/InputConfig.cpp",
            "application/input/InputManager.cpp",
            "application/input/InputRecorder.cpp",
            "application/input/RumbleEffectQueue.cpp",
            "application/menu/GameSetupScreen.cpp",
            "application/menu/MenuItems.cpp",
            "application/menu/OxygenMenu.cpp",
            "application/modding/Mod.cpp",
            "application/modding/ModManager.cpp",
            "application/overlays/BackdropView.cpp",
            "application/overlays/CheatSheetOverlay.cpp",
            "application/overlays/DebugLogView.cpp",
            "application/overlays/DebugSidePanel.cpp",
            "application/overlays/DebugSidePanelCategory.cpp",
            "application/overlays/MemoryHexView.cpp",
            "application/overlays/ProfilingView.cpp",
            "application/overlays/SaveStateMenu.cpp",
            "application/overlays/TouchControlsOverlay.cpp",
            "application/video/VideoOut.cpp",
            "download/DownloadManager.cpp",
            "download/Downloader.cpp",
            "drawing/DrawCollection.cpp",
            "drawing/DrawCommand.cpp",
            "drawing/Drawer.cpp",
            "drawing/DrawerTexture.cpp",
            "drawing/opengl/OpenGLDrawer.cpp",
            "drawing/opengl/OpenGLDrawerResources.cpp",
            "drawing/opengl/OpenGLDrawerTexture.cpp",
            "drawing/opengl/OpenGLSpriteTextureManager.cpp",
            "drawing/opengl/OpenGLTexture.cpp",
            "drawing/opengl/OpenGLUpscaler.cpp",
            "drawing/software/Blitter.cpp",
            "drawing/software/SoftwareDrawer.cpp",
            "drawing/software/SoftwareDrawerTexture.cpp",
            "drawing/software/SoftwareRasterizer.cpp",
            "file/FilePackage.cpp",
            "file/FileStructureTree.cpp",
            "file/PackedFileProvider.cpp",
            "file/ZipFileProvider.cpp",
            "helper/BitStream.cpp",
            "helper/FileHelper.cpp",
            "helper/HighResolutionTimer.cpp",
            "helper/JsonHelper.cpp",
            "helper/JsonSerializer.cpp",
            "helper/Logging.cpp",
            "helper/Profiling.cpp",
            "helper/RandomNumberGenerator.cpp",
            "helper/TextInputHandler.cpp",
            "helper/Transform2D.cpp",
            "helper/Utils.cpp",
            "menu/devmode/DevModeMainWindow.cpp",
            "menu/devmode/DevModeWindowBase.cpp",
            "menu/devmode/windows/AudioBrowserWindow.cpp",
            "menu/devmode/windows/CallFramesWindow.cpp",
            "menu/devmode/windows/CustomSidePanelWindow.cpp",
            "menu/devmode/windows/DebugLogWindow.cpp",
            "menu/devmode/windows/FileBrowserWindow.cpp",
            "menu/devmode/windows/GameSimWindow.cpp",
            "menu/devmode/windows/GameVisualizationsWindow.cpp",
            "menu/devmode/windows/MemoryHexViewWindow.cpp",
            "menu/devmode/windows/NetworkingWindow.cpp",
            "menu/devmode/windows/PaletteBrowserWindow.cpp",
            "menu/devmode/windows/PaletteViewWindow.cpp",
            "menu/devmode/windows/PersistentDataWindow.cpp",
            "menu/devmode/windows/RenderedGeometryWindow.cpp",
            "menu/devmode/windows/ScriptBuildWindow.cpp",
            "menu/devmode/windows/SettingsWindow.cpp",
            "menu/devmode/windows/SpriteBrowserWindow.cpp",
            "menu/devmode/windows/VRAMWritesWindow.cpp",
            "menu/devmode/windows/WatchesWindow.cpp",
            "menu/imgui/ImGuiExtensions.cpp",
            "menu/imgui/ImGuiHelpers.cpp",
            "menu/imgui/ImGuiIntegration.cpp",
            "menu/imgui/ImGuiManager.cpp",
            "menu/imgui/ImGuiSoftwareRenderer.cpp",
            "menu/imgui/implementations/ImGuiFileBrowser.cpp",
            "network/EngineServerClient.cpp",
            "network/netplay/ExternalAddressQuery.cpp",
            "network/netplay/NetplayClient.cpp",
            "network/netplay/NetplayHost.cpp",
            "network/netplay/NetplayManager.cpp",
            "pch.cpp",
            "platform/CrashHandler.cpp",
            "platform/PlatformFunctions.cpp",
            "platform/android/AndroidJNIHelper.cpp",
            "platform/android/AndroidJavaInterface.cpp",
            "rendering/Geometry.cpp",
            "rendering/RenderResources.cpp",
            "rendering/Renderer.cpp",
            "rendering/opengl/OpenGLRenderResources.cpp",
            "rendering/opengl/OpenGLRenderer.cpp",
            "rendering/opengl/shaders/DebugDrawPlaneShader.cpp",
            "rendering/opengl/shaders/OpenGLShader.cpp",
            "rendering/opengl/shaders/PostFXBlurShader.cpp",
            "rendering/opengl/shaders/RenderComponentSpriteShader.cpp",
            "rendering/opengl/shaders/RenderPaletteSpriteShader.cpp",
            "rendering/opengl/shaders/RenderPlaneShader.cpp",
            "rendering/opengl/shaders/RenderVdpSpriteShader.cpp",
            "rendering/opengl/shaders/SimpleCopyScreenShader.cpp",
            "rendering/opengl/shaders/SimpleRectColoredShader.cpp",
            "rendering/opengl/shaders/SimpleRectIndexedShader.cpp",
            "rendering/opengl/shaders/SimpleRectOverdrawShader.cpp",
            "rendering/opengl/shaders/SimpleRectTexturedShader.cpp",
            "rendering/opengl/shaders/SimpleRectTexturedUVShader.cpp",
            "rendering/opengl/shaders/SimpleRectVertexColorShader.cpp",
            "rendering/parts/PatternManager.cpp",
            "rendering/parts/PlaneManager.cpp",
            "rendering/parts/RenderItem.cpp",
            "rendering/parts/RenderParts.cpp",
            "rendering/parts/ScrollOffsetsManager.cpp",
            "rendering/parts/SpriteManager.cpp",
            "rendering/parts/palette/Palette.cpp",
            "rendering/parts/palette/PaletteManager.cpp",
            "rendering/software/SoftwareRenderer.cpp",
            "rendering/sprite/ComponentSprite.cpp",
            "rendering/sprite/PaletteSprite.cpp",
            "rendering/sprite/SpriteDump.cpp",
            "rendering/utils/BufferTexture.cpp",
            "rendering/utils/Kosinski.cpp",
            "rendering/utils/RenderUtils.cpp",
            "resources/FontCollection.cpp",
            "resources/PaletteCollection.cpp",
            "resources/PrintedTextCache.cpp",
            "resources/RawDataCollection.cpp",
            "resources/ResourcesCache.cpp",
            "resources/SpriteCollection.cpp",
            "simulation/CodeExec.cpp",
            "simulation/EmulatorInterface.cpp",
            "simulation/GameRecorder.cpp",
            "simulation/LemonScriptProgram.cpp",
            "simulation/LemonScriptRuntime.cpp",
            "simulation/LogDisplay.cpp",
            "simulation/PersistentData.cpp",
            "simulation/SaveStateSerializer.cpp",
            "simulation/Simulation.cpp",
            "simulation/SimulationState.cpp",
            "simulation/analyse/ROMDataAnalyser.cpp",
            "simulation/bindings/LemonScriptBindings.cpp",
            "simulation/bindings/RendererBindings.cpp",
            "simulation/debug/DebugTracking.cpp",
            "simulation/sound/SoundDriver.cpp",
            "simulation/sound/SoundEmulation.cpp",
            "simulation/sound/blip_buf.cpp",
            "simulation/sound/sn76489.cpp",
            "simulation/sound/ym2612.cpp",
        },
    });

    oxygen_mod.linkLibrary(oxygen_netcore);

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });
    oxygen_mod.linkLibrary(zlib_dep.artifact("z"));
    oxygen_mod.addIncludePath(zlib_dep.path("contrib/minizip"));
    oxygen_mod.addCSourceFiles(.{
        .root = zlib_dep.path("contrib/minizip"),
        .files = &.{
            "ioapi.c",
            "unzip.c",
        },
    });

    const imgui_dep = b.dependency("imgui", .{
        .target = target,
        .optimize = optimize,
    });
    oxygen_mod.linkLibrary(imgui_dep.artifact("imgui"));
    oxygen_mod.addCMacro("USE_IMGUI", "1");

    oxygen_mod.addIncludePath(librmx_dep.path("source"));
    oxygen_mod.linkLibrary(librmx_dep.artifact("rmxmedia"));
    oxygen_mod.linkLibrary(librmx_dep.artifact("rmxext_oggvorbis"));

    const lemonscript_dep = b.dependency("lemonscript", .{
        .target = target,
        .optimize = optimize,
    });
    oxygen_mod.addIncludePath(lemonscript_dep.path("source"));
    oxygen_mod.linkLibrary(lemonscript_dep.artifact("lemonscript"));

    switch (target.result.os.tag) {
        .linux => oxygen_mod.linkSystemLibrary("curl", .{}),
        else => {},
    }

    const oxygen = b.addLibrary(.{
        .name = "oxygen",
        .linkage = .static,
        .root_module = oxygen_mod,
    });
    b.installArtifact(oxygen);
    oxygen.installLibraryHeaders(librmx_dep.artifact("rmxmedia"));
    oxygen.installLibraryHeaders(librmx_dep.artifact("rmxext_oggvorbis"));

    // oxygen_app
    const engineapp_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
        .strip = optimize != .debug,
    });
    engineapp_mod.addIncludePath(b.path("source"));
    engineapp_mod.addCSourceFiles(.{
        .root = b.path("source/engineapp"),
        .files = &.{
            "ConfigurationImpl.cpp",
            "EngineDelegate.cpp",
            "GameApp.cpp",
            "audio/AudioOut.cpp",
            "experiments/Experiments.cpp",
            "main.cpp",
        },
    });

    engineapp_mod.linkLibrary(oxygen);

    engineapp_mod.addIncludePath(librmx_dep.path("source"));
    engineapp_mod.addIncludePath(lemonscript_dep.path("source"));

    b.installArtifact(b.addExecutable(.{
        .name = "oxygenapp",
        .root_module = engineapp_mod,
    }));
}
