CPPFLAGS := $(shell llvm-config --cxxflags) -fdebug-default-version=3 -g -fdebug-info-for-profiling -fno-omit-frame-pointer
LLVM_LIBS := $(shell llvm-config --system-libs --libs executionengine mcjit support instrumentation irreader passes target x86)
LLVM_LIBDIR := $(shell llvm-config --libdir)

manual_asan.o: manual_asan.cpp
	clang++ -fsanitize=address -fuse-ld=/usr/bin/mold $(CPPFLAGS) -L${LLVM_LIBDIR} -I/usr/local/include manual_asan.cpp ${LLVM_LIBS} -o manual_asan.o

manual_asan: manual_asan.o
	./manual_asan.o

use_after_free.o: use_after_free.cpp
	clang++ -shared-libsan -fsanitize=address -fno-omit-frame-pointer use_after_free.cpp -o use_after_free.o

use_after_free.ll: use_after_free.cpp
	clang++ -shared-libsan -fsanitize=address -fno-omit-frame-pointer -emit-llvm -S use_after_free.cpp -o use_after_free.ll

use_after_free_nosan.ll: use_after_free.cpp
	clang++ -fno-omit-frame-pointer -emit-llvm -S use_after_free.cpp -o use_after_free_nosan.ll

use_after_free_nosan.dbg.ll: use_after_free_nosan.ll
	clang++ -fno-omit-frame-pointer -g -emit-llvm -S use_after_free.cpp -o use_after_free_nosan.dbg.ll

no_err.ll: no_err.cpp
	clang++ -fno-omit-frame-pointer -g -emit-llvm -S no_err.cpp -o no_err.ll

no_err.o: no_err.cpp
	clang++ -shared-libsan -fsanitize=address -fno-omit-frame-pointer no_err.cpp -o no_err.o

no_err_autosan.ll: no_err.cpp
	clang++ -shared-libsan -g -fsanitize=address -fno-omit-frame-pointer -emit-llvm -S no_err.cpp -o no_err_autosan.ll
