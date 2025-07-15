// lib/models/block_type.dart

enum BlockType {
  SUMMARY,
  DETAILED_EXPLANATION,
  CODE_EXAMPLE,
  CODE_QUIZ, // New type
  UNKNOWN;

  static BlockType fromString(String type) {
    switch (type) {
      case 'SUMMARY':
        return BlockType.SUMMARY;
      case 'DETAILED_EXPLANATION':
        return BlockType.DETAILED_EXPLANATION;
      case 'CODE_EXAMPLE':
        return BlockType.CODE_EXAMPLE;
      case 'CODE_QUIZ': // New type
        return BlockType.CODE_QUIZ;
      default:
        return BlockType.UNKNOWN;
    }
  }
}