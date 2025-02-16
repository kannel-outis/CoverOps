import 'package:html_gen/src/tag.dart';
import 'package:test/test.dart';

void main() {
  test('should generate a simple tag with an id attribute', () async {
    final tag = _TestTag(attributes: {'id': 'test'});

    final result = tag.build();

    expect(result, '<test id="test"></test>');
    // final
  });

  test('should generate a tag with content and id attribute', () async {
    final tag = _TestTag(attributes: {'id': 'test'}, content: 'This is a test content');

    final result = tag.build();

    expect(result, '<test id="test">This is a test content</test>');
    // final
  });

  test('should generate a nested tag with proper indentation', () async {
    final tag = _TestTag(attributes: {
      'id': 'test'
    }, children: [
      _TestTag(
        attributes: {'id': 'another-test'},
        content: 'This is a test content',
      ),
    ]);

    final result = tag.build();

    print(result);

    expect(
        result,
        equals(
          '<test id="test">\n'
          '    <test id="another-test">This is a test content</test>\n'
          '</test>',
        ));
    // final
  });

  test('should generate deeply nested tags with multiple children and proper indentation', () async {
    final tag = _TestTag(
      attributes: {'id': 'test'},
      children: [
        _TestTag(attributes: {
          'id': 'another-test'
        }, children: [
          _TestTag(
            attributes: {'id': 'another-test'},
            content: 'This is a test content',
          ),
          _TestTag(
            attributes: {'id': 'another-test'},
            content: 'This is a test content',
          ),
          _TestTag(
            attributes: {'id': 'another-test'},
            content: 'This is a test content',
          ),
        ]),
        _TestTag(
          attributes: {'id': 'another-test'},
          content: 'This is a test content',
        ),
        _TestTag(
          attributes: {'id': 'another-test'},
          content: 'This is a test content',
        ),
      ],
    );

    final result = tag.build();

    // print(result);

    expect(
        result,
        equals(
          '<test id="test">\n'
          '    <test id="another-test">\n'
          '        <test id="another-test">This is a test content</test>\n'
          '        <test id="another-test">This is a test content</test>\n'
          '        <test id="another-test">This is a test content</test>\n'
          '    </test>\n'
          '    <test id="another-test">This is a test content</test>\n'
          '    <test id="another-test">This is a test content</test>\n'
          '</test>',
        ));
    // final
  });
}

class _TestTag extends Tag {
  _TestTag({
    super.attributes,
    super.children,
    super.content,
  });

  @override
  String get tagName => 'test';
}
