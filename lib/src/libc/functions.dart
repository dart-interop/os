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

/// Access to 'libc', a library available in Posix systems.
library os.libc;

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:os/loading.dart';

const MAP_ANONYMOUS = 0x1000;
const MAP_FIXED = 0x0010;
const MAP_JIT = 0x0800;
const MAP_NOCACHE = 0x0400;
const MAP_PRIVATE = 0x0002;
const MAP_SHARED = 0x0001;

const O_ACCMODE = 0x0003;
const O_APPEND = 0x0008;
const O_ASYNC = 0x0040;
const O_CREAT = 0x0200;
const O_EXCL = 0x0800;
const O_EXLOCK = 0x0020;
const O_FSYNC = 0x0080;
const O_NOFOLLOW = 0x0100;
const O_NONBLOCK = 0x0004;
const O_RDONLY = 0x0000;
const O_RDWR = 0x0002;
const O_SHLOCK = 0x0010;
const O_TRUNC = 0x0400;
const O_WRONLY = 0x0001;

const POLLERR = 0x08;
const POLLHUP = 0x10;
const POLLIN = 0x01;
const POLLNVAL = 0x20;
const POLLOUT = 0x04;
const POLLPRI = 0x02;

const PROT_EXEC = 0x04;
const PROT_NONE = 0x00;
const PROT_READ = 0x01;
const PROT_WRITE = 0x02;

final chmod = libraryLoader.open().lookupFunction<_chmod_C, _chmod_Dart>(
      'chmod',
    );

final close = libraryLoader.open().lookupFunction<_close_C, _close_Dart>(
      'close',
    );

final libraryLoader = DynamicLibraryProvider(
  darwinNames: const ['libc.dylib', '/usr/lib/libc.dylib'],
  linuxNames: const ['libc.so.6', 'libc.so'],
);

final mkfifo = libraryLoader.open().lookupFunction<_mkfifo_C, _mkfifo_Dart>(
      'mkfifo',
    );

final mkdir = libraryLoader.open().lookupFunction<_mkdir_C, _mkdir_Dart>(
      'mkdir',
    );

final mmap = libraryLoader.open().lookupFunction<_mmap_C, _mmap_Dart>(
      'mmap',
    );

final mprotect =
    libraryLoader.open().lookupFunction<_mprotect_C, _mprotect_Dart>(
          'mprotect',
        );

final munmap = libraryLoader.open().lookupFunction<_munmap_C, _munmap_Dart>(
      'munmap',
    );

final open = libraryLoader.open().lookupFunction<_open_C, _open_Dart>(
      'open',
    );

final poll = libraryLoader.open().lookupFunction<_poll_C, _poll_Dart>(
      'poll',
    );

final read = libraryLoader.open().lookupFunction<_read_C, _read_Dart>(
      'read',
    );

final unlink = libraryLoader.open().lookupFunction<_unlink_C, _unlink_Dart>(
      'unlink',
    );

final write = libraryLoader.open().lookupFunction<_write_C, _write_Dart>(
      'write',
    );

typedef _chmod_C = ffi.Int32 Function(
  ffi.Pointer<ffi.Utf8> name,
  ffi.Int32 mode,
);

typedef _chmod_Dart = int Function(
  ffi.Pointer<ffi.Utf8> name,
  int mode,
);

typedef _close_C = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _close_Dart = int Function(
  int fd,
);

typedef _mkfifo_C = ffi.Int32 Function(
  ffi.Pointer<ffi.Utf8> name,
  ffi.Int32 mode,
);

typedef _mkfifo_Dart = int Function(
  ffi.Pointer<ffi.Utf8> name,
  int mode,
);

typedef _mmap_C = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  ffi.IntPtr size, // size_t
  ffi.Int32 protection,
  ffi.Int32 flags,
  ffi.Int32 fileDescriptor,
  ffi.IntPtr offset, // off_t
);

typedef _mmap_Dart = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> pointer,
  int size, // size_t
  int protection,
  int flags,
  int fileDescriptor,
  int offset, // off_t
);

typedef _mprotect_C = ffi.Void Function(
  ffi.Pointer<ffi.Uint8> pointer,
  ffi.IntPtr size,
  ffi.IntPtr protection,
);

typedef _mprotect_Dart = void Function(
  ffi.Pointer<ffi.Uint8> pointer,
  int size,
  int protection,
);

typedef _mkdir_C = ffi.Int32 Function(
  ffi.Pointer<ffi.Utf8> name,
  ffi.Int32 mode,
);

typedef _mkdir_Dart = int Function(
  ffi.Pointer<ffi.Utf8> name,
  int mode,
);

typedef _munmap_C = ffi.Void Function(
  ffi.Pointer<ffi.Uint8> pointer,
  ffi.IntPtr size,
);

typedef _munmap_Dart = void Function(
  ffi.Pointer<ffi.Uint8> pointer,
  int size,
);

typedef _open_C = ffi.Int32 Function(
  ffi.Pointer<ffi.Utf8> name,
  ffi.Int32 flags,
  ffi.Int32 mode,
);

typedef _open_Dart = int Function(
  ffi.Pointer<ffi.Utf8> name,
  int flags,
  int mode,
);

typedef _poll_C = ffi.Int32 Function(
  ffi.Pointer<PollFd> pollfd,
  ffi.Int32 pollfdLength,
  ffi.Int32 timeout,
);

typedef _poll_Dart = int Function(
  ffi.Pointer<PollFd> pollfd,
  int pollfdLength,
  int timeout,
);

typedef _read_C = ffi.IntPtr Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Uint8> buffer,
  ffi.IntPtr length,
);

typedef _read_Dart = int Function(
  int fd,
  ffi.Pointer<ffi.Uint8> buffer,
  int length,
);

typedef _unlink_C = ffi.Int32 Function(
  ffi.Pointer<ffi.Utf8> name,
);

typedef _unlink_Dart = int Function(
  ffi.Pointer<ffi.Utf8> name,
);

typedef _write_C = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Uint8> buffer,
  ffi.IntPtr length,
);

typedef _write_Dart = int Function(
  int fd,
  ffi.Pointer<ffi.Uint8> buffer,
  int length,
);

abstract class PollFd extends ffi.Struct {
  @ffi.Int32()
  int fd;

  @ffi.Int16()
  int events;

  @ffi.Int16()
  int revents;
}
