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

import 'package:meta/meta.dart';

/// Returns true when [Platform.isIOS] or [Platform.isMacOS] is true.
bool get isDarwin {
  return Platform.isIOS || Platform.isMacOS;
}

/// Loads a dynamic library by trying different names.
class DynamicLibraryProvider {
  final List<String> linuxNames;
  final List<String> darwinNames;
  final List<String> windowsNames;
  final List<String> otherNames;

  ffi.DynamicLibrary _dynamicLibrary;

  DynamicLibraryProvider({
    this.linuxNames = const [],
    this.darwinNames = const [],
    this.windowsNames = const [],
    this.otherNames = const [],
  });

  List<String> get currentNames {
    if (isDarwin) {
      return darwinNames;
    }
    if (Platform.isLinux) {
      return linuxNames;
    }
    if (Platform.isWindows) {
      return windowsNames;
    }
    return otherNames;
  }

  List<String> get supportedPlatforms {
    final result = <String>[];
    if (darwinNames.isNotEmpty) {
      result.add("darwin");
    }
    if (linuxNames.isNotEmpty) {
      result.add("linux");
    }
    if (windowsNames.isNotEmpty) {
      result.add("windows");
    }
    return result;
  }

  /// Opens the dynamic library.
  ///
  /// If the dynamic library is not found, throws [UnsupportedError].
  ffi.DynamicLibrary open() {
    var result = this._dynamicLibrary;
    if (result != null) {
      return result;
    }
    final names = currentNames;
    if (names.isEmpty) {
      final platformList = supportedPlatforms.toList()..sort();
      throw UnsupportedError(
        "The library is only supported in: ${platformList.join(', ')}",
      );
    }
    Object firstError;
    for (var name in currentNames) {
      try {
        final result = ffi.DynamicLibrary.open(name);
        this._dynamicLibrary = result;
        return result;
      } catch (e) {
        firstError ??= e;
      }
    }
    if (firstError != null) {
      throw firstError;
    }
    final joined = names.join("', '");
    throw UnsupportedError(
      "Could not find '$joined'",
    );
  }
}
