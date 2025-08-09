(module

  ;; Host provides immutable base
  (global $lib_base (import "env" "lib_base") i32)
  ;; Big enough so we can loop a lot (256 * 64KiB = 16 MiB)
  (memory (export "mem") 256)

  ;; Offsets for the two variables (bytes)
  ;; A = lib_base + 0
  ;; B = lib_base + 64
  ;; (64 keeps both 8-byte aligned and separated)
  (global $g_prebuiltSRC i32
    (i32.add (global.get $lib_base) (i32.const 0)))
  (global $g_prebuiltSTORE i32
    (i32.add (global.get $lib_base) (i32.const 64)))

  ;; Mutable versions computed once in start
  (global $g_prebuiltSRC_mut (mut i32) (i32.const 0xff))
  (global $g_prebuiltSTORE_mut (mut i32) (i32.const 0xff))

  (start $init)
  (func $init
    (global.set $g_prebuiltSRC_mut
      (i32.add (global.get $lib_base) (i32.const 0)))
    (global.set $g_prebuiltSTORE_mut
      (i32.add (global.get $lib_base) (i32.const 64)))
  )

 ;; ----------------------------
  ;; A) Bases (const offset)
  ;; ----------------------------
  (func (export "bench_const") (param $iters i32) (result i32)
    (local $i i32) (local $acc i32)

    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $iters)))

        ;; *pSTORE = *pSRC + $i
        (local.set $acc
          (i32.add
            (i32.load (i32.const 0))
            (local.get $i))
        )
        (i32.store (i32.const 64) (local.get $acc))
        (local.set $i  (i32.add (local.get $i)  (i32.const 1)))
        (br $loop)
      )
    )
    (return (local.get $acc))
  )

  ;; ----------------------------
  ;; B) LOCAL  (pointer bump)
  ;; ----------------------------
  (func (export "bench_local") (param $iters i32) (result i32)
    (local $i i32) (local $acc i32)
    (local $pSRC i32) (local $pSTORE i32)


    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $iters)))

        (local.set $pSRC (i32.add (global.get $lib_base) (i32.const 0)))
        (local.set $pSTORE (i32.add (global.get $lib_base) (i32.const 64)))
        ;; *pSTORE = *pSRC + $i
        (local.set $acc
          (i32.add
            (i32.load (local.get $pSRC))
            (local.get $i))
        )
        (i32.store (local.get $pSTORE) (local.get $acc))
        (local.set $i  (i32.add (local.get $i)  (i32.const 1)))
        (br $loop)
      )
    )
    (return (local.get $acc))
  )

  ;; --------------------------------------
  ;; C) GLOBAL each iteration 
  ;; --------------------------------------
  (func (export "bench_global_each") (param $iters i32) (result i32)
    (local $i i32) (local $acc i32)

    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $iters)))

        ;; *addrSTORE = *addrSRC + $i
        (local.set $acc
          (i32.add
            (i32.load (i32.add (global.get $lib_base) (i32.const 0)))
            (local.get $i))
        )
        (i32.store 
            (i32.add (global.get $lib_base) (i32.const 64)) 
            (local.get $acc))

        (local.set $i  (i32.add (local.get $i)  (i32.const 1)))
        (br $loop)
      )
    )
    (return (local.get $acc))
  )
  ;; -------------------------------------------------
  ;; D) PREBUILT MUT globals (computed once in start)
  ;; -------------------------------------------------
  (func (export "bench_prebuilt_mut") (param $iters i32) (result i32)
    (local $i i32) (local $acc i32)
    (local $v i64)


    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $iters)))

        (local.set $acc
          (i32.add
            (i32.load (global.get $g_prebuiltSRC_mut))
            (local.get $i)))

        (i32.store (global.get $g_prebuiltSTORE_mut) (local.get $acc))
        (local.set $i  (i32.add (local.get $i)  (i32.const 1)))
        (br $loop)
      )
    )
    (return (local.get $acc))
  )
  ;; ------------------------------------------------
  ;; E) PREBUILT IMM globals (via extended-const)
  ;;    load pA/pB from immutable globals, then bump
  ;; ------------------------------------------------
  (func (export "bench_prebuilt_imm") (param $iters i32) (result i32)
    (local $i i32) (local $acc i32)



    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $iters)))

        (local.set $acc
          (i32.add
            (i32.load (global.get $g_prebuiltSRC))
            (local.get $i)))

        (i32.store (global.get $g_prebuiltSTORE) (local.get $acc))
        (local.set $i  (i32.add (local.get $i)  (i32.const 1)))
        (br $loop)
      )
    )
    (return (local.get $acc))
  )


)
