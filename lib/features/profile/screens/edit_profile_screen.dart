import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/core/widgets/loading_indicator.dart';
import 'package:taskflow_mobile/features/profile/providers/profile_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).editProfileTitle),
      ),
      body: profile.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error is ApiException
              ? error.localized(AppLocalizations.of(context))
              : AppLocalizations.of(context).profileLoadFailed,
          onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
        ),
        data: (value) {
          if (!_initialized) {
            _nameController.text = value.fullName;
            _initialized = true;
          }
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).fullName,
                ),
              ),
              const SizedBox(height: AppDimensions.space5),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalizations.of(context).saveChanges),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      _message(AppLocalizations.of(context).nameTooShort);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).updateName(name);
      if (mounted) context.pop(true);
    } catch (error) {
      if (!mounted) return;
      _message(
        error is ApiException
            ? error.localized(AppLocalizations.of(context))
            : AppLocalizations.of(context).profileUpdateFailed,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
