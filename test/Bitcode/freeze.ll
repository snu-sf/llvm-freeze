; RUN: llvm-as < %s | llvm-dis > %t.orig
; RUN: llvm-as < %s | llvm-c-test --echo > %t.echo
; RUN: diff -w %t.orig %t.echo

define i32 @f(i32 %arg) {
  %1 = freeze i32 %arg
  %2 = freeze i32 10
  %3 = freeze i32 %1
  ret i32 %1
}
