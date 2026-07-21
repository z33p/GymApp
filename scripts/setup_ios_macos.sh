#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPEN_VSCODE=false
CLEAN=false

for arg in "$@"; do
  case "$arg" in
    --open) OPEN_VSCODE=true ;;
    --clean) CLEAN=true ;;
    -h|--help)
      echo "Uso: ./scripts/setup_ios_macos.sh [--clean] [--open]"
      echo "  --clean  remove o build Flutter antes de preparar o projeto"
      echo "  --open   abre o projeto no VS Code ao terminar"
      exit 0
      ;;
    *) echo "Argumento desconhecido: $arg" >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Este script precisa ser executado no macOS." >&2
  exit 1
fi

missing=()
for tool in flutter xcodebuild; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
if ((${#missing[@]} > 0)); then
  echo "Ferramentas ausentes: ${missing[*]}" >&2
  echo "Instale o Flutter e o Xcode Command Line Tools e execute novamente." >&2
  exit 1
fi

if ! command -v pod >/dev/null 2>&1; then
  echo "CocoaPods não encontrado. Instale-o com: brew install cocoapods" >&2
  exit 1
fi

cd "$ROOT_DIR"
if [[ "$CLEAN" == true ]]; then
  flutter clean
fi

echo "[1/3] Resolvendo dependências Flutter..."
flutter pub get
echo "[2/3] Instalando pods iOS..."
pod install --project-directory="$ROOT_DIR/ios"
echo "[3/3] Validando workspace..."
[[ -f "$ROOT_DIR/ios/Runner.xcworkspace/contents.xcworkspacedata" ]] || { echo "Workspace iOS não encontrado." >&2; exit 1; }

echo
echo "Projeto pronto. No VS Code, selecione um simulador/dispositivo e execute 'GymApp iOS (Debug)'."
echo "Alternativamente, execute: flutter run"

if [[ "$OPEN_VSCODE" == true ]]; then
  if command -v code >/dev/null 2>&1; then
    code "$ROOT_DIR"
  else
    echo "VS Code não está disponível no PATH; abra o projeto manualmente." >&2
  fi
fi
