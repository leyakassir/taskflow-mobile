import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/about/widgets/web_page_title.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// In-app browser for the legal pages edited in the admin dashboard
/// (served by the backend at /legal/page). Looks like a browser: page
/// title with the site address, a loading bar, reload and "Open in
/// browser". Links inside the page work, and Back steps back through them
/// before closing the screen.
class LegalWebViewScreen extends StatefulWidget {
  const LegalWebViewScreen({super.key, required this.slug});
  final String slug;
  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late WebViewController _controller;
  late Uri _currentUrl;
  String? _loadedLanguage;
  String? _pageTitle;
  double _progress = 0;
  bool _failed = false;
  bool _canGoBack = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_loadedLanguage == language) return;
    _loadedLanguage = language;
    _currentUrl = _pageUri(language);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() {
            _failed = false;
            _progress = 0;
            _currentUrl = Uri.tryParse(url) ?? _currentUrl;
          }),
          onProgress: (percent) => setState(() => _progress = percent / 100),
          onPageFinished: (_) => _onPageFinished(),
          onWebResourceError: (error) {
            // Only a failure of the page itself counts, not e.g. a favicon.
            if (error.isForMainFrame ?? true) setState(() => _failed = true);
          },
        ),
      )
      ..loadRequest(_currentUrl);
  }

  Uri _pageUri(String language) => Uri.parse(ApiConstants.baseUrl).replace(
    path: '/legal/page',
    queryParameters: {'slug': widget.slug, 'lang': language},
  );

  Future<void> _onPageFinished() async {
    final title = await _controller.getTitle();
    final canGoBack = await _controller.canGoBack();
    if (!mounted) return;
    setState(() {
      _progress = 1;
      _canGoBack = canGoBack;
      if (title != null && title.trim().isNotEmpty) _pageTitle = title.trim();
    });
  }

  Future<void> _reload() async {
    setState(() => _failed = false);
    await _controller.loadRequest(_currentUrl);
  }

  Future<void> _openInBrowser() async {
    final opened = await launchUrl(
      _currentUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).legalOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fallbackTitle = switch (widget.slug) {
      'terms' => l10n.legalTermsTitle,
      'privacy' => l10n.legalPrivacyTitle,
      'about' => l10n.legalAboutScreenTitle,
      _ => l10n.legalTermsTitle,
    };
    final loading = !_failed && _progress < 1;

    return PopScope(
      // Back goes back inside the page first, like a browser.
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _controller.goBack();
        final canGoBack = await _controller.canGoBack();
        if (mounted) setState(() => _canGoBack = canGoBack);
      },
      child: Scaffold(
        appBar: AppBar(
          title: WebPageTitle(
            title: _pageTitle ?? fallbackTitle,
            url: _currentUrl,
          ),
          actions: [
            IconButton(
              tooltip: l10n.legalReload,
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: l10n.legalOpenInBrowser,
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser_rounded),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: AnimatedOpacity(
              opacity: loading ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 2,
              ),
            ),
          ),
        ),
        body: _failed
            ? ErrorView(message: l10n.legalLoadFailed, onRetry: _reload)
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
