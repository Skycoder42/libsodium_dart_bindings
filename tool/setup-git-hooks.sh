#!/bin/bash
set -eo pipefail

mkdir -p .git/hooks

cat << EOF > .git/hooks/pre-commit
#!/bin/bash
set -eo pipefail

pushd packages/sodium
dart run dart_pre_commit
popd

pushd packages/sodium_libs
flutter pub run dart_pre_commit
popd
EOF
chmod a+x .git/hooks/pre-commit
