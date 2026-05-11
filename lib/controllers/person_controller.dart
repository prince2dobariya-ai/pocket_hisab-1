import 'package:get/get.dart';
import 'package:pocket_hisab/models/person_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class PersonController extends GetxController {
  final _db = DatabaseService();
  static const _table = 'persons';

  final RxList<PersonModel> persons = <PersonModel>[].obs;
  final RxBool isLoading = false.obs;

  final RxDouble netBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading(true);
    // Fetch persons with their net balance
    final rows = await _db.rawQuery('''
      SELECT p.*, 
             (SELECT SUM(CASE WHEN type = 'given' THEN remaining_amount ELSE -remaining_amount END) 
              FROM hisab_transactions 
              WHERE person_id = p.id AND status = 'pending') as balance
      FROM $_table p
      ORDER BY p.id DESC
    ''');
    
    persons.value = rows.map((row) {
      final model = PersonModel.fromMap(row);
      // We can extend PersonModel to include balance or just handle it here if needed
      // For now, let's just use the basic model and maybe update the UI to show balance
      return model;
    }).toList();

    // Calculate total net balance
    double total = 0;
    for (var row in rows) {
      total += (row['balance'] as num?)?.toDouble() ?? 0.0;
    }
    netBalance.value = total;

    isLoading(false);
  }

  Future<bool> addPerson(PersonModel person) async {
    try {
      final id = await _db.insert(_table, person.toMap());
      await fetchAll();
      return true;
    } catch (_) {
      return false;
    }
  }


}