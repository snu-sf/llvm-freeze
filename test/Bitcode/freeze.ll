; RUN: llvm-as < %s | llvm-dis | FileCheck %s

define i32 @f(i32 %x) {
  %y = freeze i32 %x
  ret i32 %y
}

; CHECK:      define i32 @f(i32 %x) {
; CHECK-NEXT:   %y = freeze i32 %x
; CHECK-NEXT:   ret i32 %y
; CHECK-NEXT: }
