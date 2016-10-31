//===- InstCombineFreeze.cpp ----------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the visitFreeze function.
//
//===----------------------------------------------------------------------===//

#include "InstCombineInternal.h"
#include "llvm/Analysis/InstructionSimplify.h"
using namespace llvm;
using namespace PatternMatch;

#define DEBUG_TYPE "instcombine"

Instruction *InstCombiner::visitFreeze(FreezeInst &FI) {
  Value *Op0 = FI.getOperand(0);

  if (Value *V = SimplifyFreezeInst(Op0, DL, TLI, DT, AC))
    return replaceInstUsesWith(FI, V);

  if (FreezeInst *Op0_FI = dyn_cast<FreezeInst>(Op0))
    return replaceInstUsesWith(FI, Op0_FI);

  return nullptr;
}
