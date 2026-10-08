import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class LegalWebViewScreen extends StatefulWidget {
  const LegalWebViewScreen({super.key, required this.slug});
  final String slug;
  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late WebViewController _controller;
  bool _loading = true;
  String? _error;
  String? _loadedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_loadedLanguage == language) return;
    _loadedLanguage = language;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _error = null;
          }),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() {
            _loading = false;
            _error = AppLocalizations.of(context).legalLoadFailed;
          }),
        ),
      )
      ..loadRequest(_pageUri(language));
  }

  Uri _pageUri(String language) {
    return Uri.parse(ApiConstants.baseUrl).replace(
      path: '/legal/page',
      queryParameters: {'slug': widget.slug, 'lang': language},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (widget.slug) {
      'terms' => l10n.legalTermsTitle,
      'privacy' => l10n.legalPrivacyTitle,
      'about' => l10n.legalAboutScreenTitle,
      _ => l10n.legalTermsTitle,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          if (_error == null) WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error case final error?)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pagePadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error, textAlign: TextAlign.center),
                    const SizedBox(height: AppDimensions.space3),
                    FilledButton(
                      onPressed: () =>
                          _controller.loadRequest(_pageUri(_loadedLanguage!)),
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
