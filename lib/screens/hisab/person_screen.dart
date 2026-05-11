import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/person_model.dart';
import 'package:pocket_hisab/screens/hisab/person_hisab_history_screen.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class PersonScreen extends StatelessWidget {
  PersonScreen({super.key});

  final personController = Get.put(PersonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => personController.fetchAll(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: const Text('Net Balance'),
                subtitle: Row(
                  spacing: 4,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 12,
                      color: Colors.grey,
                    ),
                    Obx(
                      () => Text('${personController.persons.length} Persons'),
                    ),
                  ],
                ),
                trailing: Obx(() {
                  double balance = personController.netBalance.value;
                  String netBalance = CurrencyHelper.format(balance.abs());
                  String balanceText = balance >= 0 ? "You get" : "You pay";
                  Color netBalanceColor = balance >= 0
                      ? Colors.green
                      : Colors.red;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(netBalance, color: netBalanceColor),
                      AppText(balanceText, color: netBalanceColor),
                    ],
                  );
                }),
              ),
            ),
            Obx(() {
              int itemCount = personController.persons.length; // +1 for the ad
              if (personController.persons.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      "No person found",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              return Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                    height: 0,
                    indent: 65,
                    endIndent: 20,
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  padding: const EdgeInsets.only(bottom: 70),
                  itemCount: itemCount,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // if (index == 2) {
                    //   // insert ad at position 3
                    //   if (AdService.isNativeAdLoaded) {
                    //     return Container(
                    //         height: 80,
                    //         padding: const EdgeInsets.symmetric(horizontal: 10),
                    //         child: AdWidget(ad: AdService.nativeAd!));
                    //   } else {
                    //     return const SizedBox(); // Or a loading placeholder
                    //   }
                    // }
                    // int dataIndex = (index > 2) ? index - 1 : index;

                    PersonModel person = personController.persons[index];
                    // Color balanceColor = (person.balance ?? 0) >= 0
                    //     ? Colors.green
                    //     : Colors.red;
                    return ListTile(
                      onTap: () => Get.to(
                        () => PersonHisabHistoryScreen(
                          personName: person.personName,
                        ),
                      ),
                      title: Text(person.personName),
                      leading: CircleAvatar(
                        child: Text(
                          person.personName.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      subtitle: AppText(
                        "Added on ${DateFormat('dd MMM, yyyy').format(DateTime.parse(person.createdAt))}",
                      ),
                      trailing: person.balance == 0
                          ? const SizedBox()
                          : Column(
                              mainAxisSize: .min,
                              crossAxisAlignment: .end,
                              children: [
                                AppText(
                                  CurrencyHelper.format((person.balance ?? 0).abs()),
                                  color: (person.balance ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold),
                                AppText(
                                  (person.balance ?? 0) > 0
                                      ? 'You get'
                                      : 'You pay',
                                  color: (person.balance ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ]),
                    );
                  }),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.bottomSheet(
            _AddPersonBottomSheet(),
            isScrollControlled: false,
            backgroundColor: AppColors.bottomSheet,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        },
        label: AppText('+Add Person'),
      ),
    );
  }
}

class _AddPersonBottomSheet extends StatefulWidget {
  @override
  State<_AddPersonBottomSheet> createState() => _AddPersonBottomSheetState();
}

class _AddPersonBottomSheetState extends State<_AddPersonBottomSheet> {
  final _personName = TextEditingController();

  @override
  void dispose() {
    _personName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const AppText("Add Person"),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _personName,
            keyboardType: .text,
            labelText: "Person Name",
            hintText: "Enter name",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final personName = _personName.text.trim();
                if (personName.isEmpty) {
                  Get.snackbar('Error', 'Please enter Person name');
                  return;
                }

                final personCtrl = Get.find<PersonController>();
                personCtrl.addPerson(
                  PersonModel(
                    personName: personName,
                    createdAt: DateTime.now().toString(),
                  ),
                );

                Get.back();
              },
              child: const AppText("Add person"),
            ),
          ),
        ],
      ),
    );
  }
}
