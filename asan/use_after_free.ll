; ModuleID = 'use_after_free.cpp'
source_filename = "use_after_free.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@llvm.used = appending global [1 x i8*] [i8* bitcast (void ()* @asan.module_ctor to i8*)], section "llvm.metadata"
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 1, void ()* @asan.module_ctor, i8* null }]

; Function Attrs: mustprogress noinline optnone sanitize_address uwtable
define dso_local noundef i8* @_ZnamPKc(i64 noundef %0, i8* noundef %c) #0 {
entry:
  %.addr = alloca i64, align 8
  %c.addr = alloca i8*, align 8
  store i64 %0, i64* %.addr, align 8
  store i8* %c, i8** %c.addr, align 8
  %1 = load i8*, i8** %c.addr, align 8
  %call = call i32 (i8*, ...) @printf(i8* noundef %1)
  ret i8* inttoptr (i64 123 to i8*)
}

declare dso_local i32 @printf(i8* noundef, ...) #1

; Function Attrs: mustprogress noinline norecurse optnone sanitize_address uwtable
define dso_local noundef i32 @main(i32 noundef %argc, i8** noundef %argv) #2 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %array = alloca i32*, align 8
  store i32 0, i32* %retval, align 4
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %0 = load i8**, i8*** %argv.addr, align 8
  %arrayidx = getelementptr inbounds i8*, i8** %0, i64 0
  %1 = ptrtoint i8** %arrayidx to i64
  %2 = lshr i64 %1, 3
  %3 = add i64 %2, 2147450880
  %4 = inttoptr i64 %3 to i8*
  %5 = load i8, i8* %4, align 1
  %6 = icmp ne i8 %5, 0
  br i1 %6, label %7, label %8

7:                                                ; preds = %entry
  call void @__asan_report_load8(i64 %1) #6
  unreachable

8:                                                ; preds = %entry
  %9 = load i8*, i8** %arrayidx, align 8
  %call = call i32 (i8*, ...) @printf(i8* noundef %9)
  %10 = bitcast i32** %array to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %10) #7
  %11 = load i8**, i8*** %argv.addr, align 8
  %arrayidx1 = getelementptr inbounds i8*, i8** %11, i64 1
  %12 = ptrtoint i8** %arrayidx1 to i64
  %13 = lshr i64 %12, 3
  %14 = add i64 %13, 2147450880
  %15 = inttoptr i64 %14 to i8*
  %16 = load i8, i8* %15, align 1
  %17 = icmp ne i8 %16, 0
  br i1 %17, label %18, label %19

18:                                               ; preds = %8
  call void @__asan_report_load8(i64 %12) #6
  unreachable

19:                                               ; preds = %8
  %20 = load i8*, i8** %arrayidx1, align 8
  %call2 = call noundef i8* @_ZnamPKc(i64 noundef 400, i8* noundef %20)
  %21 = bitcast i8* %call2 to i32*
  store i32* %21, i32** %array, align 8
  %22 = load i32*, i32** %array, align 8
  %arrayidx3 = getelementptr inbounds i32, i32* %22, i64 99
  %23 = ptrtoint i32* %arrayidx3 to i64
  %24 = lshr i64 %23, 3
  %25 = add i64 %24, 2147450880
  %26 = inttoptr i64 %25 to i8*
  %27 = load i8, i8* %26, align 1
  %28 = icmp ne i8 %27, 0
  br i1 %28, label %29, label %35, !prof !4

29:                                               ; preds = %19
  %30 = and i64 %23, 7
  %31 = add i64 %30, 3
  %32 = trunc i64 %31 to i8
  %33 = icmp sge i8 %32, %27
  br i1 %33, label %34, label %35

34:                                               ; preds = %29
  call void @__asan_report_load4(i64 %23) #6
  unreachable

35:                                               ; preds = %29, %19
  %36 = load i32, i32* %arrayidx3, align 4
  %37 = bitcast i32** %array to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %37) #7
  ret i32 %36
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

declare void @__asan_report_load_n(i64, i64)

declare void @__asan_loadN(i64, i64)

declare void @__asan_report_load1(i64)

declare void @__asan_load1(i64)

