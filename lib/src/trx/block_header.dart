import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../btc_sdk_base.dart';
import '../model/binary/uint.dart';
import '../model/crypto/hash.dart';

class BlockHeader extends Equatable {

  // Allowed value is Uint32. The version number is represented using little endian notation.
  final Uint nVersion;
  // 32 Bytes double SHA-256 hash of the previous linked block header
  final Uint8List hashPrevBlock;
  final Uint8List hashMerkleRoot;

  BlockHeader({required this.nVersion, required this.hashPrevBlock, required this.hashMerkleRoot}) {
    assert(nVersion.type == UintType.uint32);
    assert(hashPrevBlock.length == 32);
    assert(hashMerkleRoot.length == 32);
  }

  Uint8List get hash => Hash.sha256(Hash.sha256(
      nVersion.toUint8List
          .concat(hashPrevBlock)
          .concat(hashMerkleRoot)
    )
  );

  @override
  List<Object?> get props => [nVersion, hashPrevBlock, hashMerkleRoot];

}