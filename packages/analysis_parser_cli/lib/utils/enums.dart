enum AnalysisType {
  error('error'),
  warning('warn'),
  info('information'),
  hint('hint');

  final String alias;
  const AnalysisType(this.alias);

  static AnalysisType fromString(String? type) {
    return AnalysisType.values.firstWhere(
      (e) {
        final matchName = e.name.toLowerCase() == type?.toLowerCase();
        final matchAlias = e.alias.toLowerCase() == type?.toLowerCase();
        return matchName || matchAlias;
      },
      orElse: () => AnalysisType.error,
    );
  }
}
