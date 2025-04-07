import 'package:flutter/material.dart';
import '../../db/db_helper.dart';
import '../../db/model/db_model.dart';

void showBottomSheetForm(BuildContext context, SKU? sku, Function reloadList) {
  TextEditingController nameController =
      TextEditingController(text: sku?.name ?? '');
  TextEditingController bNameController =
      TextEditingController(text: sku?.bName ?? '');
  TextEditingController typeController =
      TextEditingController(text: sku?.type ?? '');
  TextEditingController cardNumController =
      TextEditingController(text: sku?.card_num ?? '');
  TextEditingController validTillController =
      TextEditingController(text: sku?.valid_till ?? '');
  TextEditingController codeController =
      TextEditingController(text: sku?.code.toString() ?? '');
  TextEditingController waiverController =
      TextEditingController(text: sku?.waive.toString() ?? '');
  TextEditingController countController =
      TextEditingController(text: sku?.count.toString() ?? '');

  Future<void> updateDatabase() async {
    int enteredCount = int.tryParse(countController.text.trim()) ?? 0;

    // Fetch existing waiver count from DB
    int previousCount = await DBHelper.instance.getWaiverCount(sku?.id ?? 0);
    int updatedCount = previousCount + enteredCount;

    // Create SKU object with updated waiver count
    SKU newSKU = SKU(
      id: sku?.id,
      name: nameController.text.trim(),
      bName: bNameController.text.trim(),
      type: typeController.text.trim(),
      card_num: cardNumController.text.trim(),
      code: int.tryParse(codeController.text.trim()) ?? 0,
      valid_till: validTillController.text.trim(),
      waive: int.tryParse(waiverController.text.trim()) ?? 0,
      count: updatedCount,
    );

    // Insert or update based on whether SKU exists
    if (sku == null) {
      await DBHelper.instance.insert(newSKU.toMap());
    } else {
      await DBHelper.instance.update(newSKU.toMap());
    }

    // Fetch latest count from DB to update UI
    int latestCount = await DBHelper.instance.getWaiverCount(sku?.id ?? 0);

    // Update the UI
    countController.text = latestCount.toString();

    reloadList();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: bNameController,
                decoration: const InputDecoration(labelText: 'Bank Name')),
            TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Cardholder Name')),
            TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type')),
            TextField(
                controller: cardNumController,
                decoration: const InputDecoration(labelText: 'Card Number')),
            TextField(
                controller: validTillController,
                decoration: const InputDecoration(labelText: 'Valid Till')),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: waiverController,
              decoration: const InputDecoration(labelText: 'Waiver Times'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: countController,
              decoration: const InputDecoration(labelText: 'Waiver Count'),
              keyboardType: TextInputType.phone,
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  await updateDatabase(); // Update DB when user presses "Enter"
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateDatabase(); // Call the same update function
                Navigator.pop(context); // Close the bottom sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Set the background color
                foregroundColor: Colors.white, // Set the text color
              ),
              child: Text(sku == null ? 'Add Card' : 'Update Card'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ElevatedButton(
//   onPressed: () async {
//     int enteredCount =
//         int.tryParse(countController.text.trim()) ?? 0;
//
//     // Fetch existing waiver count from DB
//     int previousCount =
//         await DBHelper.instance.getWaiverCount(sku?.id ?? 0);
//     int updatedCount = previousCount + enteredCount;
//
//     // Create SKU object with updated waiver count
//     SKU newSKU = SKU(
//       id: sku?.id,
//       name: nameController.text.trim(),
//       bName: bNameController.text.trim(),
//       type: typeController.text.trim(),
//       card_num: card_numController.text.trim(),
//       code: int.tryParse(codeController.text.trim()) ?? 0,
//       valid_till: valid_tillController.text.trim(),
//       waive: int.tryParse(waiverController.text.trim()) ??
//           0, // Update Waiver Count
//       count: updatedCount,
//     );
//
//     // Insert or update based on whether SKU exists
//     if (sku == null) {
//       await DBHelper.instance.insert(newSKU.toMap());
//     } else {
//       await DBHelper.instance.update(newSKU.toMap());
//     }
//
//     reloadList();
//     Navigator.pop(context);
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor:
//         Colors.teal, // Set the background color to teal
//     foregroundColor: Colors.white, // Set the text color to white
//   ),
//   child: Text(sku == null ? 'Add Card' : 'Update Card'),
// ),
