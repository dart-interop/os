import 'dart:io';
import 'dart:typed_data';

import 'package:os/file_system.dart';
import 'package:test/test.dart';

void main() {
  test(
    'NamedPipe',
    () async {
      // Construct File
      final file = File.fromUri(Directory.systemTemp.uri.resolve(
        'named_pipe_test',
      ));

      // Construct NamedPipe
      final fifo = NamedPipe(file.path);

      if (fifo.existsSync()) {
        fifo.deleteSync();
      }

      // Create a named pipe in the system
      fifo.createSync();
      expect(fifo.existsSync(), isTrue);
      addTearDown(() {
        if (fifo.existsSync()) {
          fifo.deleteSync();
        }
      });

      // Open writer and reader
      final receivedChunks = <List<int>>[];
      final readerSubscription = fifo.openRead().listen((item) {
        receivedChunks.add(item);
      }, onError: (error) {
        fail(error);
      });
      addTearDown(() {
        readerSubscription.cancel();
      });
      final writer = fifo.openWrite();

      // Write
      await writer.add(Uint8List.fromList([1, 2]));
      await writer.add(Uint8List.fromList([3, 4, 5]));
      await Future.delayed(const Duration(milliseconds: 50));

      // Stop
      await writer.close();
      await readerSubscription.cancel();

      // Check that we received the data
      expect(
        receivedChunks,
        [
          [1, 2, 3, 4, 5],
        ],
      );

      // Delete
      fifo.deleteSync();
      expect(file.existsSync(), isFalse);
    },
    testOn: 'mac-os',
    timeout: const Timeout(Duration(milliseconds: 200)),
  );
}
