import 'package:os/virtual_memory.dart';

void main() {
  // Allocate virtual memory
  final memory = VirtualMemory.allocate(1024);
  memory.asUint8List[0] = 42;

  // Make the memory read-only
  memory.setProtection(VirtualMemory.protectionWrite);

  // Any mutation will result in a crash now
  memory.asUint8List[0] = 99;
}
