import 'package:os/virtual_memory.dart';

/// PURPOSE:
/// Testing that a virtual memory protection violation leads to a crash.

void main(List<String> args) {
  mutateMemory(args[0], int.parse(args[1]), args[2]);
}

void mutateMemory(String when, int protection, String op) {
  VirtualMemory virtualMemory;
  switch (when) {
    case 'allocate':
      // Allocate
      virtualMemory = VirtualMemory.allocate(
        1024,
        protection: protection,
      );
      break;

    case 'setProtection':
      // Allocate with default protection
      virtualMemory = VirtualMemory.allocate(1024);

      // Change protection
      virtualMemory.setProtection(protection);
      break;

    default:
      throw ArgumentError.value(when, 'when');
  }
  switch (op) {
    case 'read':
      final value = virtualMemory.asUint8List[0];
      print('Read: $value');
      break;

    case 'write':
      virtualMemory.asUint8List[0] = 3;
      break;

    default:
      throw ArgumentError.value(op, 'op');
  }
  print('SUCCESS');
}
