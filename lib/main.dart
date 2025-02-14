import 'package:flowcash/pages/home/historial_page.dart';
import 'package:flowcash/pages/home/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow Cash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flow Cash'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Inicio'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomePage(), 
            HistoricalPage(), 
          ],
        ),
      ),
    );
  }
}
