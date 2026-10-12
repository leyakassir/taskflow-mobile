import 'dart:async';

import 'package:flutter/material.dart';

import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// "Resend code" that waits [cooldown] after each send (the server ignores
/// earlier requests anyway), counting down meanwhile.
class ResendCodeButton extends StatefulWidget {
  const ResendCodeButton({
    super.key,
    required this.cooldown,
    required this.onResend,
  });

  final Duration cooldown;

  /// Returns when the request finished; the countdown restarts after it.
  final Future<void> Function() onResend;

  @override
  State<ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<ResendCodeButton> {
  Timer? _timer;
  late int _secondsLeft;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _secondsLeft = widget.cooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await widget.onResend();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _start();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final waiting = _secondsLeft > 0;
    return TextButton.icon(
      onPressed: waiting || _sending ? null : _resend,
      icon: _sending
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded, size: 18),
      label: Text(
        waiting ? l10n.resetResendIn(_secondsLeft) : l10n.resetResend,
      ),
    );
  }
}
