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
import 'dart:io';
import 'dart:typed_data';

import '../libc/all.dart' as libc;
import 'virtual_memory_impl_posix.dart';
import 'virtual_memory_impl_windows.dart';

abstract class VirtualMemory {
  static const int protectionNoAccess = libc.PROT_NONE;
  static const int protectionRead = libc.PROT_READ;
  static const int protectionWrite = libc.PROT_WRITE;
  static const int protectionReadWrite = libc.PROT_READ | libc.PROT_WRITE;
  static const int protectionExecute = libc.PROT_EXEC;
  static const int flagsShared = libc.MAP_SHARED;
  static const int flagsPrivate = libc.MAP_PRIVATE;
  static const int flagsAnonymous = libc.MAP_ANONYMOUS;

  factory VirtualMemory.allocate(
    int size, {
    int protection,
    int flags,
  }) {
    if (size < 0) {
      throw ArgumentError.value(size, 'size');
    }
    protection ??= protectionRead | protectionWrite;
    flags ??= flagsPrivate | flagsAnonymous;
    if (Platform.isWindows) {
      return VirtualMemoryImplWindows.allocate(
        size,
        protection: protection,
        flags: flags,
      );
    }
    return VirtualMemoryImplPosix.allocate(
      size,
      protection: protection,
      flags: flags,
    );
  }

  factory VirtualMemory.fromAddress(int address, int size) {
    if (Platform.isWindows) {
      return VirtualMemoryImplWindows.fromPointer(
        ffi.Pointer<ffi.Uint8>.fromAddress(address),
        size,
      );
    }
    return VirtualMemoryImplPosix.fromPointer(
      ffi.Pointer<ffi.Uint8>.fromAddress(address),
      size,
    );
  }

  int get address;
  Uint8List get asUint8List;
  int get size;
  void free();
  void setProtection(int protection);
}
