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
  final _paidController = TextEditingController(text: '0');
  final _tenureController = TextEditingController(text: '12');

  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _monthlyController.dispose();
    _paidController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateMonthly() {
    final total = double.tryParse(_totalController.text) ?? 0;
    final paid = double.tryParse(_paidController.text) ?? 0;
    final remaining = total - paid;
    final tenure = int.tryParse(_tenureController.text) ?? 0;
    if (remaining > 0 && tenure > 0) {
      setState(() {
        _monthlyController.text = (remaining / tenure).toStringAsFixed(2);
      });
    }
  }

  void _calculateTenure() {
    final total = double.tryParse(_totalController.text) ?? 0;
    final paid = double.tryParse(_paidController.text) ?? 0;
    final remaining = total - paid;
    final monthly = double.tryParse(_monthlyController.text) ?? 0;
    if (remaining > 0 && monthly > 0) {
      setState(() {
        _tenureController.text = (remaining / monthly).ceil().toString();
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
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    labelText: "Total Amount",
                    hintText: "0.00",
                    onChange: (_) => _calculateMonthly(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _paidController,
                    keyboardType: TextInputType.number,
                    labelText: "Already Paid",
                    hintText: "0.00",
                    onChange: (_) => _calculateMonthly(),
                  ),
                ),
              ],
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
                    onChange: (_) => _calculateTenure(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    labelText: "Tenure (Months)",
                    hintText: "12",
                    onChange: (_) => _calculateMonthly(),
                  ),
                ),
              ],
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
                final paid = double.parse(_paidController.text);
                final monthly = double.parse(_monthlyController.text);
                final tenureMonths = int.tryParse(_tenureController.text) ?? 12;

                final endDate = _startDate.add(
                  Duration(days: tenureMonths * 30),
                );

                final emi = EmiModel(
                  name: _nameController.text,
                  totalAmount: total,
                  paidAmount: paid,
                  remainingAmount: total - paid,
                  monthlyAmount: monthly,
                  startDate: _startDate.toString(),
                  endDate: endDate.toString(),
                  status: (total - paid) <= 0 ? 'completed' : 'active',
                  createdAt: DateTime.now().toString(),
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
}
