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

import 'package:ffi/ffi.dart' as ffi;

import '../libc/all.dart' as libc;
import '../windows/windows.dart' as windows;
import 'virtual_memory.dart';

class VirtualMemoryImplWindows implements VirtualMemory {
  final ffi.Pointer<ffi.Uint8> _pointer;

  @override
  final int size;

  VirtualMemoryImplWindows.fromPointer(this._pointer, this.size);

  @override
  int get address => _pointer.address;

  @override
  Uint8List get asUint8List {
    return _pointer.asTypedList(size);
  }

  @override
  void free() {
    windows.virtualFree(
      _pointer,
      size,
      windows.MEM_DECOMMIT | windows.MEM_RELEASE,
    );
  }

  @override
  void setProtection(int protection) {
    final oldPtr = ffi.allocate<ffi.Uint32>();
    try {
      windows.virtualProtect(
        _pointer,
        size,
        _toWindowsProtection(protection),
        oldPtr,
      );
    } finally {
      ffi.free(oldPtr);
    }
  }

  static VirtualMemory allocate(
    int size, {
    int protection,
    int flags,
  }) {
    final nullPointer = ffi.Pointer<ffi.Uint8>.fromAddress(0);
    final resultPointer = windows.virtualAlloc(
      nullPointer,
      size,
      _toWindowsFlags(flags),
      _toWindowsProtection(protection),
    );
    return VirtualMemoryImplWindows.fromPointer(resultPointer, size);
  }

  static int _toWindowsFlags(int flags) {
    var result = windows.MEM_COMMIT | windows.MEM_RESERVE;
    return result;
  }

  static int _toWindowsProtection(int protection) {
    final isExecute = protection & libc.PROT_EXEC != 0;
    final isRead = protection & libc.PROT_READ != 0;
    final isWrite = protection & libc.PROT_WRITE != 0;
    if (isExecute) {
      if (isRead) {
        if (isWrite) {
          return windows.PAGE_EXECUTE_READWRITE;
        }
        return windows.PAGE_EXECUTE_READ;
      }
      return windows.PAGE_EXECUTE;
    }
    if (isWrite) {
      return windows.PAGE_READWRITE;
    }
    if (isRead) {
      return windows.PAGE_READONLY;
    }
    return windows.PAGE_NOACCESS;
  }
}
