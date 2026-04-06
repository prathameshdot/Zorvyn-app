import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/config/theme.dart';

/// Convert any error object to a user-friendly message — never leaks exception details
String friendlyError(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is AppException) return error.message;
  return fallback;
}

/// Claymorphism card container
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 20,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppTheme.isDark(context);
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: AppTheme.clayCard(color: color ?? AppTheme.surfaceC(context), radius: radius, isDark: dark),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Primary gradient button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF8B83FF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(16),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const CupertinoActivityIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({super.key, required this.text, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clay-styled text field
class ClayTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const ClayTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              labelText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryC(context),
              ),
            ),
          ),
        Container(
          decoration: AppTheme.clayInset(),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(fontSize: 15, color: AppTheme.textPrimaryC(context)),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppTheme.textHintC(context), size: 20)
                  : null,
              suffixIcon: suffix,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black12,
            child: const Center(child: CupertinoActivityIndicator(radius: 16)),
          ),
      ],
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.clayCard(color: AppTheme.bgC(context)),
              child: Icon(icon, size: 48, color: AppTheme.textHintC(context)),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryC(context))),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondaryC(context))),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(text: buttonText!, onPressed: onButtonPressed),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error display widget
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.clayCard(color: AppTheme.bgC(context)),
              child: const Icon(CupertinoIcons.exclamationmark_triangle, size: 40, color: AppTheme.warning),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondaryC(context))),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryC(context))),
          if (actionText != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: onAction,
              child: Text(actionText!, style: const TextStyle(fontSize: 14, color: AppTheme.primary)),
            ),
        ],
      ),
    );
  }
}

/// Cupertino picker helper
void showCupertinoPicker({
  required BuildContext context,
  required List<String> items,
  required String selectedItem,
  required ValueChanged<String> onChanged,
}) {
  int selectedIndex = items.indexOf(selectedItem).clamp(0, items.length - 1);
  showCupertinoModalPopup(
    context: context,
    builder: (_) => Container(
      height: 280,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () {
                  onChanged(items[selectedIndex]);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: selectedIndex),
              onSelectedItemChanged: (i) => selectedIndex = i,
              children: items.map((item) {
                final display = item.replaceAll('_', ' ');
                return Center(
                  child: Text(
                    display.isEmpty ? '' : display[0].toUpperCase() + display.substring(1),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Cupertino date picker helper
void showCupertinoDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required ValueChanged<DateTime> onChanged,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  DateTime selected = initialDate;
  showCupertinoModalPopup(
    context: context,
    builder: (_) => Container(
      height: 300,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () {
                  onChanged(selected);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              initialDateTime: initialDate,
              minimumDate: minimumDate,
              maximumDate: maximumDate ?? DateTime.now().add(const Duration(days: 3650)),
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (d) => selected = d,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Snackbar helper — shows error/success as a subtle bar, never prints exception
void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: isError ? 3 : 2),
    ),
  );
}

/// Confirm dialog — iOS style
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  bool isDestructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: isDestructive,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Amount formatter
String formatAmount(double amount) {
  if (amount >= 100000) {
    return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '\u20B9${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
}

/// Category icon helper
IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return CupertinoIcons.cart;
    case 'transport':
      return CupertinoIcons.car;
    case 'shopping':
      return CupertinoIcons.bag;
    case 'entertainment':
      return CupertinoIcons.film;
    case 'bills':
      return CupertinoIcons.doc_text;
    case 'health':
      return CupertinoIcons.heart;
    case 'education':
      return CupertinoIcons.book;
    case 'travel':
      return CupertinoIcons.airplane;
    case 'groceries':
      return CupertinoIcons.cart_fill;
    case 'rent':
      return CupertinoIcons.house;
    case 'utilities':
      return CupertinoIcons.bolt;
    case 'subscriptions':
      return CupertinoIcons.creditcard;
    case 'salary':
      return CupertinoIcons.money_dollar;
    case 'freelance':
      return CupertinoIcons.desktopcomputer;
    case 'investment':
      return CupertinoIcons.graph_square;
    case 'business':
      return CupertinoIcons.briefcase;
    case 'gift':
      return CupertinoIcons.gift;
    case 'refund':
      return CupertinoIcons.arrow_counterclockwise;
    default:
      return CupertinoIcons.ellipsis;
  }
}

/// Category color helper
Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color(0xFFFF6B6B);
    case 'transport':
      return const Color(0xFF4ECDC4);
    case 'shopping':
      return const Color(0xFFFFD93D);
    case 'entertainment':
      return const Color(0xFF6C63FF);
    case 'bills':
      return const Color(0xFFFF8E72);
    case 'health':
      return const Color(0xFFFF6B9D);
    case 'education':
      return const Color(0xFF45B7D1);
    case 'travel':
      return const Color(0xFF96CEB4);
    case 'groceries':
      return const Color(0xFFFFA07A);
    case 'rent':
      return const Color(0xFF9B59B6);
    case 'utilities':
      return const Color(0xFFF39C12);
    case 'subscriptions':
      return const Color(0xFF1ABC9C);
    case 'salary':
      return const Color(0xFF2ECC71);
    case 'freelance':
      return const Color(0xFF3498DB);
    case 'investment':
      return const Color(0xFF27AE60);
    case 'business':
      return const Color(0xFF8E44AD);
    case 'gift':
      return const Color(0xFFE74C3C);
    case 'refund':
      return const Color(0xFF95A5A6);
    default:
      return const Color(0xFFBDC3C7);
  }
}

/// Skeleton loading card — simple shimmer placeholder
class SkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;

  const SkeletonCard({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final dark = AppTheme.isDark(context);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: dark ? AppTheme.surfaceAltDark : AppTheme.dividerC(context),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
