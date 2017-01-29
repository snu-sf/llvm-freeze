; RUN: not llvm-as %s -o /dev/null 2>&1 | FileCheck %s

; CHECK: freeze-pointer.ll:[[@LINE+2]]:15: error: cannot freeze non-integer type
define i32* @ptr(i32* %x) {
  %y = freeze i32* %x
  ret i32* %y
}
