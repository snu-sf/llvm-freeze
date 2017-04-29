; 6 test cases which must introduce a freeze instruction after loop unswitch
; RUN: opt < %s -loop-simplify -loop-rotate -loop-unswitch -S | FileCheck %s

@x = common global i32 0, align 4
define i32 @emptyf()  {
entry:
  ret i32 0
}
declare i32 @g(i32) 
declare i32 @h(i32) 

; int f_freeze1(int a, int b){
;   int sum = 0;
;   for(int i = 0; i < a; i++){
;     g(0);
;     if(b == 0){
;       sum += g(i);
;     }
;     sum++;
;   }
;   return sum;
; }

; CHECK: define i32 @f_freeze1(i32 %a, i32 %b) {
define i32 @f_freeze1(i32 %a, i32 %b)  {
entry:
  br label %for.cond

; CHECK:       %cmp1 = icmp eq i32 %b, 0
; CHECK-NEXT:  %cmp1.fr = freeze i1 %cmp1
; CHECK-NEXT:  br i1 %cmp1.fr, label %for.body.lr.ph.split.us, label %for.body.lr.ph.for.body.lr.ph.split_crit_edge

for.cond:                                         ; preds = %for.inc, %entry
  %sum.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc3, %for.inc ]
  %cmp = icmp slt i32 %i.0, %a
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %call = call i32 @g(i32 0)
  %cmp1 = icmp eq i32 %b, 0
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %call2 = call i32 @g(i32 %i.0)
  %add = add nsw i32 %sum.0, %call2
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %sum.1 = phi i32 [ %add, %if.then ], [ %sum.0, %for.body ]
  %inc = add nsw i32 %sum.1, 1
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc3 = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret i32 %sum.0
}

; int f_freeze2(int a, int b){
;   int sum = 0;
;   for(int i = 0; i < a; i++){
;     g(0);
;     if(b == 0){
;       sum += g(i);
;     }else{
;       sum += h(i);
;     }
;   }
;   return sum;
; }

