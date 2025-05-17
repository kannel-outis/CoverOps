///
///
/// Interface representing a link in the chain of responsibility pattern.
abstract class ChainLink<T> {
  /// Reference to the next link in the chain.
  ChainLink<T>? _nextHandler;

  /// Handles the request object and potentially delegates to the next link.
  ///
  /// This method is called with a `ChainMessage` object containing the data
  /// and the current chain level. The handler can process the data and then
  /// call the `next` method on the `ChainLinkHandler` to continue processing
  /// in the chain, or stop processing if desired.
  void handle(ChainMessage<T> request, ChainLinkHandler<T> handler);
}

/// Class representing a message passed through the chain of responsibility.
class ChainMessage<T> {
  /// Private constructor to enforce factory pattern.
  ChainMessage._({this.chainLevel = 0, this.data});

  /// Current level (depth) within the chain of responsibility.
  final int chainLevel;

  /// Data associated with the message.
  final T? data;

  /// Creates a new `ChainMessage` with potentially modified data.
  ///
  /// This method allows for creating a new message with the same chain level
  /// but potentially different data.
  ChainMessage<T> of({T? data}) {
    return ChainMessage<T>._(data: data ?? this.data);
  }

  /// Private factory method for creating a new `ChainMessage` with optional
  /// chain level and data.
  ChainMessage<T> _of({int? chainLevel, T? data}) {
    return ChainMessage<T>._(chainLevel: chainLevel ?? this.chainLevel, data: data ?? this.data);
  }
}

/// Class representing the chain of responsibility itself.
class Chain<T> {
  /// Private constructor to enforce factory pattern.
  Chain._();

  /// Factory method to create a new `Chain` builder.
  factory Chain.builder() {
    return Chain<T>._();
  }

  /// Head (first link) of the chain.
  ChainLink<T>? _chainHead;

  /// Tail (last link) of the chain.
  ChainLink<T>? _chainLink;

  /// Adds a new link to the end of the chain.
  ///
  /// This method allows for building the chain by adding links sequentially.
  void then(ChainLink<T> link) {
    _chainHead ??= link;
    _chainLink?._nextHandler = link;
    _chainLink = link;
  }

  /// Builds and starts the chain of responsibility processing.
  ///
  /// This method initiates the chain processing by calling the `handle` method
  /// of the head link with an initial `ChainMessage` object.
  void build() {
    _chainHead?.handle(ChainMessage<T>._(), ChainLinkHandler<T>(_chainHead!));
  }
}

/// Class facilitating the flow of messages through the chain.
class ChainLinkHandler<T> {
  /// Constructor for `ChainHandler`.
  ChainLinkHandler(this._chainLink);

  /// Reference to the current chain link.
  final ChainLink<T> _chainLink;

  /// Passes the message to the next link in the chain.
  ///
  /// This method increments the chain level in the message and creates a new
  /// `ChainHandler` instance for the next link before calling the `handle`
  /// method of the next link.
  void next(ChainMessage<T> value) {
    final nextHandler = _chainLink._nextHandler;
    if (null == nextHandler) return;
    nextHandler.handle(value._of(chainLevel: value.chainLevel + 1), ChainLinkHandler(nextHandler));
  }
}
/// A root chain link that passes data through the chain of responsibility.
///
/// This link is typically used as the first link in a chain, providing
/// initial data to be processed by subsequent links in the chain.
///
/// [T] represents the type of data being passed through the chain.
class RootChainLink<T> extends ChainLink<T> {
  RootChainLink({required this.data});

  final T data;

  @override
  void handle(ChainMessage<T> request, ChainLinkHandler<T> handler) {
    handler.next(request.of(data: data));
  }
}
