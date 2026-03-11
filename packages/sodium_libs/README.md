# sodium_libs
> **⚠️ &nbsp;THIS PACKAGE IS DEPRECATED**<br>
> Due to recent advancements in how dart handles native assets (more concrete the build hooks), this library is no
> longer required to use `sodium` in flutter applications.
>
> The replacement is straightforward: Simply reference `sodium` directly in your `pubspec.yaml` instead of
> `sodium_libs`. The build hooks will take care of the rest.
>
> See [sodium README](../sodium/README.md) for more details and check out the migration guide below for a step-by-step
> guide on how to transition from `sodium_libs` to `sodium`.

## Migrating to sodium
The migration is relatively easy, as the API of `sodium` remains unchanged. The main change is in how you reference the
library.

1. Replace the dependency in your `pubspec.yaml`:
   ```yaml
   dependencies:
     sodium_libs: ^<latest_version>
   ```
   with
   ```yaml
   dependencies:
     sodium: ^<latest_version>
   ```
2. Update all imports to reference `sodium` instead of `sodium_libs`:
   ```dart
   import 'package:sodium_libs/sodium_libs.dart';
   ```
   should be changed to
   ```dart
   import 'package:sodium/sodium.dart';
   ```
3. Run `flutter clean` and then `flutter pub get` to ensure no old build artifacts are causing any issues.

And thats it! Your application should now be using `sodium` directly, and you can take advantage of the latest features
and improvements without needing the `sodium_libs` package anymore.
