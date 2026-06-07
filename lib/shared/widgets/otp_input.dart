import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool autofocus;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.obscureText = false,
    this.autofocus = true,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _values = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      final chars = value.split('').take(widget.length).toList();
      for (int i = 0; i < chars.length; i++) {
        _controllers[i].text = chars[i];
        _values[i] = chars[i];
      }
      final nextIndex = chars.length < widget.length ? chars.length : widget.length - 1;
      _focusNodes[nextIndex].requestFocus();
    } else if (value.isNotEmpty) {
      _values[index] = value;
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      _values[index] = '';
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    final otp = _values.join();
    widget.onChanged?.call(otp);
    if (otp.length == widget.length && !_values.contains('')) {
      widget.onCompleted(otp);
    }
  }

  String _displayValue(int index) {
    if (_values[index].isEmpty) return '';
    return widget.obscureText ? '●' : _values[index];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        final isFilled = _values[index].isNotEmpty;
        final isFocused = _focusNodes[index].hasFocus;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 48,
          height: 58,
          decoration: BoxDecoration(
            color: isFocused
                ? AppColors.surface
                : isFilled
                    ? AppColors.surfaceVariant
                    : AppColors.white,
            border: Border.all(
              color: isFocused
                  ? AppColors.primary
                  : isFilled
                      ? AppColors.accent
                      : AppColors.divider,
              width: isFocused ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  autofocus: widget.autofocus && index == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: false,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.transparent,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) => _onChanged(v, index),
                ),
              ),
              Center(
                child: Text(
                  _displayValue(index),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class PinDisplay extends StatelessWidget {
  final int filledCount;
  final int total;

  const PinDisplay({
    super.key,
    required this.filledCount,
    this.total = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isFilled = index < filledCount;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: isFilled ? AppColors.surfaceVariant : AppColors.white,
            border: Border.all(
              color: isFilled ? AppColors.accent : AppColors.divider,
              width: isFilled ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isFilled
                ? Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}

class NumPad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final bool showSubmit;

  const NumPad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onSubmit,
    this.showSubmit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyKey(),
            const SizedBox(width: 16),
            _buildNumberKey('0'),
            const SizedBox(width: 16),
            _buildBackspaceKey(),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((k) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildNumberKey(k),
        );
      }).toList(),
    );
  }

  Widget _buildNumberKey(String number) {
    return GestureDetector(
      onTap: () => onKeyPressed(number),
      child: Container(
        width: 76,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: onBackspace,
      child: Container(
        width: 76,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyKey() {
    return const SizedBox(width: 76, height: 62);
  }
}
