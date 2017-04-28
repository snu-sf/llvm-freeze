; RUN: opt < %s -instcombine -S | FileCheck --match-full-lines %s

define i32 @f(i32 %x) {
; CHECK: %y = freeze i32 %x
; CHECK-NEXT: ret i32 %y
  %y = freeze i32 %x
  %z = freeze i32 %y
  ret i32 %z
}

define i32 @make_const() {
; CHECK: ret i32 10
  %x = freeze i32 10
  ret i32 %x
}
