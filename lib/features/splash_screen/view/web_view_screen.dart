import 'package:flutter/material.dart';
import 'package:ninjachiken/features/splash_screen/view/web_view_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _errorOccured = false;
  String _errorDescription = '';

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted:
                  (_) => setState(() {
                    _isLoading = true;
                    _errorOccured = false;
                  }),
              onPageFinished: (_) => setState(() => _isLoading = false),
              onNavigationRequest: (req) => NavigationDecision.navigate,
              onWebResourceError: (error) {
                setState(() {
                  _isLoading = false;
                  _errorOccured = true;
                  _errorDescription = error.description;
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    if (_errorOccured) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: WebViewAppBar(controller: _controller, mounted: mounted),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Ошибка загрузки страницы'),
              Text(_errorDescription),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorOccured = false;
                    _isLoading = true;
                  });
                  _controller.reload();
                },
                child: Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: WebViewAppBar(controller: _controller, mounted: mounted),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
