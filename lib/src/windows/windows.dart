// Copyright 2019 terrier989 <terrier989@gmail.com>.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Access to Windows kernel functions.
library os.windows.kernel;

import 'dart:ffi' as ffi;

import 'package:os/loading.dart';

const MEM_COALESCE_PLACEHOLDERS = 0x1;
const MEM_COMMIT = 0x1000;
const MEM_DECOMMIT = 0x4000;
const MEM_LARGE_PAGES = 0x20000000;
const MEM_PRESERVE_PLACEHOLDER = 0x2;
const MEM_RELEASE = 0x8000;
const MEM_RESERVE = 0x2000;
const MEM_RESET = 0x80000;
const PAGE_EXECUTE = 0x10;

const PAGE_EXECUTE_READ = 0x20;
const PAGE_EXECUTE_READWRITE = 0x40;
const PAGE_EXECUTE_WRITECOPY = 0x80;
const PAGE_NOACCESS = 0x1;
const PAGE_READONLY = 0x2;
const PAGE_READWRITE = 0x4;
const PAGE_WRITECOPY = 0x8;

final libraryLoader = DynamicLibraryProvider(
  windowsNames: ['kernel32.dll'],
);

final virtualAlloc =
    libraryLoader.open().lookupFunction<_virtualAlloc_C, _virtualAlloc_Dart>(
          'VirtualAlloc',
        );

final virtualFree =
    libraryLoader.open().lookupFunction<_virtualFree_C, _virtualFree_Dart>(
          'VirtualFree',
        );

final virtualProtect = libraryLoader
    .open()
    .lookupFunction<_virtualProtect_C, _virtualProtect_Dart>(
      'VirtualProtect',
    );

typedef _virtualAlloc_C = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  ffi.IntPtr size,
  ffi.Uint32 type,
  ffi.Uint32 protection,
);

typedef _virtualAlloc_Dart = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  int size,
  int type,
  int protection,
);

typedef _virtualFree_C = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  ffi.IntPtr size,
  ffi.Uint32 freeType,
);

typedef _virtualFree_Dart = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  int size,
  int freeType,
);

typedef _virtualProtect_C = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  ffi.IntPtr size,
  ffi.Uint32 protection,
  ffi.Pointer<ffi.Uint32> oldProtection,
);

typedef _virtualProtect_Dart = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  int size,
  int protection,
  ffi.Pointer<ffi.Uint32> oldProtection,
);
