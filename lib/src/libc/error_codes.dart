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

import 'dart:ffi' as ffi;

import 'functions.dart' show libraryLoader;

final _errno = libraryLoader.open().lookup<ffi.Int32>('errno');

int get errorCode => _errno.value;

String get errorDescription {
  final c = errorCode;
  return '${errorNames[c]} ($c)';
}

const EPERM = 1;
const ENOENT = 2;
const ESRCH = 3;
const EINTR = 4;
const EIO = 5;
const ENXIO = 6;
const BIG = 7;
const ENOEXEC = 8;
const EBADF = 9;
const ECHILD = 10;
const EDEADLK = 11;
const ENOMEM = 12;
const EACCES = 13;
const EFAULT = 14;
const ENOTBLK = 15;
const EBUSY = 16;
const EEXIST = 17;
const EXDEV = 18;
const ENODEV = 19;
const ENOTDIR = 20;
const EISDIR = 21;
const EINVAL = 22;
const ENFILE = 23;
const EMFILE = 24;
const ENOTTY = 25;
const ETXTBSY = 26;
const EFBIG = 27;
const ENOSPC = 28;
const ESPIPE = 29;
const EROFS = 30;
const EMLINK = 31;
const EPIPE = 32;
const EDOM = 33;
const ERANGE = 34;
const EAGAIN = 35;
const EINPROGRESS = 36;
const EALREADY = 37;
const ENOTSOCK = 38;
const EDESTADDRREQ = 39;
const EMSGSIZE = 40;
const EPROTOTYPE = 41;
const ENOPROTOOPT = 42;
const EPROTONOSUPPORT = 43;
const ESOCKTNOSUPPORT = 44;
const ENOTSUP = 45;
const EPFNOSUPPORT = 46;
const EAFNOSUPPORT = 47;
const EADDRINUSE = 48;
const EADDRNOTAVAIL = 49;
const ENETDOWN = 50;
const ENETUNREACH = 51;
const ENETRESET = 52;
const ECONNABORTED = 53;
const ECONNRESET = 54;
const ENOBUFS = 55;
const EISCONN = 56;
const ENOTCONN = 57;
const ESHUTDOWN = 58;
const ETOOMANYREFS = 59;
const ETIMEDOUT = 60;
const ECONNREFUSED = 61;
const ELOOP = 62;
const ENAMETOOLONG = 63;
const EHOSTDOWN = 64;
const EHOSTUNREACH = 65;
const ENOTEMPTY = 66;
const EPROCLIM = 67;
const EUSERS = 68;
const EDQUOT = 69;
const ENOLCK = 77;
const ENOSYS = 78;
const EFTYPE = 79;
const EAUTH = 80;
const ENEEDAUTH = 81;
const EPWROFF = 82;
const EDEVERR = 83;
const EOVERFLOW = 84;
const EBADEXEC = 85;
const EBADARCH = 86;
const ESHLIBVERS = 87;

const errorNames = <int, String>{
  1: 'EPERM',
  2: 'ENOENT',
  3: 'ESRCH',
  4: 'EINTR',
  5: 'EIO',
  6: 'ENXIO',
  7: 'BIG',
  8: 'ENOEXEC',
  9: 'EBADF',
  10: 'ECHILD',
  11: 'EDEADLK',
  12: 'ENOMEM',
  13: 'EACCES',
  14: 'EFAULT',
  15: 'ENOTBLK',
  16: 'EBUSY',
  17: 'EEXIST',
  18: 'EXDEV',
  19: 'ENODEV',
  20: 'ENOTDIR',
  21: 'EISDIR',
  22: 'EINVAL',
  23: 'ENFILE',
  24: 'EMFILE',
  25: 'ENOTTY',
  26: 'ETXTBSY',
  27: 'EFBIG',
  28: 'ENOSPC',
  29: 'ESPIPE',
  30: 'EROFS',
  31: 'EMLINK',
  32: 'EPIPE',
  33: 'EDOM',
  34: 'ERANGE',
  35: 'EAGAIN',
  36: 'EINPROGRESS',
  37: 'EALREADY',
  38: 'ENOTSOCK',
  39: 'EDESTADDRREQ',
  40: 'EMSGSIZE',
  41: 'EPROTOTYPE',
  42: 'ENOPROTOOPT',
  43: 'EPROTONOSUPPORT',
  44: 'ESOCKTNOSUPPORT',
  45: 'ENOTSUP',
  46: 'EPFNOSUPPORT',
  47: 'EAFNOSUPPORT',
  48: 'EADDRINUSE',
  49: 'EADDRNOTAVAIL',
  50: 'ENETDOWN',
  51: 'ENETUNREACH',
  52: 'ENETRESET',
  53: 'ECONNABORTED',
  54: 'ECONNRESET',
  55: 'ENOBUFS',
  56: 'EISCONN',
  57: 'ENOTCONN',
  58: 'ESHUTDOWN',
  59: 'ETOOMANYREFS',
  60: 'ETIMEDOUT',
  61: 'ECONNREFUSED',
  62: 'ELOOP',
  63: 'ENAMETOOLONG',
  64: 'EHOSTDOWN',
  65: 'EHOSTUNREACH',
  66: 'ENOTEMPTY',
  67: 'EPROCLIM',
  68: 'EUSERS',
  69: 'EDQUOT',
  77: 'ENOLCK',
  78: 'ENOSYS',
  79: 'EFTYPE',
  80: 'EAUTH',
  81: 'ENEEDAUTH',
  82: 'EPWROFF',
  83: 'EDEVERR',
  84: 'EOVERFLOW',
  85: 'EBADEXEC',
  86: 'EBADARCH',
  87: 'ESHLIBVERS',
};
