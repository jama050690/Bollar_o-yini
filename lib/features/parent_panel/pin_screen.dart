import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import 'parent_settings.dart';

enum _PinStep { enter, create, confirm }

/// Ota-ona paneliga kirish (FR-6).
/// PIN yo'q bo'lsa — yangi PIN ikki marta kiritib o'rnatiladi.
/// [changePin] — paneldan "PIN ni o'zgartirish" orqali ochilganda.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key, this.changePin = false});

  final bool changePin;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  late _PinStep _step;
  String _input = '';
  String? _firstPin;
  String? _error;

  @override
  void initState() {
    super.initState();
    final hasPin = ref.read(parentSettingsProvider).hasPin;
    _step = hasPin && !widget.changePin ? _PinStep.enter : _PinStep.create;
  }

  String get _title => switch (_step) {
        _PinStep.enter => AppStrings.pinEnter,
        _PinStep.create => AppStrings.pinCreate,
        _PinStep.confirm => AppStrings.pinConfirm,
      };

  void _onDigit(String digit) {
    if (_input.length >= kPinLength) return;
    setState(() {
      _input += digit;
      _error = null;
    });
    if (_input.length == kPinLength) _submit();
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _submit() {
    final pin = _input;
    final settings = ref.read(parentSettingsProvider.notifier);

    switch (_step) {
      case _PinStep.enter:
        if (settings.checkPin(pin)) {
          _openPanel();
        } else {
          setState(() {
            _input = '';
            _error = AppStrings.pinWrong;
          });
        }
      case _PinStep.create:
        setState(() {
          _firstPin = pin;
          _input = '';
          _step = _PinStep.confirm;
        });
      case _PinStep.confirm:
        if (pin != _firstPin) {
          setState(() {
            _firstPin = null;
            _input = '';
            _step = _PinStep.create;
            _error = AppStrings.pinMismatch;
          });
          return;
        }
        settings.setPin(pin);
        if (widget.changePin) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text(AppStrings.pinChanged)));
          context.pop();
        } else {
          _openPanel();
        }
    }
  }

  void _openPanel() {
    ref.read(parentUnlockedProvider.notifier).unlock();
    // go (push emas): vaqt holati o'zgarib router qayta tekshirganda
    // panel asosiy manzil bo'lib qolishi kerak, aks holda yopilib qoladi.
    context.go(AppRoutes.parentPanel);
  }

  Future<void> _onForgot() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _AdultQuestionDialog(),
    );
    if (ok != true || !mounted) return;
    ref.read(parentSettingsProvider.notifier).resetPin();
    setState(() {
      _input = '';
      _firstPin = null;
      _error = null;
      _step = _PinStep.create;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.parentPanelTitle),
        leading: CloseButton(onPressed: _close),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _PinDots(filled: _input.length),
                SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      _error ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                  ),
                ),
                _Keypad(onDigit: _onDigit, onDelete: _onDelete),
                const SizedBox(height: 16),
                if (_step == _PinStep.enter)
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _onForgot,
                    child: const Text(AppStrings.pinForgot),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kPinLength; i++)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? AppColors.primary : Colors.transparent,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
          ),
      ],
    );
  }
}

/// Katta raqam tugmalari (NFR-1: kamida 64 dp).
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onDelete});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final key in row) _key(key)],
          ),
      ],
    );
  }

  Widget _key(String key) {
    const size = 80.0;
    if (key.isEmpty) return const SizedBox(width: size + 16, height: size + 16);

    final isDelete = key == '⌫';
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Semantics(
        label: isDelete ? AppStrings.pinDelete : key,
        button: true,
        excludeSemantics: true,
        child: Material(
          color: isDelete ? Colors.transparent : Colors.white,
          shape: const CircleBorder(),
          elevation: isDelete ? 0 : 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isDelete ? onDelete : () => onDigit(key),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Text(
                  key,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "PIN ni unutdim": kattalar uchun oddiy savol (bola tasodifan ochmasligi uchun).
class _AdultQuestionDialog extends StatefulWidget {
  const _AdultQuestionDialog();

  @override
  State<_AdultQuestionDialog> createState() => _AdultQuestionDialogState();
}

class _AdultQuestionDialogState extends State<_AdultQuestionDialog> {
  final _random = Random();
  final _controller = TextEditingController();
  late final int _a = 6 + _random.nextInt(4);
  late final int _b = 6 + _random.nextInt(4);
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    if (int.tryParse(_controller.text.trim()) == _a * _b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.adultQuestion(_a, _b)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          hintText: AppStrings.adultAnswerHint,
          errorText: _wrong ? AppStrings.adultWrong : null,
        ),
        onSubmitted: (_) => _check(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(onPressed: _check, child: const Text(AppStrings.confirm)),
      ],
    );
  }
}
