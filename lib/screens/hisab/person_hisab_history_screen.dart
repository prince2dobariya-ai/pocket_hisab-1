import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class PersonHisabHistoryScreen extends StatelessWidget {
  final String personName;

  const PersonHisabHistoryScreen({super.key, required this.personName});

  @override
  Widget build(BuildContext context) {
    final hisabCtrl = Get.find<HisabController>();

    return Scaffold(
      appBar: CustomAppBar(title: "$personName's Hisab"),
      body: Obx(() {
        final items = hisabCtrl.hisabs
            .where((h) => h.personName == personName)
            .toList();

        if (items.isEmpty) {
          return const Center(child: Text("No history found"));
        }

        // Calculate net balance for this person
        double netBalance = 0;
        for (var h in items) {
          netBalance += (h.type == 'given' ? h.amount : -h.amount);
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: netBalance > 0
                  ? Colors.green.shade50
                  : (netBalance < 0 ? Colors.red.shade50 : Colors.grey.shade50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Net Balance",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    netBalance == 0
                        ? "Settled"
                        : "₹${netBalance.abs().toStringAsFixed(0)} ${netBalance > 0 ? '(Owes You)' : '(You Owe)'}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: netBalance > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isBorrowed = item.type == 'borrowed';
                  final color = isBorrowed
                      ? Colors.red.shade400
                      : Colors.green.shade400;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBorrowed ? "Borrowed" : "Lent",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 16,
                                ),
                              ),
                              if (item.note != null && item.note!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item.note!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${item.amount.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.createdAt.split('T').first,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
