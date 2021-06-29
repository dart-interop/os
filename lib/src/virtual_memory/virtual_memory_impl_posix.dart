// Copyright 2019 terrier989 <terrier989@gmail.com>.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../libc/all.dart' as libc;
import 'virtual_memory.dart';

class VirtualMemoryImplPosix implements VirtualMemory {
  final ffi.Pointer<ffi.Uint8> _pointer;

  @override
  final int size;

  @override
  final Uint8List asUint8List;

  factory VirtualMemoryImplPosix.fromPointer(
      ffi.Pointer<ffi.Uint8> pointer, int size) {
    final data = pointer.cast<ffi.Uint8>().asTypedList(size);
    return VirtualMemoryImplPosix._(pointer, size, data);
  }

  VirtualMemoryImplPosix._(this._pointer, this.size, this.asUint8List);

  @override
  int get address => _pointer.address;

  @override
  void free() {
    libc.munmap(
      _pointer,
      size,
    );
  }

  @override
  void setProtection(int protection) {
    libc.mprotect(_pointer, size, protection);
  }

  static VirtualMemory allocate(
    int size, {
    int? protection,
    int? flags,
  }) {
    final pointer = libc.mmap(
      ffi.Pointer<ffi.Uint8>.fromAddress(0),
      size,
      protection,
      flags,
      -1,
      0,
    );
    if (pointer.address < 0) {
      throw StateError(
        'Allocating $size bytes of memory failed: ${libc.errorDescription}',
      );
    }
    return VirtualMemoryImplPosix.fromPointer(pointer, size);
  }
}
