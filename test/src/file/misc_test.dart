import 'dart:io';

import 'package:os/file_system.dart';
import 'package:test/test.dart';

void main() {
  test("chmod", () async {
    final directory = Directory.systemTemp.createTempSync();
    addTearDown(() {
      directory.deleteSync();
    });
    expect(_octal(directory.statSync().mode & 0x1FF), isNot("777"));
    await chmod(directory, 0x1FF);
    expect(_octal(directory.statSync().mode & 0x1FF), "777");
  });

  test("chmodSync", () {
    final directory = Directory.systemTemp.createTempSync();
    addTearDown(() {
      directory.deleteSync();
    });
    expect(_octal(directory.statSync().mode & 0x1FF), isNot("777"));
    chmodSync(directory, 0x1FF);
    expect(_octal(directory.statSync().mode & 0x1FF), "777");
  });
}

String _octal(int v) => v.toRadixString(8);
