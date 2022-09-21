#include <clang/Basic/CodeGenOptions.h>
#include <llvm-c/Core.h>
#include <llvm-c/Initialization.h>
#include <llvm-c/Target.h>
#include <llvm-c/Transforms/PassManagerBuilder.h>
#include <llvm/CodeGen/AsmPrinter.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/ExecutionEngine/RTDyldMemoryManager.h>
#include <llvm/ExecutionEngine/SectionMemoryManager.h>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/IR/Verifier.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Object/Archive.h>
#include <llvm/Object/ELF.h>
#include <llvm/Object/ELFObjectFile.h>
#include <llvm/Pass.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/Transforms/IPO/PassManagerBuilder.h>
#include <llvm/Transforms/Instrumentation/AddressSanitizer.h>

using namespace llvm;
uintptr_t asan_globals_start = 0;
uintptr_t asan_globals_end = 0;
ExecutionEngine *eng;
// In case the execution needs TLS storage, we define a very small TLS memory
// area here that will be used in allocateTLSSection().

extern "C" {
alignas(16) __attribute__((visibility("hidden"), tls_model("initial-exec"),
                           used)) thread_local char LLVMRTDyldTLSSpace[1024];
}

class MyMCJITMemoryManager : public SectionMemoryManager {
   private:
    unsigned UsedTLSStorage = 0;

   public:
    struct Alloc {
        uint8_t *bytes;
        uintptr_t size;
        llvm::StringRef name;
    };
    static llvm::SmallVector<Alloc, 4> mem_allocs;
    static llvm::SmallVector<Alloc, 8> data_allocs;
    static std::unique_ptr<MyMCJITMemoryManager> Create() {
        return std::make_unique<MyMCJITMemoryManager>();
    }

    MyMCJITMemoryManager() : SectionMemoryManager{} {}

    // Allocate a memory block of (at least) the given size suitable for
    // executable code. The section_id is a unique identifier assigned by the
    // MCJIT engine, and optionally recorded by the memory manager to access a
    // loaded section.
    uint8_t *allocateCodeSection(uintptr_t size, unsigned alignment, unsigned section_id,
                                 llvm::StringRef section_name) override {
        auto *res =
            SectionMemoryManager::allocateCodeSection(size, alignment, section_id, section_name);
        llvm::outs() << "MEM " << format_hex((uint64_t)res, 1) << " " << size << " " << section_id
                     << " " << section_name << "\n";

        // printf("%p\n", res);
        return res;
    };

    // Allocate a memory block of (at least) the given size suitable for data.
    // The SectionID is a unique identifier assigned by the JIT engine, and
    // optionally recorded by the memory manager to access a loaded section.
    uint8_t *allocateDataSection(uintptr_t size, unsigned alignment, unsigned section_id,
                                 llvm::StringRef section_name, bool is_readonly) override {
        auto *res = SectionMemoryManager::allocateDataSection(size, alignment, section_id,
                                                              section_name, is_readonly);
        llvm::outs() << "DAT " << format_hex((uint64_t)res, 1) << " " << size << " " << section_id
                     << " " << section_name << "\n";
        if (section_name == "asan_globals") {
            asan_globals_start = reinterpret_cast<uintptr_t>(res);
            asan_globals_end = reinterpret_cast<uintptr_t>(res + size);
            eng->addGlobalMapping("__start_asan_globals", (uint64_t)asan_globals_start);
            eng->addGlobalMapping("__stop_asan_globals", (uint64_t)asan_globals_end);
        }
        return res;
    }
    // bool finalizeMemory(std::string *ErrMsg = nullptr) override {
    //     return SectionMemoryManager::finalizeMemory;
    // }

