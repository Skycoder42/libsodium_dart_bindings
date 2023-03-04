#!/bin/bash
set -exo pipefail

git clone https://github.com/flutter/flutter.git -b stable /opt/flutter

flutter config --no-analytics
flutter config --enable-linux-desktop
flutter config --enable-web

dart --disable-analytics
dart pub global activate melos
melos run pre-commit:init
