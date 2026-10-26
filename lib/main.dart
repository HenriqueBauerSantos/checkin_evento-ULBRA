import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

const String nomeEvento = 'Semana da Computação 2026';

void main() => runApp(const CheckinApp());

// R1: app com tema próprio
class CheckinApp extends StatelessWidget {
  const CheckinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nomeEvento,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
        scaffoldBackgroundColor: const Color(0xFFF7FBFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00796B),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const PaginaCheckin(),
    );
  }
}

// Os três resultados possíveis da validação (R4)
enum TipoResultado { confirmado, jaFezCheckin, invalido }

// R1: uma única página (StatefulWidget)
class PaginaCheckin extends StatefulWidget {
  const PaginaCheckin({super.key});

  @override
  State<PaginaCheckin> createState() => _PaginaCheckinState();
}

class _PaginaCheckinState extends State<PaginaCheckin> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _scrollController = ScrollController();

  // Dados do ingresso gerado (null = ainda não gerou)
  String? _conteudoQr;
  String _ingressoNome = '';
  String _ingressoEmail = '';

  // Leitura
  bool _lendo = false; // true => mostra a câmera no lugar da página
  bool _jaLeu = false; // garante "lê uma vez só"

  // Resultado da última leitura
  TipoResultado? _resultado;
  String _mensagemResultado = '';

  // R5: lista de presença
  final List<String> _presentes = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- R2
  void _gerarIngresso() {
    // O separador do formato é "|", então removemos esse caractere dos campos
    final nome = _nomeController.text.trim().replaceAll('|', ' ');
    final email = _emailController.text.trim().replaceAll('|', ' ');
    setState(() {
      _ingressoNome = nome;
      _ingressoEmail = email;
      _conteudoQr = 'CHECKIN|$nome|$email';
    });
    FocusScope.of(context).unfocus();
  }

  // ---------------------------------------------------------------- R3
  void _iniciarLeitura() {
    setState(() {
      _jaLeu = false;
      _lendo = true;
    });
  }

  void _cancelarLeitura() {
    setState(() => _lendo = false); // volta sem ler nada
  }

  void _aoDetectar(BarcodeCapture captura) {
    if (_jaLeu) return; // a câmera pode disparar várias vezes: só a 1ª vale
    if (captura.barcodes.isEmpty) return;
    final codigo = captura.barcodes.first.rawValue;
    if (codigo == null) return;

    _jaLeu = true;
    _validar(codigo);
  }

  // ---------------------------------------------------------------- R4
  void _validar(String codigo) {
    final partes = codigo.split('|');
    final ingressoValido = partes.length == 3 &&
        partes[0] == 'CHECKIN' &&
        partes[1].trim().isNotEmpty;

    TipoResultado tipo;
    String mensagem;

    if (!ingressoValido) {
      tipo = TipoResultado.invalido;
      mensagem = 'Este QR code não é um ingresso do evento.';
    } else {
      final nome = partes[1].trim();
      if (_presentes.contains(nome)) {
        tipo = TipoResultado.jaFezCheckin;
        mensagem = nome;
      } else {
        _presentes.add(nome);
        tipo = TipoResultado.confirmado;
        mensagem = nome;
      }
    }

    setState(() {
      _resultado = tipo;
      _mensagemResultado = mensagem;
      _lendo = false; // volta para a página e mostra o resultado
    });

    // Depois de reconstruir a página, rola até o final para mostrar
    // o resultado e a lista de presença.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------------------------------------------------------------- UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(nomeEvento)),
      body: _corpo(),
    );
  }

  Widget _corpo() {
    // R3: troca a página pela câmera usando if (como na Aula 10)
    if (_lendo) {
      return _telaCamera();
    }
    return _telaPrincipal();
  }

  Widget _telaCamera() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // BoxFit.contain mostra a imagem inteira, centralizada
          Positioned.fill(
            child: Center(
              child: MobileScanner(
                fit: BoxFit.contain,
                onDetect: _aoDetectar,
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível abrir a câmera.\n'
                        'Verifique a permissão de câmera do app.\n\n'
                        '(${error.errorCode.name})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 24,
            child: Text(
              'Aponte para o QR do ingresso',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00796B),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _cancelarLeitura,
                child: const Text('Cancelar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _telaPrincipal() {
    return SafeArea(
      child: SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- R2: campos + botão
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do participante'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed:
                _nomeController.text.trim().isEmpty ? null : _gerarIngresso,
            child: const Text('Gerar ingresso'),
          ),
          const SizedBox(height: 16),

          // ---- R2: Card do ingresso (só aparece depois de gerar)
          if (_conteudoQr != null) _cardIngresso(),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ---- R3 / R4: check-in
          const Text(
            'Check-in',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _iniciarLeitura,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Ler ingresso'),
          ),
          const SizedBox(height: 12),
          if (_resultado != null) _cardResultado(),

          // ---- R5: lista de presença (contador + um Text por nome)
          const SizedBox(height: 20),
          Text(
            'Presentes (${_presentes.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_presentes.isEmpty)
                const Text('Ninguém fez check-in ainda.'),
              for (final nome in _presentes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('✔  $nome', style: const TextStyle(fontSize: 15)),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _cardIngresso() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          Image.asset(
            'assets/evento.png',
            height: 110,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _ingressoNome,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_ingressoEmail),
                const SizedBox(height: 12),
                // QR no formato CHECKIN|nome|e-mail
                QrImageView(
                  data: _conteudoQr!,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardResultado() {
    late final Color cor;
    late final Color fundo;
    late final String icone;
    late final String titulo;

    switch (_resultado!) {
      case TipoResultado.confirmado:
        cor = const Color(0xFF2E7D32);
        fundo = const Color(0xFFE8F5E9);
        icone = '✔';
        titulo = 'Check-in confirmado';
      case TipoResultado.jaFezCheckin:
        cor = const Color(0xFFE65100);
        fundo = const Color(0xFFFFF3E0);
        icone = '⚠';
        titulo = 'Já fez check-in';
      case TipoResultado.invalido:
        cor = const Color(0xFFC62828);
        fundo = const Color(0xFFFFEBEE);
        icone = '✖';
        titulo = 'QR inválido';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: cor, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(icone, style: TextStyle(fontSize: 30, color: cor)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_mensagemResultado, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
