import 'dart:io';

import 'package:os/virtual_memory.dart';
import 'package:test/test.dart';

void main() {
  group("VirtualMemory:", () {
    const pageSize = 4096;

    test("allocate(...)", () {
      final memory = VirtualMemory.allocate(pageSize);
      expect(memory, isNotNull);
    });

    ProcessResult runVirtualMemoryScript(
        String when, int protection, String op) {
      return Process.runSync(
        "dart",
        [
          "test/src/virtual_memory/virtual_memory_error_script.dart"
              .replaceAll("/", Platform.pathSeparator),
          when,
          protection.toString(),
          op,
        ],
        runInShell: true,
      );
    }

    void testProtection(String when, int protection) {
      final read = protection & VirtualMemory.protectionRead != 0;
      final write = protection & VirtualMemory.protectionWrite != 0;

      // Try read
      {
        final result = runVirtualMemoryScript(when, protection, "read");
        if (read) {
          expect(result.stderr, "");
          expect(result.stdout, contains("SUCCESS"));
        } else {
          expect(result.stderr, contains("CRASH"));
        }
      }

      // Try write
      {
        final result = runVirtualMemoryScript(when, protection, "write");
        if (write) {
          expect(result.stderr, "");
          expect(result.stdout, contains("SUCCESS"));
        } else {
          expect(result.stderr, contains("CRASH"));
        }
      }
    }

    test("allocate(..., protection:VirtualMemory.protectionNoAccess)", () {
      testProtection("allocate", VirtualMemory.protectionNoAccess);
    });

    test("allocate(..., protection:VirtualMemory.protectionRead)", () {
      testProtection("allocate", VirtualMemory.protectionRead);
    });

    test("allocate(..., protection:VirtualMemory.protectionReadWrite)", () {
      testProtection("allocate", VirtualMemory.protectionReadWrite);
    });

    test("setProtection(..., VirtualMemory.protectionNoAccess)", () {
      testProtection("setProtection", VirtualMemory.protectionNoAccess);
    });

    test("setProtection(..., VirtualMemory.protectionRead)", () {
      testProtection("setProtection", VirtualMemory.protectionRead);
    });

    test("setProtection(..., VirtualMemory.protectionReadWrite)", () {
      testProtection("setProtection", VirtualMemory.protectionReadWrite);
    });

    test("mutate the first element: OK", () {
      final memory = VirtualMemory.allocate(
        pageSize,
        protection: VirtualMemory.protectionReadWrite,
      );
      expect(memory.asUint8List[0], 0);
      memory.asUint8List[0] = 3;
      expect(memory.asUint8List[0], 3);
    });

    test("mutate the last element", () {
      final memory = VirtualMemory.allocate(pageSize);
      final last = pageSize - 1;
      expect(memory.asUint8List[last], 0);
      memory.asUint8List[last] = 3;
      expect(memory.asUint8List[last], 3);
      expect(() => memory.asUint8List[last + 1], throwsArgumentError);
    });

    test("free", () {
      final memory = VirtualMemory.allocate(pageSize);

      // Free the memory
      // TODO: How to test this?
      memory.free();
    });
  }, testOn: "posix || windows");
}
