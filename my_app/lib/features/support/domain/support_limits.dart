class SupportLimits {
  SupportLimits._();

  static const maximumSubjectLength = 160;
  static const maximumMessageLength = 10000;
  static const maximumAttachmentBytes = 10 * 1024 * 1024;
  static const allowedAttachmentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };
}
