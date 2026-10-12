import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/features/profile/providers/profile_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Edit-name dialog, in the same style as the change-password dialog.
/// Pops `true` once the name was saved. Errors show under the field.
class EditNameDialog extends ConsumerStatefulWidget {
  const EditNameDialog({super.key, required this.currentName});

  final String currentName;

  @override
  ConsumerState<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends ConsumerState<EditNameDialog> {
  late final _name = TextEditingController(text: widget.currentName);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _error = l10n.nameTooShort);
      return;
    }
    if (name == widget.currentName.trim()) {
      Navigator.pop(context, false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(profileControllerProvider.notifier).updateName(name);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error is ApiException
            ? error.localized(l10n)
            : l10n.profileUpdateFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editProfileTitle),
      content: TextField(
        controller: _name,
        autofocus: true,
        enabled: !_saving,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: l10n.fullName,
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}
