import 'package:flutter/material.dart';
import 'package:pdf_annotation_poc/pdf_screen.dart';
import 'package:pdf_annotation_poc/pdf_viewmodel.dart';
import 'package:provider/provider.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(create: (_) => PdfViewModel(), child: const MyApp()),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(debugShowCheckedModeBanner: false, home: PdfViewPage());
//   }
// }

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PdfViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PdfViewPage(),
    );
  }
}
