import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autofocus;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.autofocus = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscure = widget.obscureText;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : context.appColors.cardBgLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            color: _isFocused ? AppColors.primary : context.appColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: context.appColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: _isFocused ? 2 : 1.5),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText ? _obscure : false,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onSubmitted: widget.onSubmitted,
            textInputAction: widget.textInputAction,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 15,
              fontFamily: 'Nunito',
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle:
                  TextStyle(color: context.appColors.textMuted, fontSize: 15),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon,
                      color:
                          _isFocused ? AppColors.primary : context.appColors.textMuted,
                      size: 20)
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: context.appColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : widget.suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: '',
              filled: false,
            ),
          ),
        ),

        // Helper / Error text
        if (widget.errorText != null || widget.helper != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (hasError)
                const Icon(Icons.error_outline,
                    size: 13, color: AppColors.error),
              if (hasError) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText ?? widget.helper!,
                  style: TextStyle(
                    color: hasError ? AppColors.error : context.appColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
