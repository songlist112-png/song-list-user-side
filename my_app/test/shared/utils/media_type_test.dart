import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/shared/utils/media_type.dart';

void main() {
  test('normalizes picker extensions into MIME media types', () {
    expect(normalizeMediaType('pdf'), 'application/pdf');
    expect(normalizeMediaType('.jpg'), 'image/jpeg');
    expect(
      normalizeMediaType('', fileName: 'chart.docx'),
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
  });

  test('preserves valid MIME values and safely defaults unknown values', () {
    expect(normalizeMediaType('application/pdf'), 'application/pdf');
    expect(normalizeMediaType('unknown'), 'application/octet-stream');
  });
}
