import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_styles.dart';

class OptionButton extends StatefulWidget {
  const OptionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isWrong,
    required this.isLocked,
    required this.isCorrectSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isWrong;
  final bool isLocked;
  final bool isCorrectSelected;

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton>
    with TickerProviderStateMixin {
  bool _showErrorFlash = false;
  bool _showSelectionGlow = false;

  late final AnimationController _pressController;
  late final AnimationController _tickController;
  late final Animation<double> _pressScale;
  late final Animation<double> _tickScale;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _pressScale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeOutCubic,
      ),
    );

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tickScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _tickController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(OptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWrong && !oldWidget.isWrong) {
      _triggerErrorFlash();
      setState(() => _showSelectionGlow = true);
    }
    if (widget.isCorrectSelected && !oldWidget.isCorrectSelected) {
      _tickController.forward(from: 0);
      setState(() => _showSelectionGlow = true);
    }
    if (!widget.isWrong &&
        !widget.isCorrectSelected &&
        (oldWidget.isWrong || oldWidget.isCorrectSelected)) {
      setState(() => _showSelectionGlow = false);
    }
  }

  Future<void> _triggerErrorFlash() async {
    setState(() => _showErrorFlash = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showErrorFlash = false);
    }
  }

  void _handleHighlightChanged(bool pressed) {
    if (widget.isLocked) {
      return;
    }
    if (pressed) {
      _pressController.forward();
    } else {
      _pressController.reverse();
    }
  }

  void _handleTap() {
    if (widget.isLocked) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _showSelectionGlow = true);
    widget.onTap();
  }

  Color _glowColor() {
    if (_showErrorFlash || widget.isWrong) {
      return AppStyles.error;
    }
    if (widget.isCorrectSelected) {
      return AppStyles.success;
    }
    return AppStyles.primary;
  }

  bool get _shouldGlow =>
      _showSelectionGlow || _showErrorFlash || widget.isCorrectSelected;

  @override
  void dispose() {
    _pressController.dispose();
    _tickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccessOption = widget.isCorrectSelected;
    final Color accent = _glowColor();

    final Color borderColor = _showErrorFlash
        ? AppStyles.error
        : isSuccessOption
            ? AppStyles.success
            : _showSelectionGlow
                ? AppStyles.primary.withValues(alpha: 0.45)
                : AppStyles.primary.withValues(alpha: 0.22);

    final Color backgroundColor = _showErrorFlash
        ? AppStyles.error.withValues(alpha: 0.08)
        : isSuccessOption
            ? AppStyles.success.withValues(alpha: 0.1)
            : _showSelectionGlow
                ? AppStyles.primary.withValues(alpha: 0.04)
                : Colors.white;

    return RepaintBoundary(
      child: Semantics(
        button: true,
        enabled: !widget.isLocked,
        label: widget.label,
        child: AnimatedBuilder(
          animation: _pressScale,
          builder: (context, child) {
            return Transform.scale(
              scale: _pressScale.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 58),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: borderColor,
                width: _shouldGlow || isSuccessOption ? 2.5 : 2,
              ),
              boxShadow: [
                if (_shouldGlow)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                BoxShadow(
                  color: accent.withValues(alpha: _shouldGlow ? 0.12 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: backgroundColor,
              elevation: 0,
              shadowColor: accent,
              surfaceTintColor: accent,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashFactory: InkRipple.splashFactory,
                splashColor: AppStyles.primary.withValues(alpha: 0.14),
                highlightColor: AppStyles.primary.withValues(alpha: 0.07),
                hoverColor: AppStyles.primary.withValues(alpha: 0.04),
                onHighlightChanged: _handleHighlightChanged,
                onTap: widget.isLocked ? null : _handleTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSuccessOption
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: _showErrorFlash
                            ? AppStyles.error
                            : isSuccessOption
                                ? AppStyles.success
                                : _showSelectionGlow
                                    ? AppStyles.primary
                                    : AppStyles.primary.withValues(alpha: 0.85),
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.isLocked && !isSuccessOption
                                ? AppStyles.textSecondary
                                : AppStyles.textPrimary,
                          ),
                        ),
                      ),
                      if (isSuccessOption)
                        ScaleTransition(
                          scale: _tickScale,
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppStyles.success,
                            size: 26,
                          ),
                        ),
                    ],
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
