import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/models/emi_model.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class AddEmiScreen extends StatefulWidget {
  const AddEmiScreen({super.key});

  @override
  State<AddEmiScreen> createState() => _AddEmiScreenState();
}

class _AddEmiScreenState extends State<AddEmiScreen> {
  final _nameController = TextEditingController();
  final _totalController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _tenureController = TextEditingController(text: '12');
  final _alreadyPaidController = TextEditingController(text: '0');

  DateTime _startDate = DateTime.now();
  int _dueDayOfMonth = DateTime.now().day;

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _monthlyController.dispose();
    _tenureController.dispose();
    _alreadyPaidController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final monthly = double.tryParse(_monthlyController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;
    if (monthly > 0 && tenure > 0) {
      setState(() {
        _totalController.text = (monthly * tenure).toStringAsFixed(2);
      });
    } else {
      setState(() {
        _totalController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New EMI'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "EMI Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: "EMI Name",
              hintText: "e.g. iPhone 15 Pro",
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _monthlyController,
                    keyboardType: TextInputType.number,
                    labelText: "Monthly EMI",
                    hintText: "0.00",
                    onChange: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    labelText: "Tenure (Months)",
                    hintText: "12",
                    onChange: (_) => _calculateTotal(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _totalController,
              keyboardType: TextInputType.number,
              labelText: "Total Amount",
              hintText: "0.00",
              readOnly: true,
            ),
            const SizedBox(height: 16),
            // Already Paid Amount
            CustomTextField(
              controller: _alreadyPaidController,
              keyboardType: TextInputType.number,
              labelText: "Already Paid Amount",
              hintText: "0.00 (if you've paid some instalments before)",
            ),
            const SizedBox(height: 24),

            // Due Day of Month picker
            const Text(
              "Monthly Due Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_repeat_rounded,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Every month on the",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _dueDayOfMonth,
                        items: List.generate(28, (i) => i + 1)
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  '$d${_daySuffix(d)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _dueDayOfMonth = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Start Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd MMMM yyyy').format(_startDate)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              title: "Create EMI",
              onTap: () async {
                if (_nameController.text.isEmpty ||
                    _totalController.text.isEmpty ||
                    _monthlyController.text.isEmpty ||
                    _tenureController.text.isEmpty) {
                  Get.snackbar('Error', 'Please fill all fields');
                  return;
                }

                final total = double.parse(_totalController.text);
                final monthly = double.parse(_monthlyController.text);
                final tenureMonths = int.tryParse(_tenureController.text) ?? 12;
                final alreadyPaid =
                    double.tryParse(_alreadyPaidController.text) ?? 0.0;

                final remaining = (total - alreadyPaid).clamp(0.0, total);
                final newStatus = remaining <= 0 ? 'completed' : 'active';

                final endDate = _startDate.add(
                  Duration(days: tenureMonths * 30),
                );

                final emi = EmiModel(
                  name: _nameController.text,
                  totalAmount: total,
                  paidAmount: alreadyPaid,
                  remainingAmount: remaining,
                  monthlyAmount: monthly,
                  startDate: _startDate.toString(),
                  endDate: endDate.toString(),
                  status: newStatus,
                  createdAt: DateTime.now().toString(),
                  dueDayOfMonth: _dueDayOfMonth,
                );

                final success = await Get.find<EmiController>().addEmi(emi);
                if (success) {
                  Get.back();
                  Get.snackbar('Success', 'EMI added successfully');
                } else {
                  Get.snackbar('Error', 'Failed to add EMI');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
