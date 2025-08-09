(module
  (type $t (func (param i32) (result i32)))
  (import "env" "table" (table 1 funcref))
  (func (export "bench") (param $iters i32) (result i32)
    (local $i i32) (local $acc i32)
    (local.set $i (i32.const 0))
    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $iters)))
        (local.set $acc (i32.add (local.get $acc) (call $foo (local.get $i))))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $loop)))
    (return (local.get $acc)))
  (func $foo (param i32) (result i32)
    (call_indirect (type $t) (local.get 0) (i32.const 0)))
)