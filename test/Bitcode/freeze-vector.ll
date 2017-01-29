; RUN: not llvm-as %s -o /dev/null 2>&1 | FileCheck %s

; CHECK: freeze-vector.ll:[[@LINE+2]]:15: error: cannot freeze non-integer type
define <2 x i32> @vec(<2 x i32> %x) {
  %y = freeze <2 x i32> %x
  ret <2 x i32> %y
}
