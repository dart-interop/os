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

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../libc/all.dart' as libc;

/// Duration before polling again.
const _shortDuration = Duration(microseconds: 100);

/// Opens a file and returns file descriptor, which can be used with other
/// 'libc' functions.
int _openFd(String path, int flags) {
  final pathAddr = path.toNativeUtf8();
  try {
    return libc.open(
      pathAddr,
      flags,
      0,
    );
  } finally {
    malloc.free(pathAddr);
  }
}

class NamedPipe {
  final String path;

  NamedPipe(this.path) {
    if (path == null) {
      throw ArgumentError.notNull();
    }
  }

  /// Creates the named pipe.
  ///
  /// Parameter [mode] can be used to specify Posix file permissions.
  void createSync({int mode = 0x1FF}) {
    final pathAddr = path.toNativeUtf8();
    try {
      final result = libc.mkfifo(
        pathAddr,
        mode,
      );
      if (result < 0) {
        throw _NamedPipeException('create', path, libc.errorCode);
      }
    } finally {
      malloc.free(pathAddr);
    }
  }

  /// Deletes the named pipe.
  ///
  /// Note that usually named pipes can't be deleted with normal file
  /// operations.
  void deleteSync() {
    if (!existsSync()) {
      return;
    }
    final pathAddr = path.toNativeUtf8();
    try {
      final result = libc.unlink(
        pathAddr,
      );
      if (result < 0) {
        throw _NamedPipeException(
          'delete',
          path,
          libc.errorCode,
        );
      }
    } finally {
      malloc.free(pathAddr);
    }
  }

  bool existsSync() {
    return File(path).existsSync();
  }

  /// Opens the named pipe for reading.
  Stream<List<int>> openRead() {
    final streamController = StreamController<List<int>>();
    streamController.onListen = () {
      // Open the file
      final fd = _openFd(path, libc.O_RDONLY | libc.O_NONBLOCK);
      if (fd < 0) {
        final error = _NamedPipeException(
          'open',
          path,
          libc.errorCode,
        );
        streamController.addError(error);
        streamController.close();
        return;
      }

      // Allocate a buffer that can be filled by 'libc'
      final bufferLength = 512;
      final buffer = malloc.allocate<Uint8>(bufferLength);
      final bufferData = buffer.asTypedList(bufferLength);

      var libcClosed = false;

      // Periodically check whether any data has arrived
      Timer.periodic(_shortDuration, (timer) {
        if (libcClosed) {
          return;
        }

        // If the stream is closed
        if (streamController.isClosed) {
          // Cancel timer
          timer.cancel();
          libcClosed = true;

          // Free memory
          malloc.free(buffer);

          // Close file handle
          libc.close(fd);
          return;
        }

        // Read from 'libc'
        final result = libc.read(fd, buffer, bufferLength);

        // Error?
        if (result < 0) {
          final errorCode = libc.errorCode;

          // Because writer hasn't closed?
          if (errorCode == libc.EAGAIN) {
            // Wait a bit more
            return;
          }

          final error = _NamedPipeException(
            'read',
            path,
            errorCode,
          );
          streamController.addError(error);
          streamController.close();
          return;
        }

        // Empty?
        if (result == 0) {
          return;
        }

        // We received data.
        // We need to allocate a new Uint8List that we can pass to the listener.
        final readData = Uint8List(result);
        readData.setAll(0, bufferData.take(result));
        streamController.add(readData);
      });
      //libc.write(pollFd.fd, 0, 0);
    };
    return streamController.stream;
  }

  /// Opens the named pipe for writing.
  ///
  /// Optional parameter [timeout] defines how long to wait for readers to open
  /// the pipe.
  _NamedPipeWriter openWrite({Duration? timeout}) {
    return _NamedPipeWriter(path, timeout: timeout);
  }
}

class _NamedPipeException implements Exception {
  final String op;
  final String path;
  final int errorCode;

  _NamedPipeException(this.op, this.path, this.errorCode);

  @override
  String toString() {
    final errorName = libc.errorNames[errorCode];
    return 'Operation "$op" on a named pipe failed.\n  path = "$path"\n  error = $errorCode ($errorName)';
  }
}

class _NamedPipeWriter implements Sink<List<int>>, StreamConsumer<List<int>> {
  final String path;
  int? _fd;
  Future<void>? _future;
  bool _isClosed = false;
  final Duration? _timeout;

  _NamedPipeWriter(this.path, {Duration? timeout}) : _timeout = timeout {
    if (!File(path).existsSync()) {
      throw StateError('File "$path" does not exist');
    }
  }

  @override
  Future<void> add(List<int> data) {
    if (_isClosed) {
      throw StateError('The sink is closed');
    }
    var oldFuture = _future;
    if (oldFuture == null) {
      oldFuture = _waitForOpen();
      _future = oldFuture;
    }
    final newFuture = _add(oldFuture, data);
    _future = newFuture;
    return newFuture;
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (var chunk in stream) {
      await add(chunk);
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    final future = _future ?? Future<void>.value();
    return future.whenComplete(() {
      if (_fd != null) {
        final result = libc.close(_fd);
        _fd = null;
        if (result < 0) {
          throw _NamedPipeException(
            'close',
            path,
            libc.errorCode,
          );
        }
      }
    });
  }

  Future<void> _add(Future<void> waitedFuture, List<int> data) async {
    // Wait for previous future
    await waitedFuture;

    // If empty, we can skip allocation
    if (data.isEmpty) {
      return;
    }

    // Allocate buffer than 'libc' can use
    final length = data.length;
    final pointer = malloc.allocate<Uint8>(length);

    try {
      // Declare remaining pointer/length
      var remainingPointer = pointer;
      var remainingLength = length;

      // Copy data
      final pointerData = pointer.asTypedList(length);
      pointerData.setAll(0, data);

      // While we have remaining bytes
      while (remainingLength > 0) {
        if (_isClosed) {
          throw StateError('The sink is closed');
        }

        // Write
        final n = libc.write(_fd, remainingPointer, remainingLength);

        // An error?
        if (n < 0) {
          throw _NamedPipeException('add', path, libc.errorCode);
        }

        // Wrote something?
        if (n > 0) {
          remainingPointer = remainingPointer.elementAt(n);
          remainingLength -= n;
          if (remainingLength == 0) {
            return;
          }
        }

        // Wait a bit before trying again
        await Future.delayed(_shortDuration);
      }
    } finally {
      malloc.free(pointer);
    }
  }

  Future<void> _waitForOpen() async {
    final startedAt = DateTime.now();
    while (true) {
      if (_isClosed) {
        throw StateError('The sink is closed');
      }
      final fd = _openFd(path, libc.O_WRONLY | libc.O_NONBLOCK);
      if (fd <= 0) {
        // Failed because nobody is reading the stream?
        if (libc.errorCode == libc.ENXIO) {
          // Wait a bit more
          await Future.delayed(_shortDuration);
          if (_timeout != null &&
              DateTime.now().isAfter(startedAt.add(_timeout!))) {
            throw TimeoutException('Timeout before reader was attached');
          }
          continue;
        }
        throw _NamedPipeException('open', path, libc.errorCode);
      }
      _fd = fd;
      return;
    }
  }
}
