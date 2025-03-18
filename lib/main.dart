import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rive Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// **現在選択されている Artboard**
  String _selectedArtboard =
      "CatIdle"; // ✅ キャラ(猫、犬)のモーション(Idle, Sleep等)ごとにArtboardの切り替え

  /// Riveアニメーションのコントローラー
  SMIInput<double>? _effect;
  SMIInput<double>? _color;
  SMIInput<double>? _emotion;
  SMIInput<bool>? _loop;

  /// UIの状態管理
  double _selectedEffect = 0.0;
  double _selectedColor = 0.0;
  double _selectedEmotion = 0.0;
  bool _isLooping = false;

  StateMachineController? controller;

  /// Rive 初期化処理
  void _onRiveInit(Artboard artboard) {
    controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );

    if (controller == null) {
      debugPrint("❌ State Machine Controller not found.");
      return;
    }

    artboard.addController(controller!);

    _effect = controller?.findInput<double>('Effect') as SMINumber?;
    _color = controller?.findInput<double>('Color') as SMINumber?;
    _emotion = controller?.findInput<double>('Emotion') as SMINumber?;
    _loop = controller?.findInput<bool>('Loop') as SMIBool?;

    debugPrint("🔍 Effect Input: $_effect");
    debugPrint("🔍 Color Input: $_color");
    debugPrint("🔍 Emotion Input: $_emotion");
    debugPrint("🔍 Loop Input: $_loop");

    if (_effect == null ||
        _color == null ||
        _emotion == null ||
        _loop == null) {
      debugPrint("❌ One or more inputs are NULL! Check Rive file.");
    } else {
      debugPrint("✅ Inputs initialized successfully.");
    }

    // ✅ 初期値を設定
    _effect?.change(0.0);
    _color?.change(0.0);
    _emotion?.change(0.0);
    _loop?.change(false);
  }

  /// **Artboard の切り替え**
  void _changeArtboard(String artboardName) {
    setState(() {
      _selectedArtboard = artboardName;
    });

    debugPrint("🎨 Artboard switched to: $_selectedArtboard");

    // ✅ `Loop` の状態を復元
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_loop != null) {
        _loop!.change(_isLooping);
        debugPrint("🔄 Restored Loop: $_isLooping");
      }
    });
  }

  /// ✅ Loop をチェックボックスで切り替え
  void _toggleLoop(bool? value) {
    if (_loop == null) {
      debugPrint("❌ _loop is NULL. Check Rive initialization.");
      return;
    }

    setState(() {
      _isLooping = value ?? false;
    });

    debugPrint("🔄 Loop toggled: $_isLooping");
    _loop!.change(_isLooping);
  }

  /// ユーザーが値を変更した時の処理
  void _updateEffect(double value) {
    if (_effect == null) {
      debugPrint("❌ _effect is NULL. Check Rive initialization.");
      return;
    }

    debugPrint("🟡 _updateEffect called with value: $value");

    setState(() {
      _selectedEffect = value; // ラジオボタンの更新
    });
    _effect?.change(value); // Riveの更新

    debugPrint("✅ Effect updated: ${_effect!.value}");
  }

  void _updateColor(double value) {
    setState(() {
      _selectedColor = value; // ラジオボタンの更新
    });
    _color?.change(value); // Riveの更新
  }

  void _updateEmotion(double value) {
    setState(() {
      _selectedEmotion = value; // ラジオボタンの更新
    });
    _emotion?.change(value); // Riveの更新
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// **アートボードを切り替えるドロップダウン**
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedArtboard,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _changeArtboard(newValue);
                  }
                },
                items: <String>['CatIdle', 'DogIdle']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            /// **Rive アニメーション**
            SizedBox(
              width: double.infinity,
              height: 300,
              child: RiveAnimation.asset(
                'assets/sample.riv',
                artboard: _selectedArtboard,
                onInit: _onRiveInit,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            _buildRadioGroup(
              title: 'Effect',
              values: [0.0, 1.0, 2.0],
              selectedValue: _selectedEffect,
              onChanged: _updateEffect,
            ),
            _buildRadioGroup(
              title: 'Color',
              values: [0.0, 1.0, 2.0, 3.0],
              selectedValue: _selectedColor,
              onChanged: _updateColor,
            ),
            _buildRadioGroup(
              title: 'Emotion',
              values: [0.0, 1.0],
              selectedValue: _selectedEmotion,
              onChanged: _updateEmotion,
            ),
            const SizedBox(height: 20),
            _buildLoopToggle(), // ✅ Loop のチェックボックスを追加
          ],
        ),
      ),
    );
  }

  /// **Loop 切り替えチェックボックス**
  Widget _buildLoopToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _isLooping,
          onChanged: _toggleLoop,
        ),
        const Text("Loop"),
      ],
    );
  }

  /// **横並びのラジオボタングループを作成**
  Widget _buildRadioGroup({
    required String title,
    required List<double> values,
    required double selectedValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 横スクロール可能にする
            child: Row(
              children: values
                  .map((value) => Row(
                        children: [
                          Radio<double>(
                            value: value,
                            groupValue: selectedValue,
                            onChanged: (v) {
                              if (v != null) {
                                onChanged(v);
                              }
                            },
                          ),
                          Text('$value'),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
