#include <llvm/CodeGen/AsmPrinter.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/JITEventListener.h>
#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/ExecutionEngine/RTDyldMemoryManager.h>
#include <llvm/ExecutionEngine/RuntimeDyld.h>
#include <llvm/ExecutionEngine/SectionMemoryManager.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Object/Archive.h>
#include <llvm/Object/ELF.h>
#include <llvm/Object/ELFObjectFile.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/SourceMgr.h>

// #include "weld.h"

using namespace llvm;

int main(int argc, char const *argv[]) {
    LLVMInitializeNativeAsmPrinter();
    LLVMInitializeNativeAsmParser();
    LLVMInitializeNativeTarget();

    llvm::LLVMContext ctx{};
    SMDiagnostic err;

    auto llvm_code = "pi.test.ll";
    bool is_weld = llvm::StringRef{llvm_code}.startswith("code");
    bool is_pi = llvm::StringRef{llvm_code}.startswith("pi");

    auto buf = cantFail(errorOrToExpected(MemoryBuffer::getFile(llvm_code)));
    auto mod = parseIR(buf->getMemBufferRef(), err, ctx);
    if (!err.getMessage().empty()) {
        llvm::outs() << "err " << err.getMessage() << " at line " << err.getLineNo() << "\n";
        return 1;
    }
    if (verifyModule(*mod, &llvm::outs())) {
        return 2;
    }
    llvm::outs() << mod->getSourceFileName() << "\n";
    EngineBuilder builder{std::move(mod)};
    std::string err2;
    builder.setErrorStr(&err2);
    // builder.setUseOrcMCJITReplacement(false);
    builder.setEngineKind(EngineKind::JIT);
    auto tm = builder.selectTarget();
    auto eng = builder.create();
    if (!err2.empty()) {
        llvm::errs() << err2;
        return 3;
    }

    auto load_static_ar = [](auto path) {
        auto buf = cantFail(errorOrToExpected(MemoryBuffer::getFile(path)));
        auto ar = cantFail(object::Archive::create(buf->getMemBufferRef()));
        return llvm::object::OwningBinary<object::Archive>{std::move(ar), std::move(buf)};
    };
    auto load_shared_lib = [](auto path) {
        auto buf = cantFail(errorOrToExpected(MemoryBuffer::getFile(path)));
        auto ar = cantFail(object::ObjectFile::createELFObjectFile(buf->getMemBufferRef()));
        return llvm::object::OwningBinary<object::ObjectFile>{std::move(ar), std::move(buf)};
    };

    auto lis = JITEventListener::createPerfJITEventListener();
    assert(lis);
    eng->RegisterJITEventListener(lis);
    llvm::outs() << "Registered listener\n";

    eng->finalizeObject();
    printf("finalized\n");
    if (eng->hasError()) {
        llvm::errs() << eng->getErrorMessage() << "\n";
        return 4;
    }
    int res = 1;
    if (is_pi) {
        auto addr = eng->getFunctionAddress("pi2");
        assert(addr && "pi fn not found");
        using F = double (*)(uint64_t);
        auto pif = reinterpret_cast<F>(addr);
        auto r = (*pif)(10000000);
        llvm::outs() << "pi " << r << "\n";
        res = 0;
    } else if (!is_weld) {
        auto addr = eng->getFunctionAddress("main");
        assert(addr && "main not found");
        using F = int (*)(int, const char *[]);
        auto mainf = reinterpret_cast<F>(addr);
        const char *n[] = {"", "10000000"};
        res = (*mainf)(2, n);
    }

    return res;
}
