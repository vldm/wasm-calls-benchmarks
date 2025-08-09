#!/usr/bin/env bash


wat2wasm ./src/call_indirect.wat -o ./out/call_indirect.wasm
wat2wasm ./src/call_export.wat -o ./out/call_export.wasm
wat2wasm ./src/provider.wat -o ./out/provider.wasm
wat2wasm ./src/call_indirect_stub.wat -o ./out/call_indirect_stub.wasm