# Overview
This package provides access to various low-level APIs of operating systems. The package binds with
_libc_ (Linux, Mac OS X) and _kernel32.dll_ (Windows) using [dart:ffi](https://dart.dev/guides/libraries/c-interop).

The project is licensed under the [Apache License 2.0](LICENSE).

## Status
Passes tests in:
  * Darwin (OS X)

Fails tests in:
  * Linux
  * Windows

## Issues?
  * [Create an issue](https://github.com/terrier989/os/issues).

# APIs
## os.file_system
Library 'package:os/file_system.dart' provides access to various functions not supported by
'dart:io'.

Examples:
```dart
chmodSync(Directory("some/path"), 0x1FF); // Octal: 777
```

Named pipes (also known as "POSIX pipes") are sometimes used for inter-process communication in
operating systems such as Linux and Mac OS X.

```dart
void main() async {
  // Create the pipe
  final namedPipe = NamedPipe("some/path");
  namedPipe.createSync();

  // Write something
  final writer = namedPipe.openWrite()
  writer.add([1,2,3])
  await writer.close();

  // Delete the pipe
  namedPipe.deleteSync();
}
```

## os.virtual_memory
Library 'package:os/memory.dart' enables you to control virtual memory tables.

```dart
void main() async {
  // Allocate memory
  final memory = VirtualMemory.allocate(1024);

  // Set protection bits
  memory.setProtection(VirtualMemory.protectionReadWrite);

  // Write to the memory
  memory.asUint8List[23] = 29;

  // Free the memory
  memory.free();
}
```