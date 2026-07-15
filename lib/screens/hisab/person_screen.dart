import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/person_model.dart';
import 'package:pocket_hisab/screens/hisab/person_hisab_history_screen.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final personController = Get.put(PersonController());
  final _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      body: RefreshIndicator(
        onRefresh: () => personController.fetchAll(),
        child: Column(
          children: [
            _buildNetBalanceCard(),
            if (false) _buildSearchBar(),
            _buildFilterChips(),
            _buildPersonList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.bottomSheet(
            _AddPersonBottomSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText(
          'Add Person',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNetBalanceCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      double balance = personController.netBalance.value;
      String formattedBalance = CurrencyHelper.format(balance.abs());

      String stateTitle;
      String stateSubtitle;
      Color statePillColor;
      Color stateTextColor;
      IconData stateIcon;

      if (balance > 0) {
        stateTitle = "You get";
        stateSubtitle = "Net amount people owe you";
        statePillColor = Colors.green.shade50;
        stateTextColor = Colors.green.shade800;
        stateIcon = Icons.arrow_upward_rounded;
      } else if (balance < 0) {
        stateTitle = "You pay";
        stateSubtitle = "Net amount you owe people";
        statePillColor = Colors.red.shade50;
        stateTextColor = Colors.red.shade800;
        stateIcon = Icons.arrow_downward_rounded;
      } else {
        stateTitle = "Settled";
        stateSubtitle = "No active balance";
        statePillColor = Colors.blueGrey.shade50;
        stateTextColor = Colors.blueGrey.shade800;
        stateIcon = Icons.check_circle_outline_rounded;
      }

      return Container(
        margin: const .symmetric(horizontal: 16, vertical: 8),
        padding: const .all(20),
        decoration: BoxDecoration(
          borderRadius: .circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Color.alphaBlend(
                      context.themePrimary.withValues(alpha: 0.20),
                      AppColors.darkCard,
                    ),
                    Color.alphaBlend(
                      context.themePrimary.withValues(alpha: 0.20),
                      AppColors.darkCard,
                    ),
                  ]
                : [
                    Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.15),
                      context.themePrimary,
                    ),
                    context.themePrimary,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          spacing: 6,
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const .all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: .circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const AppText(
                      'Net Balance Summary',
                      color: Colors.white70,
                      size: 14,
                      fontWeight: .w600,
                    ),
                  ],
                ),
                Container(
                  padding: const .symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: .circular(20),
                  ),
                  child: AppText(
                    '${personController.persons.length} Persons',
                    color: Colors.white,
                    size: 12,
                    fontWeight: .w600,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .end,
              children: [
                Column(
                  spacing: 4,
                  crossAxisAlignment: .start,
                  children: [
                    AppText(
                      formattedBalance,
                      color: Colors.white,
                      size: 32,
                      fontWeight: .bold,
                    ),
                    AppText(
                      stateSubtitle,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 12,
                    ),
                  ],
                ),
                Container(
                  padding: const .symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statePillColor,
                    borderRadius: .circular(30),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(stateIcon, color: stateTextColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        stateTitle.toUpperCase(),
                        style: TextStyle(
                          color: stateTextColor,
                          fontSize: 12,
                          fontWeight: .bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: .circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            hintText: "Search by name...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All", "You Get", "You Pay", "Settled"];
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          Color activeBgColor = context.themePrimary;
          Color activeTextColor = Colors.white;
          Color inactiveBgColor = Colors.white;
          Color inactiveTextColor = Colors.grey.shade600;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? activeTextColor : inactiveTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: activeBgColor,
              backgroundColor: inactiveBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: .circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              showCheckmark: false,
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonList() {
    return Obx(() {
      final filteredPersons = personController.persons.where((person) {
        final nameMatches = person.personName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );

        final balance = person.balance ?? 0.0;
        bool balanceMatches = true;
        if (_selectedFilter == "You Get") {
          balanceMatches = balance > 0;
        } else if (_selectedFilter == "You Pay") {
          balanceMatches = balance < 0;
        } else if (_selectedFilter == "Settled") {
          balanceMatches = balance == 0;
        }

        return nameMatches && balanceMatches;
      }).toList();

      if (filteredPersons.isEmpty) {
        return _buildEmptyState();
      }

      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 90, top: 8),
          itemCount: filteredPersons.length,
          itemBuilder: (context, index) {
            PersonModel person = filteredPersons[index];
            final balance = person.balance ?? 0.0;

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final Color accentColor;
            final Color balanceColor;
            final Color badgeBgColor;
            final String labelText;

            if (balance > 0) {
              accentColor = Colors.green;
              balanceColor = isDark
                  ? Colors.green.shade400
                  : Colors.green.shade700;
              badgeBgColor = isDark
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.green.shade50;
              labelText = "YOU GET";
            } else if (balance < 0) {
              accentColor = Colors.red;
              balanceColor = isDark ? Colors.red.shade400 : Colors.red.shade700;
              badgeBgColor = isDark
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.red.shade50;
              labelText = "YOU PAY";
            } else {
              accentColor = Colors.grey;
              balanceColor = isDark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600;
              badgeBgColor = isDark
                  ? Colors.grey.withValues(alpha: 0.15)
                  : Colors.grey.shade100;
              labelText = "SETTLED";
            }

            return Container(
              margin: const .symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: .circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: .all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: .circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: accentColor, width: 5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const .symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      onTap: () async {
                        await Get.to(
                          () => PersonHisabHistoryScreen(
                            personId: person.id?.toString() ?? '',
                            personName: person.personName,
                          ),
                        );
                        personController.fetchAll();
                      },
                      onLongPress: () {
                        Get.defaultDialog(
                          title: "Delete Person",
                          titleStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          middleTextStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          backgroundColor: isDark
                              ? AppColors.bottomSheetDark
                              : AppColors.bottomSheet,
                          middleText:
                              "Are you sure you want to delete ${person.personName} and all related transactions?",
                          textConfirm: "Delete",
                          textCancel: "Cancel",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () async {
                            Get.back();
                            if (person.id != null) {
                              await personController.deletePerson(person.id!);
                              showCustomSnackbar(
                                'Success',
                                '${person.personName} deleted successfully',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        );
                      },
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withValues(alpha: 0.8),
                              accentColor.withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            person.personName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: AppText(
                        person.personName,
                        fontWeight: FontWeight.w600,
                        size: 15,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AppText(
                          "Added on ${DateFormat('dd MMM, yyyy').format(DateTime.parse(person.createdAt))}",
                          size: 11,
                          color: context.themeTextLight,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (balance != 0) ...[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AppText(
                                  CurrencyHelper.format(balance.abs()),
                                  color: balanceColor,
                                  fontWeight: FontWeight.bold,
                                  size: 14,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const .symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBgColor,
                                    borderRadius: .circular(6),
                                  ),
                                  child: Text(
                                    labelText,
                                    style: TextStyle(
                                      color: balanceColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: .circular(6),
                              ),
                              child: Text(
                                "SETTLED",
                                style: TextStyle(
                                  color: balanceColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ), // ListTile
                  ), // Material
                ), // Container
              ), // ClipRRect
            ); // Container
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 64,
                  color: context.themePrimary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              const AppText(
                "No ledgers found",
                fontWeight: FontWeight.bold,
                size: 18,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppText(
                _searchQuery.isNotEmpty
                    ? "Try adjusting your search query to find this person."
                    : "Add people you lend money to or borrow money from to start tracking your hisabs.",
                size: 13,
                color: context.themeTextLight,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bottomSheetDark : AppColors.bottomSheet,
        borderRadius: const .vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Center(
            child: Container(
              margin: const .only(bottom: 12),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: .circular(99),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const AppText("Add New Person", fontWeight: .bold, size: 18),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  padding: const .all(4),
                ),
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _personName,
            keyboardType: .text,
            labelText: "Person Name",
            hintText: "Enter full name",
            autoFocus: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: CustomButton(
              onTap: () {
                final personName = _personName.text.trim();
                if (personName.isEmpty) {
                  showCustomSnackbar('Error', 'Please enter Person name');
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
              title: "Add Person",
            ),
          ),
        ],
      ),
    );
  }
}
