# HTMLGen

HTMLGen is a Dart package that provides an object-oriented approach to generating HTML markup.

## Features

- Generate HTML using Dart objects.
- Supports attributes, content, and nested tags.
- Handles both self-closing and non-self-closing tags.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  html_gen:
    git:
      url: https://github.com/kannel-outis/CodeOps.git
      path: html_gen
```

Run:

```bash
dart pub get
```

## Usage

Create HTML markup programmatically:

```dart
import 'html_gen.dart';

void main() {
  final html = HtmlTag(
    children: [
      HeadTag(children: [MetaTag(attributes: {'charset': 'UTF-8'})]),
      BodyTag(
        children: [
          PTag(content: 'Hello World!'),
          UlTag(
            children: [
              LiTag(content: 'Item 1'),
              LiTag(content: 'Item 2'),
              LiTag(children: [
                UlTag(children: [
                  LiTag(content: 'Nested Item 3.1'),
                  LiTag(content: 'Nested Item 3.2'),
                ])
              ]),
            ],
          ),
        ],
      ),
    ],
  );

  print(html.generate());
}
```

### Output:

```html
<html>
  <head>
    <meta charset="UTF-8" />
  </head>
  <body>
    <p>Hello World!</p>
    <ul>
      <li>Item 1</li>
      <li>Item 2</li>
      <li>
        <ul>
          <li>Nested Item 3.1</li>
          <li>Nested Item 3.2</li>
        </ul>
      </li>
    </ul>
  </body>
</html>
```

## License

MIT

