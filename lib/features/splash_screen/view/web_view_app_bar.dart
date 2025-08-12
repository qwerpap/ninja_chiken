import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';

class WebViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final WebViewController controller;
  final bool mounted;

  const WebViewAppBar({
    super.key,
    required this.controller,
    required this.mounted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
          } else {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              );
            }
          }
        },
      ),
      title: const Text(
        'Loading...',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () => controller.reload(),
        ),
        IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              );
            }
          },
        ),
      ],
    );
  }
}
