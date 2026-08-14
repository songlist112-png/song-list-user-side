import 'package:file_picker/file_picker.dart';

import '../../../shared/utils/media_type.dart';
import '../domain/support_message.dart';
import '../domain/support_limits.dart';

class SupportAttachmentPicker {
  SupportAttachmentPicker._();

  static Future<SupportAttachmentDraft?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
    );
    if (result == null) return null;
    final file = result.files.single;
    final path = file.path;
    if (path == null) throw StateError('Selected image is unavailable');
    final mediaType = normalizeMediaType(
      file.extension ?? '',
      fileName: file.name,
    );
    final draft = SupportAttachmentDraft(
      path: path,
      name: file.name,
      mediaType: mediaType,
      size: file.size,
    );
    if (!SupportLimits.allowedAttachmentTypes.contains(mediaType)) {
      throw ArgumentError('Only JPEG, PNG, and WebP images are supported');
    }
    if (file.size > SupportLimits.maximumAttachmentBytes) {
      throw ArgumentError('Image must be 10 MB or smaller');
    }
    return draft;
  }
}
