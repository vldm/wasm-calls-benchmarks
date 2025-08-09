Simple WebAssembly offset calculation benchmark

In order to implement relocation we need to dynamically calculate offsets, for
this we replace a form of i32.const with different forms of offset calculation:
- inline i32.add with global base and constant offset
- same as above but storing result in local variable at beginning of the function 
- mutable global variable that is initialized at start of the function
- global variable that is initialized during instantiation (ext-const) 


As a result for Firefox 140:
```
Benchmark                      | Time (ns/call) |     Result
------------------------------------------------------------
A) const offsets              |          1.61 |-1440531528
B) local init each-iter       |          2.65 |-1440531528
C) global each-iter           |          2.17 |-1440531528
D) prebuilt MUT (start)       |          1.89 |-1440531528
E) prebuilt IMM (ext-const)   |          1.88 |-1440531528

```

Chrome 139:
```
Benchmark                      | Time (ns/call) |     Result
------------------------------------------------------------
A) const offsets              |          0.67 |-1440531528
B) local init each-iter       |          1.10 |-1440531528
C) global each-iter           |          1.10 |-1440531528
D) prebuilt MUT (start)       |          1.00 |-1440531528
E) prebuilt IMM (ext-const)   |          1.10 |-1440531528
```


So for GOT optimal way is to use mutable global variable, which is initialized at start. 