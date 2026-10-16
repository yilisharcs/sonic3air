const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const librmx_dep = b.dependency("librmx", .{
        .target = target,
        .optimize = optimize,
    });

    const lemonscript_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    lemonscript_mod.addIncludePath(librmx_dep.path("source"));
    lemonscript_mod.addIncludePath(b.path("source"));
    lemonscript_mod.addCSourceFiles(.{
        .root = b.path("source/lemon"),
        .files = &.{
            "compiler/Compiler.cpp",
            "compiler/LineNumberTranslation.cpp",
            "compiler/Node.cpp",
            "compiler/Operators.cpp",
            "compiler/Preprocessor.cpp",
            "compiler/Token.cpp",
            "compiler/TokenHelper.cpp",
            "compiler/TypeCasting.cpp",
            "compiler/backend/FunctionCompiler.cpp",
            "compiler/backend/OpcodeOptimization.cpp",
            "compiler/frontend/CompilerFrontend.cpp",
            "compiler/frontend/TokenProcessing.cpp",
            "compiler/parser/Parser.cpp",
            "compiler/parser/ParserHelper.cpp",
            "pch.cpp",
            "program/BaseType.cpp",
            "program/ConstantArray.cpp",
            "program/DataType.cpp",
            "program/Define.cpp",
            "program/GlobalsLookup.cpp",
            "program/Module.cpp",
            "program/ModuleSerializer.cpp",
            "program/Opcode.cpp",
            "program/Program.cpp",
            "program/SourceFileInfo.cpp",
            "program/StringRef.cpp",
            "program/function/Function.cpp",
            "program/function/FunctionWrapper.cpp",
            "program/function/NativeFunction.cpp",
            "program/function/ScriptFunction.cpp",
            "runtime/BuiltInFunctions.cpp",
            "runtime/ControlFlow.cpp",
            "runtime/OpcodeProcessor.cpp",
            "runtime/Runtime.cpp",
            "runtime/RuntimeFunction.cpp",
            "runtime/StandardLibrary.cpp",
            "runtime/provider/DefaultOpcodeProvider.cpp",
            "runtime/provider/NativizedOpcodeProvider.cpp",
            "runtime/provider/OptimizedOpcodeProvider.cpp",
            "translator/Nativizer.cpp",
            "translator/NativizerInternal.cpp",
            "translator/SourceCodeWriter.cpp",
            "translator/Translator.cpp",
            "utility/DataTypeHelper.cpp",
            "utility/FlyweightString.cpp",
            "utility/PragmaSplitter.cpp",
            "utility/StringFormatter.cpp",
            "utility/StringFormatterLegacy.cpp",
        },
    });
    lemonscript_mod.linkLibrary(librmx_dep.artifact("rmxbase"));
    const lemonscript = b.addLibrary(.{
        .name = "lemonscript",
        .linkage = .static,
        .root_module = lemonscript_mod,
    });
    b.installArtifact(lemonscript);
}