    TLSSection allocateTLSSection(uintptr_t size, unsigned alignment, unsigned section_id,
                                  StringRef section_name) override {
        llvm::outs() << "TLS " << size << " " << alignment << " " << section_id << " "
                     << section_name << " "
                     << "\n";
        if (size + UsedTLSStorage > sizeof(LLVMRTDyldTLSSpace)) {
            llvm::outs() << "not enough mem " << UsedTLSStorage << " " << sizeof(LLVMRTDyldTLSSpace)
                         << "\n";
            return {};
        }

        // Get the offset of the TLSSpace in the TLS block by using a tpoff
        // relocation here.
        int64_t TLSOffset;
        asm("leaq LLVMRTDyldTLSSpace@tpoff, %0" : "=r"(TLSOffset));

        TLSSection Section;
        // We use the storage directly as the initialization image. This means that
        // when a new thread is spawned after this allocation, it will not be
        // initialized correctly. This means, llvm-rtdyld will only support TLS in a
        // single thread.
        Section.InitializationImage =
            reinterpret_cast<uint8_t *>(LLVMRTDyldTLSSpace + UsedTLSStorage);
        Section.Offset = TLSOffset + UsedTLSStorage;
        llvm::outs() << "offset " << format_hex(TLSOffset, 1) << " init "
                     << format_hex((uint64_t)LLVMRTDyldTLSSpace, 1) << "\n";

        UsedTLSStorage += size;

        return Section;
    }
};

SmallVector<MyMCJITMemoryManager::Alloc, 4> MyMCJITMemoryManager::mem_allocs{};
SmallVector<MyMCJITMemoryManager::Alloc, 8> MyMCJITMemoryManager::data_allocs{};

void mallochook(const volatile void *ptr, size_t size) {}
void freehook(const volatile void *ptr, size_t size) {}

void gmonstart(void) {}

