import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/screens/hisab/add_hisab_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class PersonHisabHistoryScreen extends StatelessWidget {
  final String personName;

  const PersonHisabHistoryScreen({super.key, required this.personName});

  @override
  Widget build(BuildContext context) {
    final hisabCtrl = Get.find<HisabController>();

    return Scaffold(
      appBar: CustomAppBar(title: personName.toUpperCase()),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final items = hisabCtrl.hisabs
                  .where(
                    (h) =>
                        h.personName?.trim().toLowerCase() ==
                        personName.trim().toLowerCase(),
                  )
                  .toList();

              if (items.isEmpty) {
                return const Center(child: Text("No history found"));
              }

              // Sort items by date (Oldest first for chat-like flow)
              items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              // Group items by date
              Map<String, List<HisabModel>> groupedItems = {};
              for (var item in items) {
                String date = item.createdAt.split('T').first;
                if (!groupedItems.containsKey(date)) {
                  groupedItems[date] = [];
                }
                groupedItems[date]!.add(item);
              }

              final sortedDates = groupedItems.keys.toList()
                ..sort((a, b) => a.compareTo(b));

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  String dateStr = sortedDates[index];
                  List<HisabModel> dayItems = groupedItems[dateStr]!;

                  return Column(
                    children: [
                      _buildDateDivider(dateStr),
                      ...dayItems
                          .map((item) => _buildChatBubble(item))
                          .toList(),
                    ],
                  );
                },
              );
            }),
          ),
          _buildBottomSummary(hisabCtrl),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    String label;
    DateTime now = DateTime.now();
    if (dateStr == DateFormat('yyyy-MM-dd').format(now)) {
      label = "Today";
    } else {
      label = DateFormat('dd MMM yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildChatBubble(HisabModel item) {
    bool isGiven = item.type == 'given';
    Color themeColor = isGiven ? Colors.red : Colors.green;
    IconData icon = isGiven ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    // Extract time from createdAt if available, else use a placeholder
    String time = "08:00 AM";
    try {
      if (item.createdAt.contains('T')) {
        DateTime dt = DateTime.parse(item.createdAt);
        time = DateFormat('hh:mm a').format(dt);
      }
    } catch (_) {}

    return Container(
      width: double.infinity,
      alignment: isGiven ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: themeColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  "₹${item.amount.toStringAsFixed(1)}",
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            if (item.note != null && item.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.note!,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(HisabController hisabCtrl) {
    return Obx(() {
      final items = hisabCtrl.hisabs
          .where((h) => h.personName == personName)
          .toList();

      double netBalance = 0;
      for (var h in items) {
        netBalance += (h.type == 'given' ? h.amount : -h.amount);
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F5),
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Balance Due",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "₹${netBalance.abs().toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: netBalance > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTransactionButton(
                    "Received",
                    Colors.green,
                    Icons.arrow_circle_down,
                    onTap: () => Get.to(
                      () => AddHisabScreen(
                        personName: personName,
                        isBorrowed: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTransactionButton(
                    "Given",
                    Colors.red,
                    Icons.arrow_circle_up,
                    onTap: () => Get.to(
                      () => AddHisabScreen(
                        personName: personName,
                        isBorrowed: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionButton(
    String label,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
