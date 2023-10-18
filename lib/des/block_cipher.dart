import 'dart:convert';

import 'package:rassi_assist/des/engine.dart';
import 'package:rassi_assist/des/utils.dart';



class BlockCipher {
  final Engine engine;
  final String key;

  BlockCipher(this.engine, this.key);

  String encode(String message) {
    engine.init(true, utf8ToWords(key));
    var result = engine.process(utf8ToWords(message));
    engine.reset();
    return wordsToUtf8(result);
  }

  String decode(String ciphertext) {
    var b = engine..init(false, utf8ToWords(key));
    var r = b.process(utf8ToWords(ciphertext));
    engine.reset();
    return wordsToUtf8(r);
  }

  String encodeB64(String message) {
    return base64.encode(encode(message).codeUnits);
  }

  String decodeB64(String ciphertext) {
    var b = engine..init(false, utf8ToWords(key));
    var result = b.process(parseBase64(ciphertext));
    engine.reset();
    return wordsToUtf8(result);
  }
}