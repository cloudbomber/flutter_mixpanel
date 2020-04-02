import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The codec utilized to encode data back and forth between
/// the Dart application and the native platform.
class MixpanelMessageCodec extends StandardMessageCodec {
  /// Constructor.
  const MixpanelMessageCodec();

  static const int _kDateTime = 128;
  static const int _kUri = 129;

  static const int _valueTrue = 1;
  static const int _valueFalse = 2;

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is DateTime) {
      buffer.putUint8(_kDateTime);
      buffer.putInt64(value.millisecondsSinceEpoch);
    } else if (value is Uri) {
      buffer.putUint8(_kUri);
      final List<int> bytes = utf8.encoder.convert(value.toString());
      writeSize(buffer, bytes.length);
      buffer.putUint8List(bytes);
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  dynamic readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case _kDateTime:
        return DateTime.fromMillisecondsSinceEpoch(buffer.getInt64());
      case _kUri:
        final int length = readSize(buffer);
        final String string = utf8.decoder.convert(buffer.getUint8List(length));
        return Uri.parse(string);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}