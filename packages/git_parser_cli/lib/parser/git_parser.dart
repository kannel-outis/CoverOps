/// A base class for parsing Git-related data.
/// 
/// Type parameter [T] represents the return type of the parsing operation.
abstract class GitParser<T> {
  /// Parses Git data and returns a result of type [T].
  /// 
  /// This method must be implemented by concrete subclasses to define
  /// specific parsing behavior.
  Future<T> parse();
}