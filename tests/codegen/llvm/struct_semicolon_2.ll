; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf-pc-linux"

%stack_t = type { i64, i32, i32 }
%printf_t = type { i64, [16 x i8] }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64 %0, i64 %1) #0

define i64 @"kprobe:f"(i8* %0) section "s_kprobe:f_1" {
entry:
  %key = alloca i32, align 4
  %stack_args = alloca %stack_t, align 8
  %printf_args = alloca %printf_t, align 8
  %1 = bitcast %printf_t* %printf_args to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  %2 = bitcast %printf_t* %printf_args to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %2, i8 0, i64 24, i1 false)
  %3 = getelementptr %printf_t, %printf_t* %printf_args, i32 0, i32 0
  store i64 0, i64* %3, align 8
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 0)
  %get_stackid = call i64 inttoptr (i64 27 to i64 (i8*, i64, i64)*)(i8* %0, i64 %pseudo, i64 256)
  %4 = bitcast %stack_t* %stack_args to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %4)
  %5 = getelementptr %stack_t, %stack_t* %stack_args, i64 0, i32 0
  store i64 %get_stackid, i64* %5, align 8
  %6 = getelementptr %stack_t, %stack_t* %stack_args, i64 0, i32 1
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %7 = trunc i64 %get_pid_tgid to i32
  store i32 %7, i32* %6, align 4
  %8 = getelementptr %stack_t, %stack_t* %stack_args, i64 0, i32 2
  store i32 0, i32* %8, align 4
  %9 = getelementptr %printf_t, %printf_t* %printf_args, i32 0, i32 1
  %10 = bitcast [16 x i8]* %9 to i8*
  %11 = bitcast %stack_t* %stack_args to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %10, i8* align 1 %11, i64 16, i1 false)
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %ringbuf_output = call i64 inttoptr (i64 130 to i64 (i64, %printf_t*, i64, i64)*)(i64 %pseudo1, %printf_t* %printf_args, i64 24, i64 0)
  %ringbuf_loss = icmp slt i64 %ringbuf_output, 0
  br i1 %ringbuf_loss, label %event_loss_counter, label %counter_merge

event_loss_counter:                               ; preds = %entry
  %12 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %12)
  store i32 0, i32* %key, align 4
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_elem = call i8* inttoptr (i64 1 to i8* (i64, i32*)*)(i64 %pseudo2, i32* %key)
  %map_lookup_cond = icmp ne i8* %lookup_elem, null
  br i1 %map_lookup_cond, label %lookup_success, label %lookup_failure

counter_merge:                                    ; preds = %lookup_merge, %entry
  %13 = bitcast %printf_t* %printf_args to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %13)
  ret i64 0

lookup_success:                                   ; preds = %event_loss_counter
  %14 = bitcast i8* %lookup_elem to i64*
  %15 = atomicrmw add i64* %14, i64 1 seq_cst
  br label %lookup_merge

lookup_failure:                                   ; preds = %event_loss_counter
  br label %lookup_merge

lookup_merge:                                     ; preds = %lookup_failure, %lookup_success
  %16 = bitcast i32* %key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %16)
  br label %counter_merge
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly %0, i8 %1, i64 %2, i1 immarg %3) #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly %0, i8* noalias nocapture readonly %1, i64 %2, i1 immarg %3) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg %0, i8* nocapture %1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn writeonly }
