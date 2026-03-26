import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Application'),
      ),
      body: Container(
        child: const Text('About application will be here'),
      ),
    );
  }
}
