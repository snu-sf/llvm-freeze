; Makes sure that seldag legalization works correctly for freeze instruction.
; RUN: llc -march=x86 < %s 2>&1 | FileCheck %s

; CHECK: movl    $303174162, %ecx 
; CHECK: movl    $875836468, %esi 
; CHECK: movl    $1448498774, %edx
; CHECK: movl    $2021161080, %eax
; CHECK: xorl    %esi, %eax
; CHECK: xorl    %ecx, %edx
; CHECK: popl    %esi
; CHECK: retl

define i64 @expand(i32 %x) {
  %y1 = freeze i64 1302123111658042420 ; 0x1212121234343434
  %y2 = freeze i64 6221254864647256184 ; 0x5656565678787878
  %t2 = xor i64 %y1, %y2
  ret i64 %t2
}

; CHECK: movw    $682, %cx
; CHECK: movw    $992, %ax
; CHECK: addl    %ecx, %eax
; CHECK: retl
define i10 @promote() {
  %a = freeze i10 682 ; 0x2AA
  %b = freeze i10 992 ; 0x3E0
  %res = add i10 %a, %b
  ret i10 %res
}
