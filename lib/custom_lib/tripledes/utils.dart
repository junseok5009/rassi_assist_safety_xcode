import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/services.dart';

int rightShift32(int num, int n) {
  return ((num & 0xFFFFFFFF) >> n).toSigned(32);
}

int leftShift32(int num, int n) {
  return ((num & 0xFFFFFFFF) << n).toSigned(32);
}

Uint8List uInt8ListFrom32BitList(List<int> bit32) {
  var result = Uint8List(bit32.length * 4);
  for (var i = 0; i < bit32.length; i++) {
    for (var j = 0; j < 4; j++) {
      result[i * 4 + j] = bit32[i] /*.toSigned(32)*/ >> (j * 8);
    }
  }
  return result;
}

List<int> bit32ListFromUInt8List(Uint8List bytes) {
  var additionalLength = bytes.length % 4 > 0 ? 4 : 0;
  var result =
      List<int>.generate(bytes.length ~/ 4 + additionalLength, (_) => 0);
  for (var i = 0; i < bytes.length; i++) {
    var resultIdx = i ~/ 4;
    var bitShiftAmount = (3 - i % 4);
    result[resultIdx] |= bytes[i] << bitShiftAmount;
  }
  for (var i = 0; i < result.length; i++) {
    result[i] = result[i] << 24;
  }
  return result;
}

void pkcs7Pad(List<int> data, int blockSize) {
  var blockSizeBytes = blockSize * 4;
  // Count padding bytes
  var nPaddingBytes = blockSizeBytes - data.length % blockSizeBytes;

  // Create padding word
  var paddingWord = (nPaddingBytes << 24) |
      (nPaddingBytes << 16) |
      (nPaddingBytes << 8) |
      nPaddingBytes;

  // Create padding
  var paddingWords = [];
  for (var i = 0; i < nPaddingBytes; i += 4) {
    paddingWords.add(paddingWord);
  }

  var padding = List<int>.generate(nPaddingBytes, (i) {
    if (i < paddingWords.length) {
      return paddingWords[i];
    } else {
      return 0;
    }
  });

  // Add padding
  concat(data, padding);
}

void pkcs7Unpad(List<int> data, int blockSize) {
  var sigBytes = data.length;
  var nPaddingBytes = data[rightShift32(sigBytes - 1, 2)] & 0xff;
  data.length -= nPaddingBytes;
}

/// wordarray.concat()
concat(List<int> a, List<int> b) {
  // Shortcuts
  var thisWords = a;
  var thatWords = b;
  var thisSigBytes = a.length;
  var thatSigBytes = b.length;

  // Clamp excess bits
  clamp(a);

  // Concat
  if (thisSigBytes % 4 != 0) {
    // Copy one byte at a time
    for (var i = 0; i < thatSigBytes; i++) {
      var thatByte = (thatWords[i >> 2] >> (24 - (i % 4) * 8)) & 0xff;
      var idx = (thisSigBytes + i) >> 2;
      expandList(thisWords, idx + 1);
      thisWords[idx] |= thatByte << (24 - ((thisSigBytes + i) % 4) * 8);
    }
  } else {
    // Copy one word at a time
    for (var i = 0; i < thatSigBytes; i += 4) {
      var idx = (thisSigBytes + i) >> 2;
      if (idx >= thisWords.length) {
        // thisWords.length = idx + 1;
        int currentLength = thisWords.length;
        thisWords.addAll(List<int>.filled(idx + 1 - currentLength, 0));
      }
      thisWords[idx] = thatWords[i >> 2];
    }
  }

  // a.length = thisSigBytes + thatSigBytes;
  int currentLength = a.length;
  a.addAll(List<int>.filled(thisSigBytes + thatSigBytes - currentLength, 0));
}

void expandList(List<int> data, int newLength) {
  if (newLength <= data.length) {
    return;
  }

  int currentLength = data.length;
  // 크기가 newLength가 되도록 리스트 확장
  data.addAll(List<int>.filled(newLength - currentLength, 0));

/*  // update the length
  data.length = newLength;

  // replace any new allocations with 0
  for (var i = 0; i < data.length; i++) {
    if (data[i] == null) {
      data[i] = 0;
    }
  }*/
}

void clamp(List<int> data) {
  // Shortcuts
  var words = data;
  var sigBytes = data.length;

  // Clamp
  words[rightShift32(sigBytes, 2)] &=
      (0xffffffff << (32 - (sigBytes % 4) * 8)).toSigned(32);
  words.length = (sigBytes / 4).ceil();
}

