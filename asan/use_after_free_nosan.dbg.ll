; ModuleID = 'use_after_free.cpp'
source_filename = "use_after_free.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress noinline optnone uwtable
define dso_local noundef i8* @_ZnamPKc(i64 noundef %0, i8* noundef %1) #0 !dbg !208 {
  %3 = alloca i64, align 8
  %4 = alloca i8*, align 8
  store i64 %0, i64* %3, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !212, metadata !DIExpression()), !dbg !213
  store i8* %1, i8** %4, align 8
  call void @llvm.dbg.declare(metadata i8** %4, metadata !214, metadata !DIExpression()), !dbg !215
  %5 = load i8*, i8** %4, align 8, !dbg !216
  %6 = call i32 (i8*, ...) @printf(i8* noundef %5), !dbg !217
  ret i8* inttoptr (i64 123 to i8*), !dbg !218
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare dso_local i32 @printf(i8* noundef, ...) #2

; Function Attrs: mustprogress noinline norecurse optnone uwtable
define dso_local noundef i32 @main(i32 noundef %0, i8** noundef %1) #3 !dbg !219 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca i32*, align 8
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !223, metadata !DIExpression()), !dbg !224
  store i8** %1, i8*** %5, align 8
  call void @llvm.dbg.declare(metadata i8*** %5, metadata !225, metadata !DIExpression()), !dbg !226
  %7 = load i8**, i8*** %5, align 8, !dbg !227
  %8 = getelementptr inbounds i8*, i8** %7, i64 1, !dbg !227
  %9 = load i8*, i8** %8, align 8, !dbg !227
  %10 = call i32 (i8*, ...) @printf(i8* noundef %9), !dbg !228
  call void @llvm.dbg.declare(metadata i32** %6, metadata !229, metadata !DIExpression()), !dbg !231
  %11 = load i8**, i8*** %5, align 8, !dbg !232
  %12 = getelementptr inbounds i8*, i8** %11, i64 1, !dbg !232
  %13 = load i8*, i8** %12, align 8, !dbg !232
  %14 = call noundef i8* @_ZnamPKc(i64 noundef 400, i8* noundef %13), !dbg !233, !heapallocsite !27
  %15 = bitcast i8* %14 to i32*, !dbg !233
  store i32* %15, i32** %6, align 8, !dbg !231
  %16 = load i32*, i32** %6, align 8, !dbg !234
  %17 = getelementptr inbounds i32, i32* %16, i64 5, !dbg !234
  %18 = load i32, i32* %17, align 4, !dbg !234
  ret i32 %18, !dbg !235
}

