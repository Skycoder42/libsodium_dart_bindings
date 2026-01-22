extension UriX on Uri {
  Uri get withTrailingSlash {
    if (path.endsWith('/')) {
      return this;
    } else {
      return replace(path: '$path/');
    }
  }
}