declare void @__asan_report_load2(i64)

declare void @__asan_load2(i64)

declare void @__asan_report_load4(i64)

declare void @__asan_load4(i64)

declare void @__asan_report_load8(i64)

declare void @__asan_load8(i64)

declare void @__asan_report_load16(i64)

declare void @__asan_load16(i64)

declare void @__asan_report_store_n(i64, i64)

declare void @__asan_storeN(i64, i64)

declare void @__asan_report_store1(i64)

declare void @__asan_store1(i64)

declare void @__asan_report_store2(i64)

declare void @__asan_store2(i64)

declare void @__asan_report_store4(i64)

declare void @__asan_store4(i64)

declare void @__asan_report_store8(i64)

declare void @__asan_store8(i64)

declare void @__asan_report_store16(i64)

declare void @__asan_store16(i64)

declare void @__asan_report_exp_load_n(i64, i64, i32)

declare void @__asan_exp_loadN(i64, i64, i32)

declare void @__asan_report_exp_load1(i64, i32)

declare void @__asan_exp_load1(i64, i32)

declare void @__asan_report_exp_load2(i64, i32)

declare void @__asan_exp_load2(i64, i32)

declare void @__asan_report_exp_load4(i64, i32)

declare void @__asan_exp_load4(i64, i32)

declare void @__asan_report_exp_load8(i64, i32)

declare void @__asan_exp_load8(i64, i32)

declare void @__asan_report_exp_load16(i64, i32)

declare void @__asan_exp_load16(i64, i32)

declare void @__asan_report_exp_store_n(i64, i64, i32)

declare void @__asan_exp_storeN(i64, i64, i32)

declare void @__asan_report_exp_store1(i64, i32)

declare void @__asan_exp_store1(i64, i32)

declare void @__asan_report_exp_store2(i64, i32)

declare void @__asan_exp_store2(i64, i32)

declare void @__asan_report_exp_store4(i64, i32)

declare void @__asan_exp_store4(i64, i32)

declare void @__asan_report_exp_store8(i64, i32)

declare void @__asan_exp_store8(i64, i32)

declare void @__asan_report_exp_store16(i64, i32)

declare void @__asan_exp_store16(i64, i32)

declare i8* @__asan_memmove(i8*, i8*, i64)

declare i8* @__asan_memcpy(i8*, i8*, i64)

declare i8* @__asan_memset(i8*, i32, i64)

declare void @__asan_handle_no_return()

declare void @__sanitizer_ptr_cmp(i64, i64)

declare void @__sanitizer_ptr_sub(i64, i64)

; Function Attrs: nounwind readnone speculatable willreturn
declare i1 @llvm.amdgcn.is.shared(i8* nocapture) #4

; Function Attrs: nounwind readnone speculatable willreturn
declare i1 @llvm.amdgcn.is.private(i8* nocapture) #4

declare void @__asan_before_dynamic_init(i64)

declare void @__asan_after_dynamic_init()

declare void @__asan_register_globals(i64, i64)

declare void @__asan_unregister_globals(i64, i64)

declare void @__asan_register_image_globals(i64)

declare void @__asan_unregister_image_globals(i64)

declare void @__asan_register_elf_globals(i64, i64, i64)

declare void @__asan_unregister_elf_globals(i64, i64, i64)

declare void @__asan_init()

; Function Attrs: nounwind uwtable
define internal void @asan.module_ctor() #5 {
  call void @__asan_init()
  call void @__asan_version_mismatch_check_v8()
  ret void
}

declare void @__asan_version_mismatch_check_v8()

attributes #0 = { mustprogress noinline optnone sanitize_address uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { mustprogress noinline norecurse optnone sanitize_address uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { argmemonly nofree nosync nounwind willreturn }
attributes #4 = { nounwind readnone speculatable willreturn }
attributes #5 = { nounwind uwtable "frame-pointer"="all" }
attributes #6 = { nomerge }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 14.0.6 (https://github.com/iamkroot/llvm-project.git f2a6a44d49eaeb1004017c71ef62c470cb4b5ac6)"}
!4 = !{!"branch_weights", i32 1, i32 100000}