attributes #0 = { mustprogress noinline optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!202, !203, !204, !205, !206}
!llvm.ident = !{!207}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 14.0.6 (https://github.com/iamkroot/llvm-project.git f2a6a44d49eaeb1004017c71ef62c470cb4b5ac6)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !2, imports: !4, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "use_after_free.cpp", directory: "/home/krut/llvm-project/asan", checksumkind: CSK_MD5, checksum: "c07ff10037808c1e75dc98cce062c5d8")
!2 = !{!3}
!3 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!4 = !{!5, !12, !18, !23, !28, !30, !32, !34, !36, !43, !50, !57, !61, !65, !69, !77, !81, !83, !88, !94, !98, !105, !107, !111, !115, !119, !121, !125, !129, !131, !135, !137, !139, !143, !147, !151, !155, !159, !163, !165, !172, !176, !180, !185, !187, !189, !193, !197, !198, !199, !200, !201}
!5 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !7, file: !11, line: 98)
!6 = !DINamespace(name: "std", scope: null)
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !8, line: 7, baseType: !9)
!8 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/FILE.h", directory: "", checksumkind: CSK_MD5, checksum: "571f9fb6223c42439075fdde11a0de5d")
!9 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !10, line: 49, size: 1728, flags: DIFlagFwdDecl, identifier: "_ZTS8_IO_FILE")
!10 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h", directory: "", checksumkind: CSK_MD5, checksum: "1bad07471b7974df4ecc1d1c2ca207e6")
!11 = !DIFile(filename: "/usr/lib/gcc/x86_64-linux-gnu/12/../../../../include/c++/12/cstdio", directory: "")
!12 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !13, file: !11, line: 99)
!13 = !DIDerivedType(tag: DW_TAG_typedef, name: "fpos_t", file: !14, line: 84, baseType: !15)
!14 = !DIFile(filename: "/usr/include/stdio.h", directory: "", checksumkind: CSK_MD5, checksum: "f31eefcc3f15835fc5a4023a625cf609")
!15 = !DIDerivedType(tag: DW_TAG_typedef, name: "__fpos_t", file: !16, line: 14, baseType: !17)
!16 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__fpos_t.h", directory: "", checksumkind: CSK_MD5, checksum: "32de8bdaf3551a6c0a9394f9af4389ce")
!17 = !DICompositeType(tag: DW_TAG_structure_type, name: "_G_fpos_t", file: !16, line: 10, size: 128, flags: DIFlagFwdDecl, identifier: "_ZTS9_G_fpos_t")
!18 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !19, file: !11, line: 101)
!19 = !DISubprogram(name: "clearerr", scope: !14, file: !14, line: 786, type: !20, flags: DIFlagPrototyped, spFlags: 0)
!20 = !DISubroutineType(types: !21)
!21 = !{null, !22}
!22 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !7, size: 64)
!23 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !24, file: !11, line: 102)
!24 = !DISubprogram(name: "fclose", scope: !14, file: !14, line: 178, type: !25, flags: DIFlagPrototyped, spFlags: 0)
!25 = !DISubroutineType(types: !26)
!26 = !{!27, !22}
!27 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!28 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !29, file: !11, line: 103)
!29 = !DISubprogram(name: "feof", scope: !14, file: !14, line: 788, type: !25, flags: DIFlagPrototyped, spFlags: 0)
!30 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !31, file: !11, line: 104)
!31 = !DISubprogram(name: "ferror", scope: !14, file: !14, line: 790, type: !25, flags: DIFlagPrototyped, spFlags: 0)
!32 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !33, file: !11, line: 105)
!33 = !DISubprogram(name: "fflush", scope: !14, file: !14, line: 230, type: !25, flags: DIFlagPrototyped, spFlags: 0)
!34 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !35, file: !11, line: 106)
!35 = !DISubprogram(name: "fgetc", scope: !14, file: !14, line: 513, type: !25, flags: DIFlagPrototyped, spFlags: 0)
!36 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !37, file: !11, line: 107)
!37 = !DISubprogram(name: "fgetpos", scope: !14, file: !14, line: 760, type: !38, flags: DIFlagPrototyped, spFlags: 0)
!38 = !DISubroutineType(types: !39)
!39 = !{!27, !40, !41}
!40 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !22)
!41 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !42)
!42 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!43 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !44, file: !11, line: 108)
!44 = !DISubprogram(name: "fgets", scope: !14, file: !14, line: 592, type: !45, flags: DIFlagPrototyped, spFlags: 0)
!45 = !DISubroutineType(types: !46)
!46 = !{!47, !49, !27, !40}
!47 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !48, size: 64)
!48 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!49 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !47)
!50 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !51, file: !11, line: 109)
!51 = !DISubprogram(name: "fopen", scope: !14, file: !14, line: 258, type: !52, flags: DIFlagPrototyped, spFlags: 0)
!52 = !DISubroutineType(types: !53)
!53 = !{!22, !54, !54}
!54 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !55)
!55 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !56, size: 64)
!56 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !48)
!57 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !58, file: !11, line: 110)
!58 = !DISubprogram(name: "fprintf", scope: !14, file: !14, line: 350, type: !59, flags: DIFlagPrototyped, spFlags: 0)
!59 = !DISubroutineType(types: !60)
!60 = !{!27, !40, !54, null}
!61 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !62, file: !11, line: 111)
!62 = !DISubprogram(name: "fputc", scope: !14, file: !14, line: 549, type: !63, flags: DIFlagPrototyped, spFlags: 0)
!63 = !DISubroutineType(types: !64)
!64 = !{!27, !27, !22}
!65 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !66, file: !11, line: 112)
!66 = !DISubprogram(name: "fputs", scope: !14, file: !14, line: 655, type: !67, flags: DIFlagPrototyped, spFlags: 0)
!67 = !DISubroutineType(types: !68)
!68 = !{!27, !54, !40}
!69 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !70, file: !11, line: 113)
!70 = !DISubprogram(name: "fread", scope: !14, file: !14, line: 675, type: !71, flags: DIFlagPrototyped, spFlags: 0)
!71 = !DISubroutineType(types: !72)
!72 = !{!73, !76, !73, !73, !40}
!73 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !74, line: 46, baseType: !75)
!74 = !DIFile(filename: "/usr/local/lib/clang/14.0.6/include/stddef.h", directory: "", checksumkind: CSK_MD5, checksum: "2499dd2361b915724b073282bea3a7bc")
!75 = !DIBasicType(name: "unsigned long", size: 64, encoding: DW_ATE_unsigned)
!76 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3)
!77 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !78, file: !11, line: 114)
!78 = !DISubprogram(name: "freopen", scope: !14, file: !14, line: 265, type: !79, flags: DIFlagPrototyped, spFlags: 0)
!79 = !DISubroutineType(types: !80)
!80 = !{!22, !54, !54, !40}
!81 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !82, file: !11, line: 115)
!82 = !DISubprogram(name: "fscanf", linkageName: "__isoc99_fscanf", scope: !14, file: !14, line: 434, type: !59, flags: DIFlagPrototyped, spFlags: 0)
!83 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !84, file: !11, line: 116)
!84 = !DISubprogram(name: "fseek", scope: !14, file: !14, line: 713, type: !85, flags: DIFlagPrototyped, spFlags: 0)
!85 = !DISubroutineType(types: !86)
!86 = !{!27, !22, !87, !27}
!87 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!88 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !89, file: !11, line: 117)
!89 = !DISubprogram(name: "fsetpos", scope: !14, file: !14, line: 765, type: !90, flags: DIFlagPrototyped, spFlags: 0)
!90 = !DISubroutineType(types: !91)
!91 = !{!27, !22, !92}
!92 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !93, size: 64)
!93 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !13)
!94 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !95, file: !11, line: 118)
!95 = !DISubprogram(name: "ftell", scope: !14, file: !14, line: 718, type: !96, flags: DIFlagPrototyped, spFlags: 0)
!96 = !DISubroutineType(types: !97)
!97 = !{!87, !22}
!98 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !99, file: !11, line: 119)
!99 = !DISubprogram(name: "fwrite", scope: !14, file: !14, line: 681, type: !100, flags: DIFlagPrototyped, spFlags: 0)
!100 = !DISubroutineType(types: !101)
!101 = !{!73, !102, !73, !73, !40}
!102 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !103)
!103 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !104, size: 64)
!104 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!105 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !106, file: !11, line: 120)
!106 = !DISubprogram(name: "getc", scope: !14, file: !14, line: 514, type: !25, flags: DIFlagPrototyped, spFlags: 0)
!107 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !108, file: !11, line: 121)
!108 = !DISubprogram(name: "getchar", scope: !14, file: !14, line: 520, type: !109, flags: DIFlagPrototyped, spFlags: 0)
!109 = !DISubroutineType(types: !110)
!110 = !{!27}
!111 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !112, file: !11, line: 126)
!112 = !DISubprogram(name: "perror", scope: !14, file: !14, line: 804, type: !113, flags: DIFlagPrototyped, spFlags: 0)
!113 = !DISubroutineType(types: !114)
!114 = !{null, !55}
!115 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !116, file: !11, line: 127)
!116 = !DISubprogram(name: "printf", scope: !14, file: !14, line: 356, type: !117, flags: DIFlagPrototyped, spFlags: 0)
!117 = !DISubroutineType(types: !118)
!118 = !{!27, !54, null}
!119 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !120, file: !11, line: 128)
!120 = !DISubprogram(name: "putc", scope: !14, file: !14, line: 550, type: !63, flags: DIFlagPrototyped, spFlags: 0)
!121 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !122, file: !11, line: 129)
!122 = !DISubprogram(name: "putchar", scope: !14, file: !14, line: 556, type: !123, flags: DIFlagPrototyped, spFlags: 0)
!123 = !DISubroutineType(types: !124)
!124 = !{!27, !27}
!125 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !126, file: !11, line: 130)
!126 = !DISubprogram(name: "puts", scope: !14, file: !14, line: 661, type: !127, flags: DIFlagPrototyped, spFlags: 0)
!127 = !DISubroutineType(types: !128)
!128 = !{!27, !55}
!129 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !130, file: !11, line: 131)
!130 = !DISubprogram(name: "remove", scope: !14, file: !14, line: 152, type: !127, flags: DIFlagPrototyped, spFlags: 0)
!131 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !132, file: !11, line: 132)
!132 = !DISubprogram(name: "rename", scope: !14, file: !14, line: 154, type: !133, flags: DIFlagPrototyped, spFlags: 0)
!133 = !DISubroutineType(types: !134)
!134 = !{!27, !55, !55}
!135 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !136, file: !11, line: 133)
!136 = !DISubprogram(name: "rewind", scope: !14, file: !14, line: 723, type: !20, flags: DIFlagPrototyped, spFlags: 0)
!137 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !138, file: !11, line: 134)
!138 = !DISubprogram(name: "scanf", linkageName: "__isoc99_scanf", scope: !14, file: !14, line: 437, type: !117, flags: DIFlagPrototyped, spFlags: 0)
!139 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !140, file: !11, line: 135)
!140 = !DISubprogram(name: "setbuf", scope: !14, file: !14, line: 328, type: !141, flags: DIFlagPrototyped, spFlags: 0)
!141 = !DISubroutineType(types: !142)
!142 = !{null, !40, !49}
!143 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !144, file: !11, line: 136)
!144 = !DISubprogram(name: "setvbuf", scope: !14, file: !14, line: 332, type: !145, flags: DIFlagPrototyped, spFlags: 0)
!145 = !DISubroutineType(types: !146)
!146 = !{!27, !40, !49, !27, !73}
!147 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !148, file: !11, line: 137)
!148 = !DISubprogram(name: "sprintf", scope: !14, file: !14, line: 358, type: !149, flags: DIFlagPrototyped, spFlags: 0)
!149 = !DISubroutineType(types: !150)
!150 = !{!27, !49, !54, null}
!151 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !152, file: !11, line: 138)
!152 = !DISubprogram(name: "sscanf", linkageName: "__isoc99_sscanf", scope: !14, file: !14, line: 439, type: !153, flags: DIFlagPrototyped, spFlags: 0)
!153 = !DISubroutineType(types: !154)
!154 = !{!27, !54, !54, null}
!155 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !156, file: !11, line: 139)
!156 = !DISubprogram(name: "tmpfile", scope: !14, file: !14, line: 188, type: !157, flags: DIFlagPrototyped, spFlags: 0)
!157 = !DISubroutineType(types: !158)
!158 = !{!22}
!159 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !160, file: !11, line: 141)
!160 = !DISubprogram(name: "tmpnam", scope: !14, file: !14, line: 205, type: !161, flags: DIFlagPrototyped, spFlags: 0)
!161 = !DISubroutineType(types: !162)
!162 = !{!47, !47}
!163 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !164, file: !11, line: 143)
!164 = !DISubprogram(name: "ungetc", scope: !14, file: !14, line: 668, type: !63, flags: DIFlagPrototyped, spFlags: 0)
!165 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !166, file: !11, line: 144)
!166 = !DISubprogram(name: "vfprintf", scope: !14, file: !14, line: 365, type: !167, flags: DIFlagPrototyped, spFlags: 0)
!167 = !DISubroutineType(types: !168)
!168 = !{!27, !40, !54, !169}
!169 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !170, size: 64)
!170 = !DICompositeType(tag: DW_TAG_structure_type, name: "__va_list_tag", file: !171, size: 192, flags: DIFlagFwdDecl, identifier: "_ZTS13__va_list_tag")
!171 = !DIFile(filename: "use_after_free.cpp", directory: "/home/krut/llvm-project/asan")
!172 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !173, file: !11, line: 145)
!173 = !DISubprogram(name: "vprintf", scope: !14, file: !14, line: 371, type: !174, flags: DIFlagPrototyped, spFlags: 0)
!174 = !DISubroutineType(types: !175)
!175 = !{!27, !54, !169}
!176 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !177, file: !11, line: 146)
!177 = !DISubprogram(name: "vsprintf", scope: !14, file: !14, line: 373, type: !178, flags: DIFlagPrototyped, spFlags: 0)
!178 = !DISubroutineType(types: !179)
!179 = !{!27, !49, !54, !169}
!180 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !181, entity: !182, file: !11, line: 175)
!181 = !DINamespace(name: "__gnu_cxx", scope: null)
!182 = !DISubprogram(name: "snprintf", scope: !14, file: !14, line: 378, type: !183, flags: DIFlagPrototyped, spFlags: 0)
!183 = !DISubroutineType(types: !184)
!184 = !{!27, !49, !73, !54, null}
!185 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !181, entity: !186, file: !11, line: 176)
!186 = !DISubprogram(name: "vfscanf", linkageName: "__isoc99_vfscanf", scope: !14, file: !14, line: 479, type: !167, flags: DIFlagPrototyped, spFlags: 0)
!187 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !181, entity: !188, file: !11, line: 177)
!188 = !DISubprogram(name: "vscanf", linkageName: "__isoc99_vscanf", scope: !14, file: !14, line: 484, type: !174, flags: DIFlagPrototyped, spFlags: 0)
!189 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !181, entity: !190, file: !11, line: 178)
!190 = !DISubprogram(name: "vsnprintf", scope: !14, file: !14, line: 382, type: !191, flags: DIFlagPrototyped, spFlags: 0)
!191 = !DISubroutineType(types: !192)
!192 = !{!27, !49, !73, !54, !169}
!193 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !181, entity: !194, file: !11, line: 179)
!194 = !DISubprogram(name: "vsscanf", linkageName: "__isoc99_vsscanf", scope: !14, file: !14, line: 487, type: !195, flags: DIFlagPrototyped, spFlags: 0)
!195 = !DISubroutineType(types: !196)
!196 = !{!27, !54, !54, !169}
!197 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !182, file: !11, line: 185)
!198 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !186, file: !11, line: 186)
!199 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !188, file: !11, line: 187)
!200 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !190, file: !11, line: 188)
!201 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !194, file: !11, line: 189)
!202 = !{i32 7, !"Dwarf Version", i32 5}
!203 = !{i32 2, !"Debug Info Version", i32 3}
!204 = !{i32 1, !"wchar_size", i32 4}
!205 = !{i32 7, !"uwtable", i32 1}
!206 = !{i32 7, !"frame-pointer", i32 2}
!207 = !{!"clang version 14.0.6 (https://github.com/iamkroot/llvm-project.git f2a6a44d49eaeb1004017c71ef62c470cb4b5ac6)"}
!208 = distinct !DISubprogram(name: "operator new[]", linkageName: "_ZnamPKc", scope: !1, file: !1, line: 2, type: !209, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !211)
!209 = !DISubroutineType(types: !210)
!210 = !{!3, !75, !55}
!211 = !{}
!212 = !DILocalVariable(arg: 1, scope: !208, file: !1, line: 2, type: !75)
!213 = !DILocation(line: 2, column: 35, scope: !208)
!214 = !DILocalVariable(name: "c", arg: 2, scope: !208, file: !1, line: 2, type: !55)
!215 = !DILocation(line: 2, column: 49, scope: !208)
!216 = !DILocation(line: 3, column: 12, scope: !208)
!217 = !DILocation(line: 3, column: 5, scope: !208)
!218 = !DILocation(line: 4, column: 5, scope: !208)
!219 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 7, type: !220, scopeLine: 7, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !211)
!220 = !DISubroutineType(types: !221)
!221 = !{!27, !27, !222}
!222 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !47, size: 64)
!223 = !DILocalVariable(name: "argc", arg: 1, scope: !219, file: !1, line: 7, type: !27)
!224 = !DILocation(line: 7, column: 14, scope: !219)
!225 = !DILocalVariable(name: "argv", arg: 2, scope: !219, file: !1, line: 7, type: !222)
!226 = !DILocation(line: 7, column: 26, scope: !219)
!227 = !DILocation(line: 8, column: 12, scope: !219)
!228 = !DILocation(line: 8, column: 5, scope: !219)
!229 = !DILocalVariable(name: "array", scope: !219, file: !1, line: 10, type: !230)
!230 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !27, size: 64)
!231 = !DILocation(line: 10, column: 10, scope: !219)
!232 = !DILocation(line: 10, column: 22, scope: !219)
!233 = !DILocation(line: 10, column: 18, scope: !219)
!234 = !DILocation(line: 14, column: 12, scope: !219)
!235 = !DILocation(line: 14, column: 5, scope: !219)
