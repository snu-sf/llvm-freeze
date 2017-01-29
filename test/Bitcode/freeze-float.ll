; RUN: not llvm-as %s -o /dev/null 2>&1 | FileCheck %s

; CHECK: freeze-float.ll:[[@LINE+2]]:15: error: cannot freeze non-integer type
define float @float(float %x) {
  %y = freeze float %x
  ret float %y
}