// Latin1.parse
List<int> utf8ToWords(String inp) {
  var words = List.generate(inp.length, (_) => 0);
  for (var i = 0; i < inp.length; i++) {
    words[i >> 2] |= (inp.codeUnitAt(i) & 0xff).toSigned(32) <<
        (24 - (i % 4) * 8).toSigned(32);
  }
  return words;
}

// Latin1.stringify
String wordsToUtf8(List<int> words) {
  var sigBytes = words.length;
  var chars = <int>[];
  for (var i = 0; i < sigBytes; i++) {
    var bite = ((words[i >> 2]).toSigned(32) >> (24 - (i % 4) * 8)) & 0xff;
    chars.add(bite);
  }

  return String.fromCharCodes(chars);
}

List<int> parseBase64(String base64Str) {
  const map =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  List<int>? reverseMap;
  // Shortcuts
  var base64StrLength = base64Str.length;

  reverseMap = List<int>.filled(123, 0);
  for (var j = 0; j < map.length; j++) {
    reverseMap[map.codeUnits[j]] = j;
  }

  // Ignore padding
  var paddingChar = map.codeUnits[64];
  var paddingIndex = base64Str.codeUnits.indexOf(paddingChar);
  if (paddingIndex != -1) {
    base64StrLength = paddingIndex;
  }

  List<int> parseLoop(
      String base64Str, int base64StrLength, List<int> reverseMap) {
    var words = [];
    var nBytes = 0;
    for (var i = 0; i < base64StrLength; i++) {
      if (i % 4 != 0) {
        var bits1 = reverseMap[base64Str.codeUnits[i - 1]] <<
            ((i % 4) * 2).toSigned(32);
        var bits2 =
            rightShift32(reverseMap[base64Str.codeUnits[i]], (6 - (i % 4) * 2))
                .toSigned(32);
        var idx = rightShift32(nBytes, 2);
        if (words.length <= idx) {
          words.length = idx + 1;
        }
        for (var i = 0; i < words.length; i++) {
          if (words[i] == null) words[i] = 0;
        }
        words[idx] |= ((bits1 | bits2) << (24 - (nBytes % 4) * 8)).toSigned(32);
        nBytes++;
      }
    }
    return List<int>.generate(nBytes, (i) => i < words.length ? words[i] : 0);
  }

  // Convert
  return parseLoop(base64Str, base64StrLength, reverseMap);
}

//폰 번호
String utilsGetDeviceHpID(strPhone) {
  String devicePh;
  if (strPhone != null && strPhone.length > 7) {
    devicePh = strPhone.trim().substring(1);
    return devicePh;
  } else {
    return '';
  }
}

Future<String> utilsGetIDFA() async {
  String strIDFA = '';
  try {
    if (await AppTrackingTransparency.trackingAuthorizationStatus ==
        TrackingStatus.authorized) {
      final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
      strIDFA = uuid;
    }
  } on PlatformException {
    strIDFA = '';
  }
  return strIDFA;
}

int utilsGetCutMaxValue(String maxValue) {
  int result = 0;
  int length = maxValue.length;
  if (maxValue.contains('-')) {
    if (length < 3) {
      result = int.parse(maxValue);
    } else {
      maxValue = maxValue.substring(1);
      length -= 1;
      int v0 = int.parse(maxValue[0]);
      int v1 = int.parse(maxValue[1]);
      if (v1 == 9) {
        if (v0 == 9) {
          String s1 = '1';
          for (int i = 0; i < length; i++) {
            s1 += '0';
          }
          result = int.parse(s1) * -1;
        } else {
          String s1 = (v0 + 1).toString();
          for (int i = 0; i < length - 1; i++) {
            s1 += '0';
          }
          result = int.parse(s1) * -1;
        }
      } else {
        String s1 = (v1 + 1).toString();
        for (int i = 0; i < length - 2; i++) {
          s1 += '0';
        }
        result = int.parse(maxValue[0] + s1) * -1;
      }
    }
  } else {
    if (length < 2) {
      result = int.parse(maxValue);
    } else {
      int v0 = int.parse(maxValue[0]);
      int v1 = int.parse(maxValue[1]);
      if (v1 == 9) {
        if (v0 == 9) {
          String s1 = '1';
          for (int i = 0; i < length; i++) {
            s1 += '0';
          }
          result = int.parse(s1);
        } else {
          String s1 = (v0 + 1).toString();
          for (int i = 0; i < length - 1; i++) {
            s1 += '0';
          }
          result = int.parse(s1);
        }
      } else {
        String s1 = (v1 + 1).toString();
        for (int i = 0; i < length - 2; i++) {
          s1 += '0';
        }
        result = int.parse(maxValue[0] + s1);
      }
    }
  }
  return result;
}
