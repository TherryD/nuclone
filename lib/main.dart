import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const NuCloneApp());
}

class NuCloneApp extends StatefulWidget {
  const NuCloneApp({super.key});

  @override
  State<NuCloneApp> createState() => _NuCloneAppState();
}

class _NuCloneAppState extends State<NuCloneApp> {
  // Alternância de Tema (Roxo Claro / Roxo Escuro)
  // Estado que armazena a preferência de tema atual do aplicativo
  bool _isDarkTheme = false;

  void _alternarTema() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Configuração de paleta de cores correspondente a cada modo visual
    final themeData = _isDarkTheme
        ? ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF4A148C),
      scaffoldBackgroundColor: const Color(0xFF1E102F),
      cardColor: const Color(0xFF2C1B42),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF2C1B42)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8A05BE),
        brightness: Brightness.dark,
      ),
    )
        : ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF8A05BE),
      scaffoldBackgroundColor: const Color(0xFFF0F1F5),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF8A05BE)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8A05BE),
        brightness: Brightness.light,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nubank Clone & NuGame',
      theme: themeData,
      home: NuBankHomePage(
        isDarkTheme: _isDarkTheme,
        onToggleTheme: _alternarTema,
      ),
    );
  }
}

class NuBankHomePage extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const NuBankHomePage({
    super.key,
    required this.isDarkTheme,
    required this.onToggleTheme,
  });

  @override
  State<NuBankHomePage> createState() => _NuBankHomePageState();
}

class _NuBankHomePageState extends State<NuBankHomePage> {
  // Saldo principal da conta bancária
  double _saldoConta = 1500.00;

  // Declaração dos Controllers e FocusNodes
  // Usamos 'late' para inicializá-los com segurança dentro do initState
  late TextEditingController _valorController;
  late TextEditingController _pixController;
  late FocusNode _valorFocusNode;
  late FocusNode _pixFocusNode;

  String? _erroValor;

  // Variáveis de controle de altura para o gesto de arrastar (Drag)
  double _alturaFatura = 120.0;
  final double _alturaMin = 120.0;
  final double _alturaMax = 220.0;

  @override
  void initState() {
    super.initState();
    // (initState): Inicialização obrigatória de controladores de texto e nós de foco
    _valorController = TextEditingController();
    _pixController = TextEditingController();
    _valorFocusNode = FocusNode();
    _pixFocusNode = FocusNode();

    // Listener para validação de saldo e valores em tempo real sem recarregar a tela
    _valorController.addListener(_validarValorTransferencia);
  }

  @override
  void dispose() {
    // (dispose): Descarte de controladores e FocusNodes para evitar Memory Leak
    _valorController.removeListener(_validarValorTransferencia);
    _valorController.dispose();
    _pixController.dispose();
    _valorFocusNode.dispose();
    _pixFocusNode.dispose();
    super.dispose();
  }

  // Validação: Atualiza a mensagem vermelha de erro sem recarregar toda a tela
  void _validarValorTransferencia() {
    final texto = _valorController.text.trim();
    if (texto.isEmpty) {
      if (_erroValor != null) setState(() => _erroValor = null);
      return;
    }

    final valor = double.tryParse(texto.replaceAll(',', '.'));
    if (valor == null) {
      setState(() => _erroValor = 'Digite um valor numérico válido.');
    } else if (valor > _saldoConta) {
      setState(() => _erroValor = 'Saldo insuficiente para esta transferência!');
    } else {
      if (_erroValor != null) setState(() => _erroValor = null);
    }
  }

