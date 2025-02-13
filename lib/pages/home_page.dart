import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> expenses = [];
  String selectedTransactionType = 'Gasto'; // Default transaction type is 'Gasto'

  final TextEditingController detailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _saveExpenses() async {
  final prefs = await SharedPreferences.getInstance();

  // Convertir la lista de gastos a JSON
  String jsonExpenses = jsonEncode(expenses);

  // Guardar los gastos como una cadena JSON
  await prefs.setString('expenses', jsonExpenses);

  // Guardar las fechas de inicio y fin
  await prefs.setString('startDate', startDate?.toIso8601String() ?? '');
  await prefs.setString('endDate', endDate?.toIso8601String() ?? '');

  debugPrint("valor");
  debugPrint(jsonExpenses); // Imprime el JSON para depuración

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gastos/ganancias guardados exitosamente')),
  );

  // Limpiar los campos y los gastos
  setState(() {
    expenses.clear();
    detailController.clear();
    amountController.clear();
    startDate = null;
    endDate = null;
  });
}


  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now(),
        end: endDate ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _addExpense() {
    if (detailController.text.isNotEmpty && amountController.text.isNotEmpty) {
      setState(() {
        expenses.add({
          'startDate': startDate,
          'endDate': endDate,
          'detail': detailController.text,
          'amount': double.parse(amountController.text),
          'type': selectedTransactionType,
          'date': DateTime.now().toIso8601String(),
        });
      });
      detailController.clear();
      amountController.clear();
    }
  }

  void _deleteExpense(Map<String, dynamic> expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var expense in expenses) {
      total += expense['type'] == 'Gasto' ? -expense['amount'] : expense['amount'];
    }
    return total;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitir Reporte'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Agregar'),
            Tab(text: 'Ver Gastos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: const Text('Seleccionar Rango de Fechas'),
                ),
                if (startDate != null && endDate != null)
                  Text(
                      'Rango de Fechas: ${startDate!.toLocal()} - ${endDate!.toLocal()}'),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Text('Tipo de transacción: '),
                    DropdownButton<String>(
                      value: selectedTransactionType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTransactionType = newValue!;
                        });
                      },
                      items: <String>['Gasto', 'Ganancia']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(labelText: 'Detalle de la ruta'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto Gasto/Ganancia'),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: const Text('Agregar Gasto/Ganancia'),
                ),
              ],
            ),
          ),

          // Segunda pestaña: Lista de gastos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ListTile(
                        title: Text(expense['detail']),
                        subtitle: Text('\$${expense['amount']} - ${expense['type']}'),
                        tileColor: expense['type'] == 'Gasto' ? Colors.red[100] : Colors.green[100],
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Puedes agregar la lógica para editar el gasto
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteExpense(expense),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Total de Gastos/Ganancias: \$${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveExpenses,
                  child: const Text('Guardar Gastos/Ganancias'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
