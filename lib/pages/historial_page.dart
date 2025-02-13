import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricalPage extends StatefulWidget {
  const HistoricalPage({super.key});

  @override
  _HistoricalPageState createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  List<Map<String, dynamic>> expenses = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    

    // Cargar los gastos guardados
    final String? compactString = prefs.getString('expenses');
    debugPrint('Gastos guardados: $compactString');

    if (compactString != null) {
      List<String> compactExpenses = compactString.split(';');
      setState(() {
        expenses = compactExpenses.map((expense) {
          final parts = expense.split(':');
          return {
            'type': parts[0],
            'detail': parts[1],
            'amount': double.parse(parts[2]),
            'date': DateTime.parse(parts[3]),
          };
        }).toList();
      });
    }

    // Cargar las fechas de inicio y fin
    final String? start = prefs.getString('startDate');
    final String? end = prefs.getString('endDate');
    if (start != null && end != null) {
      setState(() {
        startDate = DateTime.parse(start);
        endDate = DateTime.parse(end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Expanded(
              child: expenses.isEmpty
                  ? const Center(child: Text('No hay gastos guardados.'))
                  : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(expense['detail']),
                      subtitle: Text('\$${expense['amount']} - ${expense['type']}'),
                      trailing: Text(
                        '${expense['date'].toLocal()}'.split(' ')[0], // Muestra solo la fecha sin la hora
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
