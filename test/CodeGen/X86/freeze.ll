; RUN: llc -mtriple=x86_64-unknown-linux-gnu -print-machineinstrs=expand-isel-pseudos %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=MCINSTR
; RUN: llc -mtriple=x86_64-unknown-linux-gnu < %s 2>&1 | FileCheck %s --check-prefix=X86ASM

; X86ASM: imull   %eax, %eax
; X86ASM: xorl    %eax, %eax
; X86ASM: retq

; MCINSTR: %vreg1<def> = IMPLICIT_DEF; GR32:%vreg1
; MCINSTR: %vreg2<def,tied1> = IMUL32rr %vreg1<tied0>, %vreg1, %EFLAGS<imp-def,dead>; GR32:%vreg2,%vreg1,%vreg1
; MCINSTR: %vreg3<def,tied1> = XOR32rr %vreg2<tied0>, %vreg1, %EFLAGS<imp-def,dead>; GR32:%vreg3,%vreg2,%vreg1
; MCINSTR: %EAX<def> = COPY %vreg3; GR32:%vreg3
; MCINSTR: RET 0, %EAX

define i32 @foo(i32 %x) {
  %y1 = freeze i32 undef
  %t1 = mul i32 %y1, %y1
  %t2 = xor i32 %t1, %y1
  ret i32 %t2
}