; CHECK: define i32 @f_freeze2(i32 %a, i32 %b) {
define i32 @f_freeze2(i32 %a, i32 %b)  {
entry:
  br label %for.cond

; CHECK:       %cmp1 = icmp eq i32 %b, 0
; CHECK-NEXT:  %cmp1.fr = freeze i1 %cmp1
; CHECK-NEXT:  br i1 %cmp1.fr, label %for.body.lr.ph.split.us, label %for.body.lr.ph.for.body.lr.ph.split_crit_edge

for.cond:                                         ; preds = %for.inc, %entry
  %sum.0 = phi i32 [ 0, %entry ], [ %sum.1, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, %a
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %call = call i32 @g(i32 0)
  %cmp1 = icmp eq i32 %b, 0
  br i1 %cmp1, label %if.then, label %if.else

if.then:                                          ; preds = %for.body
  %call2 = call i32 @g(i32 %i.0)
  %add = add nsw i32 %sum.0, %call2
  br label %if.end

if.else:                                          ; preds = %for.body
  %call3 = call i32 @h(i32 %i.0)
  %add4 = add nsw i32 %sum.0, %call3
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %sum.1 = phi i32 [ %add, %if.then ], [ %add4, %if.else ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret i32 %sum.0
}


; int f_freeze3(int a, int b){
;   int sum = 0;
;   for(int i = 0; i < a; i++){
;     if(x == 0) {
;       emptyf();
;     }
;     // Unswitching the below branch
;     if(b == 0){
;       sum += g(i);
;     }
;     sum++;
;   }
;   return sum;
; }

; CHECK: define i32 @f_freeze3(i32 %a, i32 %b) {
define i32 @f_freeze3(i32 %a, i32 %b)  {
entry:
  br label %for.cond

; CHECK:       %cmp2 = icmp eq i32 %b, 0
; CHECK-NEXT:  %cmp2.fr = freeze i1 %cmp2
; CHECK-NEXT:  br i1 %cmp2.fr, label %for.body.lr.ph.split.us, label %for.body.lr.ph.for.body.lr.ph.split_crit_edge

for.cond:                                         ; preds = %for.inc, %entry
  %sum.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc6, %for.inc ]
  %cmp = icmp slt i32 %i.0, %a
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %0 = load i32, i32* @x, align 4
  %cmp1 = icmp eq i32 %0, 0
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %call = call i32 @emptyf()
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %cmp2 = icmp eq i32 %b, 0
  br i1 %cmp2, label %if.then3, label %if.end5

if.then3:                                         ; preds = %if.end
  %call4 = call i32 @g(i32 %i.0)
  %add = add nsw i32 %sum.0, %call4
  br label %if.end5

if.end5:                                          ; preds = %if.then3, %if.end
  %sum.1 = phi i32 [ %add, %if.then3 ], [ %sum.0, %if.end ]
  %inc = add nsw i32 %sum.1, 1
  br label %for.inc

for.inc:                                          ; preds = %if.end5
  %inc6 = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret i32 %sum.0
}

; int f_freeze4(int a, int b){
;   int sum = 0;
;   for(int i = 0; i < a; i++){
;     if(x == 0) {
;       emptyf();
;     }
;     // Unswitching the below branch
;     if(b == 0){
;       sum += g(i);
;     }else{
;       sum += h(i);
;     }
;   }
;   return sum;
; }

; CHECK: define i32 @f_freeze4(i32 %a, i32 %b) {
define i32 @f_freeze4(i32 %a, i32 %b)  {
entry:
  br label %for.cond

; CHECK:       %cmp2 = icmp eq i32 %b, 0
; CHECK-NEXT:  %cmp2.fr = freeze i1 %cmp2
; CHECK-NEXT:  br i1 %cmp2.fr, label %for.body.lr.ph.split.us, label %for.body.lr.ph.for.body.lr.ph.split_crit_edge

for.cond:                                         ; preds = %for.inc, %entry
  %sum.0 = phi i32 [ 0, %entry ], [ %sum.1, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, %a
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %0 = load i32, i32* @x, align 4
  %cmp1 = icmp eq i32 %0, 0
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %call = call i32 @emptyf()
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %cmp2 = icmp eq i32 %b, 0
  br i1 %cmp2, label %if.then3, label %if.else

if.then3:                                         ; preds = %if.end
  %call4 = call i32 @g(i32 %i.0)
  %add = add nsw i32 %sum.0, %call4
  br label %if.end7

if.else:                                          ; preds = %if.end
  %call5 = call i32 @h(i32 %i.0)
  %add6 = add nsw i32 %sum.0, %call5
  br label %if.end7

if.end7:                                          ; preds = %if.else, %if.then3
  %sum.1 = phi i32 [ %add, %if.then3 ], [ %add6, %if.else ]
  br label %for.inc

for.inc:                                          ; preds = %if.end7
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret i32 %sum.0
}

; int f_freeze5(int a, int b){
;   int sum = 0;
;   for(int i = 0; i < a; i++){
;     sum++;
;     if(b == 0){
;       sum += g(i);
;     }
;   }
;   return sum;
; }

; CHECK: define i32 @f_freeze5(i32 %a, i32 %b) {
define i32 @f_freeze5(i32 %a, i32 %b)  {
entry:
  br label %for.cond

; CHECK: %cmp1 = icmp eq i32 %b, 0
; CHECK-NEXT: %cmp1.fr = freeze i1 %cmp1
; CHECK-NEXT: br i1 %cmp1.fr, label %for.body.lr.ph.split.us, label %for.body.lr.ph.for.body.lr.ph.split_crit_edge

for.cond:                                         ; preds = %for.inc, %entry
  %sum.0 = phi i32 [ 0, %entry ], [ %sum.1, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc2, %for.inc ]
  %cmp = icmp slt i32 %i.0, %a
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %inc = add nsw i32 %sum.0, 1
  %cmp1 = icmp eq i32 %b, 0
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %call = call i32 @g(i32 %i.0)
  %add = add nsw i32 %inc, %call
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %sum.1 = phi i32 [ %add, %if.then ], [ %inc, %for.body ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc2 = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret i32 %sum.0
}

; int f_freeze6(int a, int b){
;   int sum = 0;
;   for(int i = 0; i < a; i++){
;     sum++;
;     if(b == 0){
;       sum += g(i);
;     }else{
;       sum += h(i);
;     }
;   }
;   return sum;
; }

; CHECK: define i32 @f_freeze6(i32 %a, i32 %b) {
define i32 @f_freeze6(i32 %a, i32 %b)  {
entry:
  br label %for.cond

; CHECK: %cmp1 = icmp eq i32 %b, 0
; CHECK-NEXT: %cmp1.fr = freeze i1 %cmp1
; CHECK-NEXT: br i1 %cmp1.fr, label %for.body.lr.ph.split.us, label %for.body.lr.ph.for.body.lr.ph.split_crit_edge

for.cond:                                         ; preds = %for.inc, %entry
  %sum.0 = phi i32 [ 0, %entry ], [ %sum.1, %for.inc ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc4, %for.inc ]
  %cmp = icmp slt i32 %i.0, %a
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %inc = add nsw i32 %sum.0, 1
  %cmp1 = icmp eq i32 %b, 0
  br i1 %cmp1, label %if.then, label %if.else

if.then:                                          ; preds = %for.body
  %call = call i32 @g(i32 %i.0)
  %add = add nsw i32 %inc, %call
  br label %if.end

if.else:                                          ; preds = %for.body
  %call2 = call i32 @h(i32 %i.0)
  %add3 = add nsw i32 %inc, %call2
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %sum.1 = phi i32 [ %add, %if.then ], [ %add3, %if.else ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc4 = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret i32 %sum.0
}