int main(int argc, char const *argv[]) {
    LLVMInitializeNativeAsmPrinter();
    LLVMInitializeNativeAsmParser();
    LLVMInitializeNativeTarget();

    LLVMInitializeX86TargetInfo();

    auto registry = LLVMGetGlobalPassRegistry();
    LLVMInitializeCore(registry);
    LLVMInitializeAnalysis(registry);
    LLVMInitializeCodeGen(registry);
    LLVMInitializeIPA(registry);
    LLVMInitializeIPO(registry);
    LLVMInitializeInstrumentation(registry);
    LLVMInitializeScalarOpts(registry);
    LLVMInitializeTarget(registry);
    LLVMInitializeTransformUtils(registry);
    LLVMInitializeVectorization(registry);
    // auto file = "no_err.ll";
    // auto file = "no_err.ll";
    // auto dumpfile = "no_err_manualsan.ll";
    auto file = "use_after_free_nosan.dbg.ll";
    auto dumpfile = "use_after_free_manualsan.ll";

    llvm::LLVMContext ctx{};
    SMDiagnostic err;
    auto buf = cantFail(errorOrToExpected(MemoryBuffer::getFile(file)));
    auto mod = parseIR(buf->getMemBufferRef(), err, ctx);
    if (!err.getMessage().empty()) {
        llvm::outs() << "err " << err.getMessage() << " at line " << err.getLineNo() << "\n";
        return 1;
    }
    if (verifyModule(*mod, &llvm::outs())) {
        return 2;
    }
    llvm::outs() << mod->getSourceFileName() << "\n";
    llvm::PassManagerBuilder b{};
    b.OptLevel = 0;

    auto module = mod.release();

    auto addAsanPasses = [](const PassManagerBuilder &Builder, legacy::PassManagerBase &PM) {
        PM.add(createAddressSanitizerFunctionPass());
        PM.add(createModuleAddressSanitizerLegacyPassPass());
    };
    b.addExtension(PassManagerBuilder::ExtensionPointTy::EP_OptimizerLast, addAsanPasses);
    b.addExtension(PassManagerBuilder::ExtensionPointTy::EP_EnabledOnOptLevel0, addAsanPasses);
    llvm::legacy::FunctionPassManager fpm{module};
    llvm::legacy::PassManager mpm;
    // auto asanfuncpass = llvm::createAddressSanitizerFunctionPass();
    // fpm.add(asanfuncpass);
    // auto asanpass = llvm::createModuleAddressSanitizerLegacyPassPass();
    // mpm.add(asanpass);
    b.populateFunctionPassManager(fpm);
    b.populateModulePassManager(mpm);
    // asanpass->runOnModule(*mod);
    outs() << "Added asan\n";
    fpm.doInitialization();
    for (auto &F : *module) {
        if (F.isDeclaration()) continue;
        outs() << "running asan on " << F.getName() << "\n";
        F.addFnAttr(llvm::Attribute::SanitizeAddress);
        fpm.run(F);
    }
    fpm.doFinalization();

    auto main_func = module->getFunction("main");
    // main_func->addAttribute(!0, llvm::Attribute::SanitizeAddress);

    // module->getNamedMetadata("llvm.asan.globals");
    // module->getOrInsertNamedMetadata("llvm.asan.globals");

    outs() << "running asan on module\n";
    mpm.run(*module);
    outs() << "Ran asan\n";
    {
        auto asan_ctor = module->getFunction("asan.module_ctor");
        auto &entry = asan_ctor->getEntryBlock();
        // move the "ret void" to the new bb
        auto newbb = entry.splitBasicBlock(&entry.back());
        entry.eraseFromParent();
    }
    // asan_ctor
    std::error_code EC;
    llvm::raw_fd_ostream outf{dumpfile, EC, sys::fs::OpenFlags::OF_Text};
    module->print(outf, nullptr, false, true);

    std::unique_ptr<Module> Mod;
    Mod.reset(module);
    EngineBuilder builder{std::move(Mod)};
    std::string err2;
    builder.setErrorStr(&err2);
    // builder.setUseOrcMCJITReplacement(false);
    builder.setEngineKind(EngineKind::JIT);
    auto tm = builder.selectTarget();
    builder.setMCJITMemoryManager(MyMCJITMemoryManager::Create());
    eng = builder.create();
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

    // auto sh1 =
    // load_shared_lib("/usr/local/lib/clang/14.0.6/lib/linux/libclang_rt.asan-x86_64.so");
    // eng->addObjectFile(std::move(sh1));
    // auto sh2 = load_shared_lib("/usr/lib/x86_64-linux-gnu/libitm.so.1");
    // eng->addObjectFile(std::move(sh2));

    // auto st1 = load_static_ar("/usr/lib/x86_64-linux-gnu/libitm.so.1");
    // eng->addArchive(std::move(st1));

    // auto ar3 =
    //     load_static_ar("/usr/local/lib/clang/11.1.0/lib/linux/libclang_rt.asan-preinit-x86_64.a");
    // eng->addArchive(std::move(ar3));
    // auto ar1 = load_static_ar("/usr/local/lib/clang/11.1.0/lib/linux/libclang_rt.asan-x86_64.a");
    // eng->addArchive(std::move(ar1));
    // auto ar2 =
    //     load_static_ar("/usr/local/lib/clang/11.1.0/lib/linux/libclang_rt.asan_cxx-x86_64.a");
    // eng->addArchive(std::move(ar2));
    // eng->addGlobalMapping("_ITM_deregisterTMCloneTable", 1);
    // eng->addGlobalMapping("_ITM_registerTMCloneTable", 1);
    // eng->addGlobalMapping("__gmon_start__", (uint64_t)(gmonstart));
    // // eng->addGlobalMapping("__gmon_end__", 1);
    // eng->addGlobalMapping("__lsan_default_options", 1);
    // eng->addGlobalMapping("__lsan_default_suppressions", 1);
    // eng->addGlobalMapping("__lsan_is_turned_off", 1);
    // eng->addGlobalMapping("__sanitizer_malloc_hook", (uint64_t)(mallochook));
    // eng->addGlobalMapping("__sanitizer_free_hook", (uint64_t)(freehook));
    // eng->addGlobalMapping("printf", (uint64_t)(&printf));

    eng->finalizeObject();
    printf("finalized\n");
    if (eng->hasError()) {
        llvm::errs() << eng->getErrorMessage() << "\n";
        return 4;
    }
    printf("running constructors\n");
    eng->runStaticConstructorsDestructors(false);
    printf("getting main\n");
    auto addr = eng->getFunctionAddress("main");
    assert(addr && "main not found");
    outs() << "Running from main at " << llvm::format_hex(addr, 10) << "\n";
    using F = int (*)(int, const char *[]);
    auto mainf = reinterpret_cast<F>(addr);
    const char *n[] = {"starting\n\0", "dummy\n", "alloc array %p\n\0", "deleted array\n\0"};
    auto i = (*mainf)(3, n);
    outs() << "Returned " << i << "\n";
}
