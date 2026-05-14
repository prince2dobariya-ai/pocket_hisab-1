import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';

class HisabCard extends StatelessWidget {
  const HisabCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure PersonController is initialized
    final personCtrl = Get.find<PersonController>();

    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final balance = personCtrl.netBalance.value;
          final isGetting = balance >= 0;

          return Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          Text(
                            "Hisab (Net Balance)",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyHelper.format(balance.abs()),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isGetting ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isGetting ? Colors.green : Colors.red).withAlpha(
                        25,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isGetting ? "YOU GET" : "YOU GIVE",
                      style: TextStyle(
                        color: isGetting ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${personCtrl.persons.length} Persons',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
