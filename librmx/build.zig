const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // rmxbase
    const rmxbase_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    rmxbase_mod.addIncludePath(b.path("source"));
    rmxbase_mod.addCSourceFiles(.{
        .root = b.path("source/rmxbase"),
        .flags = &.{"-fno-sanitize=alignment"},
        .files = &.{
            "_jsoncpp/json_reader.cpp",
            "_jsoncpp/json_value.cpp",
            "_jsoncpp/json_writer.cpp",
            "base/Basics.cpp",
            "base/ErrorHandler.cpp",
            "bitmap/Bitmap.cpp",
            "bitmap/BitmapCodecBMP.cpp",
            "bitmap/BitmapCodecICO.cpp",
            "bitmap/BitmapCodecJPG.cpp",
            "bitmap/BitmapCodecPNG.cpp",
            "bitmap/Color.cpp",
            "bitmap/PaletteBitmap.cpp",
            "data/WeakPtr.cpp",
            "file/FileCrawler.cpp",
            "file/FileHandle.cpp",
            "file/FileIO.cpp",
            "file/FileProvider.cpp",
            "file/FileSystem.cpp",
            "file/JsonHelper.cpp",
            "file/RealFileProvider.cpp",
            "math/Math.cpp",
            "memory/BinarySerializer.cpp",
            "memory/InputStream.cpp",
            "memory/OneTimeAllocPool.cpp",
            "memory/OutputStream.cpp",
            "memory/RC4Encryption.cpp",
            "memory/RmxDeflate.cpp",
            "memory/String.cpp",
            "memory/UTF8Conversion.cpp",
            "memory/UnalignedMemory.cpp",
            "memory/VectorBinarySerializer.cpp",
            "memory/ZlibDeflate.cpp",
            "rmxbase.cpp",
            "tools/Logging.cpp",
            "tools/Tools.cpp",
        },
    });

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });
    rmxbase_mod.linkLibrary(zlib_dep.artifact("z"));

    const rmxbase = b.addLibrary(.{
        .name = "rmxbase",
        .linkage = .static,
        .root_module = rmxbase_mod,
    });
    b.installArtifact(rmxbase);

    // rmxmedia
    const rmxmedia_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    rmxmedia_mod.addIncludePath(b.path("source"));
    rmxmedia_mod.addIncludePath(b.path("source/rmxmedia/_glew"));
    rmxmedia_mod.addCSourceFiles(.{
        .root = b.path("source/rmxmedia"),
        .files = &.{
            "audiovideo/AudioBuffer.cpp",
            "audiovideo/AudioManager.cpp",
            "audiovideo/AudioMixer.cpp",
            "audiovideo/AudioReference.cpp",
            "audiovideo/VideoBuffer.cpp",
            "file/FileInputStreamSDL.cpp",
            "file/FileProviderSDL.cpp",
            "font/Font.cpp",
            "font/FontProcessor.cpp",
            "font/FontSource.cpp",
            "framework/AppFramework.cpp",
            "framework/GuiBase.cpp",
            "framework/InputContext.cpp",
            "framework/SystemManager.cpp",
            "framework/VideoManager.cpp",
            "opengl/Framebuffer.cpp",
            "opengl/GLTools.cpp",
            "opengl/OpenGLFontOutput.cpp",
            "opengl/Painter.cpp",
            "opengl/Shader.cpp",
            "opengl/SpriteAtlas.cpp",
            "opengl/Texture.cpp",
            "opengl/VertexArrayObject.cpp",
            "rmxmedia.cpp",
            "threads/JobManager.cpp",
            "threads/Thread.cpp",
        },
    });
    rmxmedia_mod.addCSourceFiles(.{
        .root = b.path("source/rmxmedia/_glew"),
        .files = &.{"glew.c"},
        .flags = &.{"-DGLEW_NO_GLU"},
    });
    rmxmedia_mod.linkLibrary(rmxbase);

    const sdl_dep = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl2 = sdl_dep.artifact("SDL2");
    rmxmedia_mod.linkLibrary(sdl2);
    rmxmedia_mod.addIncludePath(sdl_dep.path("include"));
    rmxmedia_mod.addIncludePath(sdl_dep.path("include-pregen"));
    switch (target.result.os.tag) {
        .windows => rmxmedia_mod.linkSystemLibrary("opengl32", .{}),
        else => rmxmedia_mod.linkSystemLibrary("GL", .{}),
    }

    const rmxmedia = b.addLibrary(.{
        .name = "rmxmedia",
        .linkage = .static,
        .root_module = rmxmedia_mod,
    });
    b.installArtifact(rmxmedia);
    rmxmedia.installLibraryHeaders(sdl2);

    // rmxext
    const rmxext_oggvorbis_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    rmxext_oggvorbis_mod.addIncludePath(b.path("source"));
    rmxext_oggvorbis_mod.addCSourceFiles(.{
        .root = b.path("source/rmxext_oggvorbis"),
        .files = &.{
            "OggLoader.cpp",
            "rmxext_oggvorbis.cpp",
        },
    });
    rmxext_oggvorbis_mod.linkLibrary(rmxmedia);

    rmxext_oggvorbis_mod.linkLibrary(sdl2);

    const libogg_dep = b.dependency("libogg", .{
        .target = target,
        .optimize = optimize,
    });
    rmxext_oggvorbis_mod.linkLibrary(libogg_dep.artifact("ogg"));

    const libvorbis_dep = b.dependency("libvorbis", .{
        .target = target,
        .optimize = optimize,
    });
    rmxext_oggvorbis_mod.linkLibrary(libvorbis_dep.artifact("vorbis"));

    const rmxext_oggvorbis = b.addLibrary(.{
        .name = "rmxext_oggvorbis",
        .linkage = .static,
        .root_module = rmxext_oggvorbis_mod,
    });
    b.installArtifact(rmxext_oggvorbis);
    rmxext_oggvorbis.installLibraryHeaders(sdl2);
    rmxext_oggvorbis.installLibraryHeaders(libogg_dep.artifact("ogg"));
    rmxext_oggvorbis.installLibraryHeaders(libvorbis_dep.artifact("vorbis"));
}
