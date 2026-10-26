# Passo a passo: abrir no VS Code, rodar e testar

## 0. Pré-requisitos (uma vez só)
- Flutter SDK instalado e no PATH (https://docs.flutter.dev/get-started/install)
- Android Studio instalado (precisa dele para o Android SDK e o emulador)
- VS Code com as extensões **Flutter** e **Dart**
- Rode `flutter doctor` no terminal e resolva o que aparecer em vermelho (aceite as licenças com `flutter doctor --android-licenses`)

## 1. Abrir o projeto
1. Extraia o `.zip` (não rode de dentro do zip).
2. VS Code → **File → Open Folder…** → escolha a pasta `checkin_evento`.
3. Abra o terminal: **Terminal → New Terminal** (ele já abre na pasta do projeto).

## 2. Gerar as pastas android/ e ios/ (uma vez só)
O zip traz o código; as pastas de plataforma são geradas pelo próprio Flutter, para bater com a **sua** versão instalada:

```bash
flutter create --platforms=android,ios --project-name checkin_evento .
```
(não esqueça do ponto no final; ele **não** sobrescreve o `lib/main.dart` nem o `pubspec.yaml`)

Se por algum motivo o `lib/main.dart` voltar ao exemplo do contador, é só copiar de novo o código do projeto original.

## 3. Aplicar as permissões de câmera (Android e iOS)
```bash
dart run tool/configurar_permissoes.dart
flutter pub get
```
O script adiciona:
- **Android** — em `android/app/src/main/AndroidManifest.xml`, antes de `<application`:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-feature android:name="android.hardware.camera" android:required="false" />
  ```
- **iOS** — em `ios/Runner/Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>A câmera é usada para ler o QR code do ingresso no check-in.</string>
  ```
(Se preferir, pode colar esses trechos manualmente.)

## 4. Criar o emulador Android (se ainda não tem)
1. VS Code: **Ctrl+Shift+P** → `Flutter: Launch Emulator` → escolha o emulador. Ou crie no Android Studio: **More Actions → Virtual Device Manager → Create Device** (ex.: Pixel 6, imagem do sistema recente, com Google APIs).
2. **Ativar a webcam como câmera do emulador** (para testar a leitura):
   Device Manager → ícone de lápis (**Edit**) do emulador → **Show Advanced Settings** → **Camera → Back → `Webcam0`** → **Finish**.
   Se o emulador já estava aberto, feche e abra de novo.

## 5. Rodar
1. Com o emulador aberto, olhe o canto inferior direito do VS Code: deve aparecer o nome do emulador (clique ali para escolher o dispositivo, se precisar).
2. Pressione **F5** (ou **Run → Start Debugging**), ou no terminal: `flutter run`.
3. A primeira execução demora alguns minutos (Gradle baixando dependências). As seguintes são rápidas.
4. Com o app rodando: `r` = hot reload, `R` = hot restart (no terminal).

## 6. Roteiro de teste (o mesmo da demonstração)
1. Digite **Nome** e **e-mail** → o botão **Gerar ingresso** só habilita com o nome preenchido (apague o nome e veja desabilitar).
2. Toque em **Gerar ingresso** → aparece o Card com imagem, nome, e-mail e o QR. *(Print 1)*
3. Toque em **Ler ingresso** → o app troca para a câmera; na primeira vez o Android pede permissão → **Permitir** (“Durante o uso do app”). *(Print 2)*
4. Aponte para um QR de ingresso:
   - no emulador, a “webcam” mostra o que a câmera do PC enxerga: coloque o QR **na tela de outro celular** (ou impresso) na frente da webcam;
   - ou, mais simples, use o **celular de verdade** (item 7).
5. Resultados esperados:
   - 1ª leitura de um ingresso → **✔ Check-in confirmado** e o nome entra em **Presentes (n)**. *(Print 3)*
   - O **mesmo** ingresso de novo → **⚠ Já fez check-in** (a lista não muda).
   - Um QR de **link** qualquer (ex.: gere um QR de `https://google.com` em qualquer gerador online) → **✖ QR inválido**.
6. **Cancelar** na tela da câmera volta à página sem ler nada.

> Dica: para testar sozinho, gere um QR com o texto `CHECKIN|Ana Souza|ana@email.com` em qualquer gerador de QR online e mostre à webcam (ou use o ingresso gerado pelo próprio app em outro celular).

## 7. Rodando no celular de verdade (melhor para a apresentação)
1. No celular Android: **Configurações → Sobre o telefone** → toque 7× em *Número da versão* → ative **Opções do desenvolvedor → Depuração USB**.
2. Conecte por cabo USB e aceite a autorização no celular.
3. No VS Code, escolha o celular no seletor de dispositivos (canto inferior direito) e pressione **F5**.

## 8. Problemas comuns
| Sintoma | Solução |
| --- | --- |
| `flutter` não é reconhecido | Flutter fora do PATH; reabra o VS Code/terminal depois de ajustar |
| Tela preta/erro ao abrir a câmera | Emulador sem webcam configurada (passo 4.2) ou permissão negada: Configurações do Android → Apps → checkin_evento → Permissões → Câmera |
| Erro de Gradle / `minSdkVersion` | Em `android/app/build.gradle(.kts)` use `minSdk = 21` (ou `minSdkVersion 21`) ou maior |
| Erro “Namespace not specified” ou JDK | Rode `flutter doctor -v` e use o JDK que o Android Studio traz |
| `Target of URI doesn't exist` no VS Code | Rode `flutter pub get` |
| iOS | Só roda em Mac com Xcode; o simulador de iOS **não tem câmera** |

## 9. Entrega (26/10)
1. Crie um repositório no GitHub e suba o projeto (`git init`, `git add .`, `git commit`, `git push`).
2. Edite o `README.md` com os **nomes do grupo** e coloque os 3 prints em `prints/`.
3. Treine a demonstração: ler ingresso do professor (✔), o mesmo de novo (⚠) e um link qualquer (✖).
