import 'package:lcov_cli/generators/tags.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/utils/chain/chain_link.dart';

abstract class StyleChainLink extends ChainLink<Line> {
  final StringBuffer buffer;

  StyleChainLink({required this.buffer});
}

class CoveredStyle extends StyleChainLink {
  CoveredStyle({required super.buffer});

  @override
  void handle(ChainMessage<Line> request, ChainLinkHandler<Line> handler) {
    late final String lineContent;
    if (request.data!.canHitLine != true) {
      lineContent = request.data!.lineContent;
      handler.next(request.of(data: request.data!.copyWith(lineContent: lineContent)));
      return;
    }
    if (request.data!.isLineHit) {
      lineContent = SpanTag(
        content: request.data!.lineContent,
        attributes: {'class': 'line-covered'},
      ).build();
    } else {
      lineContent = SpanTag(
        content: request.data!.lineContent,
        attributes: {'class': 'line-missed'},
      ).build();
    }
    handler.next(request.of(data: request.data!.copyWith(lineContent: lineContent)));
  }
}

class ModifiedStyle extends StyleChainLink {
  ModifiedStyle({required super.buffer});

  @override
  void handle(ChainMessage<Line> request, ChainLinkHandler<Line> handler) {
    late final Line line = request.data!;

    final lineNumber = SpanTag(
      content: '${line.lineNumber.toString()}\t',
      attributes: {'class': line.isModified && line.canHitLine ? 'modified' : 'unmodified'},
    ).build();
    buffer.write(SpanTag(
      content: '$lineNumber: ${line.lineContent}\n',
    ).build());
  }
}

class StyledLine {
  final Line line;
  final String styledLineContent;

  StyledLine({required this.line, required this.styledLineContent});
}
