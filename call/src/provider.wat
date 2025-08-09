(module
  (type $t (func (param i32) (result i32)))
  (table $table (export "table") 1 funcref)
  (elem $table (i32.const 0) $foo)
  (func $foo (export "foo") (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add)
)
