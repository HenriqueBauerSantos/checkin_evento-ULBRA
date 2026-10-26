# App de Check-in de Evento (Flutter) — AP2

App de check-in em uma única página: o participante gera o ingresso com QR code; a organização lê o QR com a câmera, confirma a entrada e monta a lista de presença.

**Integrantes do grupo:**
- Nome 1
- Nome 2
- Nome 3

**Pacotes:** `qr_flutter ^4.1.0` e `mobile_scanner ^5.0.0`

## Prints

| Ingresso gerado | Câmera lendo | Check-in confirmado |
| --- | --- | --- |
| ![ingresso](prints/ingresso.png) | ![camera](prints/camera.png) | ![checkin](prints/checkin.png) |

> Coloque os 3 prints na pasta `prints/` com esses nomes.

## Requisitos atendidos

| Req. | Onde está em `lib/main.dart` |
| --- | --- |
| R1 Página + tema | `PaginaCheckin` (StatefulWidget), `ThemeData` em `CheckinApp`, AppBar com o nome do evento |
| R2 Ingresso | Dois `TextField`; `FilledButton` desabilitado com nome vazio; `_cardIngresso()` com imagem, nome, e-mail e `QrImageView` |
| R3 Leitura | `if (_lendo)` troca a página pelo `MobileScanner`; lê uma vez só (`_jaLeu`); botão Cancelar; permissões de câmera Android/iOS |
| R4 Validação | `_validar()` → ✔ confirmado, ⚠ já fez check-in, ✖ QR inválido |
| R5 Presença | `Text('Presentes (n)')` + um `Text` por nome dentro de uma `Column` |

**Formato do QR:** `CHECKIN|nome|e-mail` — ex.: `CHECKIN|Ana Souza|ana@email.com`.
Qualquer QR que não tenha 3 partes separadas por `|` começando com `CHECKIN` (um link, por exemplo) dá **✖ QR inválido**.

## Como rodar (resumo)

```bash
flutter create --platforms=android,ios --project-name checkin_evento .
dart run tool/configurar_permissoes.dart
flutter pub get
flutter run
```

Passo a passo completo (VS Code + emulador + webcam) no arquivo `PASSO_A_PASSO.md`.
