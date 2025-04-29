import 'package:lcov_cli/generators/tags.dart';
import 'package:lcov_cli/models/line.dart';
import 'package:lcov_cli/utils/chain/chain_link.dart';

class CoveredStyle extends ChainLink<ChainLinkLine> {
  CoveredStyle();

  @override
  void handle(ChainMessage<ChainLinkLine> request, ChainLinkHandler<ChainLinkLine> handler) {
    late final String lineContent;
    if (request.data!.line.canHitLine != true) {
      lineContent = request.data!.line.lineContent;
      handler.next(
        request.of(
          data: ChainLinkLine(
            buffer: request.data!.buffer,
            line: request.data!.line.copyWith(
              lineContent: lineContent,
            ),
          ),
        ),
      );
      return;
    }
    if (request.data!.line.isLineHit) {
      lineContent = SpanTag(
        content: request.data!.line.lineContent,
        attributes: {'class': 'line-covered'},
      ).build();
    } else {
      lineContent = SpanTag(
        content: request.data!.line.lineContent,
        attributes: {'class': 'line-missed'},
      ).build();
    }
    handler.next(
      request.of(
        data: ChainLinkLine(
          buffer: request.data!.buffer,
          line: request.data!.line.copyWith(
            lineContent: lineContent,
          ),
        ),
      ),
    );
  }
}

class ModifiedStyle extends ChainLink<ChainLinkLine> {
  ModifiedStyle();

  @override
  void handle(ChainMessage<ChainLinkLine> request, ChainLinkHandler<ChainLinkLine> handler) {
    late final Line line = request.data!.line;

    final lineNumber = SpanTag(
      content: '${line.lineNumber.toString()}\t',
      attributes: {'class': line.isModified && line.canHitLine ? 'modified' : 'unmodified'},
    ).build();
    request.data!.buffer.write(SpanTag(
      content: '$lineNumber: ${line.lineContent}\n',
    ).build());
  }
}

class ChainLinkLine {
  final StringBuffer buffer;
  final Line line;

  ChainLinkLine({required this.buffer, required this.line});
}
