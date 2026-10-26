// Adiciona a permissão de câmera no Android e no iOS.
// Uso (na raiz do projeto, depois do "flutter create"):
//   dart run tool/configurar_permissoes.dart
import 'dart:io';

void main() {
  _android();
  _ios();
  stdout.writeln('\nPronto! Agora rode: flutter pub get');
}

void _android() {
  final f = File('android/app/src/main/AndroidManifest.xml');
  if (!f.existsSync()) {
    stderr.writeln('ERRO: $f não existe. Rode "flutter create" antes.');
    return;
  }
  var txt = f.readAsStringSync();
  if (txt.contains('android.permission.CAMERA')) {
    stdout.writeln('Android: permissão de câmera já estava configurada.');
    return;
  }
  const bloco = '''<uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    ''';
  // insere logo antes de <application
  txt = txt.replaceFirst('<application', '$bloco<application');
  f.writeAsStringSync(txt);
  stdout.writeln('Android: permissão de câmera adicionada.');
}

void _ios() {
  final f = File('ios/Runner/Info.plist');
  if (!f.existsSync()) {
    stderr.writeln('ERRO: $f não existe. Rode "flutter create" antes.');
    return;
  }
  var txt = f.readAsStringSync();
  if (txt.contains('NSCameraUsageDescription')) {
    stdout.writeln('iOS: permissão de câmera já estava configurada.');
    return;
  }
  const bloco = '''	<key>NSCameraUsageDescription</key>
	<string>A câmera é usada para ler o QR code do ingresso no check-in.</string>
''';
  final i = txt.lastIndexOf('</dict>');
  txt = txt.substring(0, i) + bloco + txt.substring(i);
  f.writeAsStringSync(txt);
  stdout.writeln('iOS: permissão de câmera adicionada.');
}
