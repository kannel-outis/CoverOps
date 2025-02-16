import 'package:html_gen/src/common_elements.dart';
import 'package:test/test.dart';

void main() {
  test('common elements should generate a properly structured HTML document with nested elements', () async {
    final html = HtmlTag(
      children: [
        HeadTag(
          children: [
            MetaTag(attributes: {'charset': 'UTF-8'}),
            MetaTag(attributes: {'name': 'viewport', 'content': 'width=device-width, initial-scale=1'}),
          ],
        ),
        BodyTag(
          children: [
            DivTag(
              attributes: {'class': 'container'},
              children: [
                PTag(content: 'Hello World!'),
                UlTag(
                  children: [
                    LiTag(content: 'Item 1'),
                    LiTag(content: 'Item 2'),
                    LiTag(
                      children: [
                        UlTag(
                          children: [
                            LiTag(content: 'Nested Item 3.1'),
                            LiTag(content: 'Nested Item 3.2'),
                          ],
                        )
                      ],
                    ),
                    LiTag(content: 'Item 4'),
                  ],
                ),
                BrTag(),
                ImgTag(attributes: {'src': 'image.jpg', 'alt': 'Sample Image'}),
              ],
            ),
          ],
        )
      ],
    );

    print(html.build());

    expect(html.build(), equals(
      '<html>\n'
      '    <head>\n'
      '        <meta charset="UTF-8" />\n'
      '        <meta name="viewport" content="width=device-width, initial-scale=1" />\n'
      '    </head>\n'
      '    <body>\n'
      '        <div class="container">\n'
      '            <p>Hello World!</p>\n'
      '            <ul>\n'
      '                <li>Item 1</li>\n'
      '                <li>Item 2</li>\n'
      '                <li>\n'
      '                    <ul>\n'
      '                        <li>Nested Item 3.1</li>\n'
      '                        <li>Nested Item 3.2</li>\n'
      '                    </ul>\n'
      '                </li>\n'
      '                <li>Item 4</li>\n'
      '            </ul>\n'
      '            <br />\n'
      '            <img src="image.jpg" alt="Sample Image" />\n'
      '        </div>\n'
      '    </body>\n'
      '</html>',
    ));
  });
}