  void _executarTransferencia() {
    final valor = double.tryParse(_valorController.text.trim().replaceAll(',', '.'));
    if (_erroValor == null && valor != null && valor > 0 && _pixController.text.isNotEmpty) {
      setState(() {
        _saldoConta -= valor;
        _valorController.clear();
        _pixController.clear();
      });

      // Fecha o teclado ao submeter a transferência
      _valorFocusNode.unfocus();
      _pixFocusNode.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIX de R\$ ${valor.toStringAsFixed(2)} realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Injeção direta e em tempo real dos ganhos no saldo da conta
  void _receberRecompensaGame(double premio) {
    setState(() {
      _saldoConta += premio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, Usuário Nu', style: TextStyle(color: Colors.white)),
        actions: [
          // Botão no cabeçalho para alternar a paleta visual
          IconButton(
            icon: Icon(
              widget.isDarkTheme ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: Colors.white,
            ),
            tooltip: 'Alternar tema',
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card do Saldo em Conta
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('R\$ ${_saldoConta.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GestureDetector com Drag Vertical (onPanUpdate)
              // Permite ao usuário arrastar verticalmente a fatura para expandir ou recolher detalhes
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _alturaFatura += details.delta.dy;
                    // Limita a altura entre os valores mínimo e máximo permitidos
                    if (_alturaFatura < _alturaMin) _alturaFatura = _alturaMin;
                    if (_alturaFatura > _alturaMax) _alturaFatura = _alturaMax;
                  });
                },
                child: Container(
                  height: _alturaFatura,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8A05BE), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.credit_card, color: Color(0xFF8A05BE)),
                              SizedBox(width: 8),
                              Text('Cartão de Crédito', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Icon(Icons.drag_handle, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Fatura atual: R\$ 420,80', style: TextStyle(fontSize: 16)),
                      // Exibição condicional de detalhes extras ao expandir o card
                      if (_alturaFatura > 140) ...[
                        const Divider(),
                        const Text('Limite disponível: R\$ 2.500,00', style: TextStyle(color: Colors.green)),
                        const Text('Melhor dia de compra: dia 12', style: TextStyle(color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Keyboard Focus System (FocusNode & FocusScope)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Área Pix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _valorController,
                        focusNode: _valorFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Valor da Transferência (R\$)',
                          border: const OutlineInputBorder(),
                          errorText: _erroValor,
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        // Avança o foco do cursor para o campo de chave PIX automaticamente
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_pixFocusNode);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pixController,
                        focusNode: _pixFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Chave PIX (CPF, E-mail, Telefone)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Feedback Visual com efeito cascata (Ripple Effect)
                      // O widget Material é essencial como pai para permitir o efeito gráfico do InkWell
                      Material(
                        color: const Color(0xFF8A05BE),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.purpleAccent,
                          onTap: _executarTransferencia,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Center(
                              child: Text(
                                'Realizar PIX',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Otimização de Estado (setState isolado)
              // O minigame vive em um widget separado para não reconstruir o formulário ou a tela inteira a cada frame/tick
              NuGameWidget(onGanho: _receberRecompensaGame),
            ],
          ),
        ),
      ),
    );
  }
}

/// REQUISITO 4 & NUGAME: Componente isolado para conter os estados efêmeros do jogo
class NuGameWidget extends StatefulWidget {
  final ValueChanged<double> onGanho;

  const NuGameWidget({super.key, required this.onGanho});

  @override
  State<NuGameWidget> createState() => _NuGameWidgetState();
}

class _NuGameWidgetState extends State<NuGameWidget> {
  // Temporizador do jogo
  Timer? _timer;
  int _tempoRestante = 10;
  bool _jogoAtivo = false;
  int _moedasColetadas = 0;

  @override
  void dispose() {
    // NUGAME CICLO DE VIDA RESTRITO: O Timer PRECISA ser cancelado no dispose()
    // para evitar travamento da aplicação ou Memory Leak caso a tela seja fechada
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarJogo() {
    setState(() {
      _jogoAtivo = true;
      _tempoRestante = 10;
      _moedasColetadas = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Prevenção extra: só altera o estado se o widget ainda estiver montado na árvore
      if (!mounted) return;
      setState(() {
        if (_tempoRestante > 1) {
          _tempoRestante--;
        } else {
          _tempoRestante = 0;
          _jogoAtivo = false;
          timer.cancel();
        }
      });
    });
  }

  void _coletarMoeda() {
    if (!_jogoAtivo) return;

    const valorPorMoeda = 5.0;
    //  Propaga o valor adquirido para a tela principal em tempo real
    widget.onGanho(valorPorMoeda);

    setState(() {
      _moedasColetadas++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_esports, color: Color(0xFF8A05BE)),
                SizedBox(width: 8),
                Text('NuGame: Caça-Rendimentos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _jogoAtivo
                  ? 'Toque na moeda rápido! Tempo: ${_tempoRestante}s'
                  : 'Toque para iniciar e faturar R\$ 5,00 por clique!',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (!_jogoAtivo) ...[
              ElevatedButton.icon(
                onPressed: _iniciarJogo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A05BE),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.play_arrow),
                label: Text(_tempoRestante == 0 ? 'Jogar Novamente' : 'Iniciar NuGame'),
              ),
              if (_moedasColetadas > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Última rodada: R\$ ${(_moedasColetadas * 5.0).toStringAsFixed(2)} injetados na conta!',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
            ] else ...[
              // Componente clicável com feedback tátil/visual (Material + InkWell circular)
              Material(
                color: Colors.amber[100],
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Colors.amberAccent,
                  onTap: _coletarMoeda,
                  child: const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Icon(Icons.monetization_on, size: 54, color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Moedas resgatadas: $_moedasColetadas',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ],
        ),
      ),
    );
  }
}