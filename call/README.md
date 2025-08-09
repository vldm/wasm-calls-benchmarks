Small WebAssembly call benchmarks. Created for wasm-split strategies testing.

Sources:
- provider.wat - Provides a simple function `foo` that returns the input value plus one.
- call_*.wat - Implement a simple loop that calls the provider's `foo` function multiple times.

Benchmark contain multiple variants of resolving Wasm -> Wasm calls:
- Direct import - Export is passed directly to the caller wasm module imports. Used as baseline. And work only when all modules are loaded and does not contain circular dependencies.
- JS trampoline - Export is passed to the JS function, which calls the provider wasm module import.
This introduce a shared variable `provider.exports` in the JS scope. When module is not loaded provider.exports can be not initialized.
- JS trampoline (mutable) - JS function is created with a mutable closure, that allows to change the provider dynamically. During initialization it can point to the stub function, which throws an error when called.
- JS trampoline (spread) - Same as regular JS trampoline, but instead of having function with fixed arguments, it uses spread operator to pass all arguments to the provider function.
This can reduce the size of Generated JS glue code, but is significantly slower.
- call_indirect - Uses `call_indirect` instruction to call the provider's `foo` function. This allows to call the function without knowing its address at compile time.
- call_indirect (js table) - Same as above, but instead of using wasm table from provider directly, it creates a new Wasm.Table in JS.
- call_indirect_stub - Instead of using `call_indirect` directly, it uses a stub function that will call indirect function. This aproach makes `wasm-split` algorithm easier, since no need to patch function body (replacing `call` to `call_indirect`).


To run the benchmarks:
1. Install `wat2wasm` tool from WebAssembly Binary Toolkit (WABT).
2. Run `./build.sh` to compile the `.wat` files to `.wasm` files.
3. in out use `python3 -m http.server` to serve the files.
4. Open `127.0.0.1:8000` in a web browser to run the benchmarks.



Results:

In my results `call_indirect` add small penalty over direct.
There is no differences where Wasm.Table is created in JS or in Wasm.
Stub function for `call_indirect` adds penalty of ~1/4.
JS: Mutable closure < JS: Trampoline with shared variable.
JS: direct arguments << JS: spread arguments.

JS trampoline on Firefox is ~2x faster than on Chrome.
Run in Chrome 139, and Firefox 140, on Ryzen 9950x.

Chrome 139:
```
Direct import               3.02  ns/call       (acc=562894464)
JS trampoline               15.77 ns/call       (acc=562894464)
JS trampoline (spread)      18.20 ns/call       (acc=562894464)
JS trampoline (mutable)     6.88  ns/call       (acc=562894464)
call_indirect               3.80  ns/call       (acc=562894464)
call_indirect (js table)    3.78  ns/call       (acc=562894464)
call_indirect_stub          5.69  ns/call       (acc=562894464)
```

Firefox 140:
```
Direct import               3.35  ns/call       (acc=562894464)
JS trampoline               8.65  ns/call       (acc=562894464)
JS trampoline (spread)      11.35 ns/call       (acc=562894464)
JS trampoline (mutable)     6.35  ns/call       (acc=562894464)
call_indirect               3.70  ns/call       (acc=562894464)
call_indirect (js table)    3.75  ns/call       (acc=562894464)
call_indirect_stub          4.95  ns/call       (acc=562894464)
```