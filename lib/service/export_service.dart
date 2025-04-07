import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../db/db_helper.dart';

class ExportService {
// Request storage permission with Android version check

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check if storage permission is already granted
      if (await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        print("Storage Permission Already Granted");
        return true;
      }

      // Request MANAGE_EXTERNAL_STORAGE permission for Android 11+
      if (await Permission.manageExternalStorage.request().isGranted) {
        print("Manage External Storage Permission Granted");
        return true;
      }

      // Request STORAGE permission for devices below Android 11
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        print("Storage Permission Granted");
        return true;
      } else if (status.isDenied) {
        print("Storage Permission Denied. Opening app settings...");
        await openAppSettings();
        return false;
      } else if (status.isPermanentlyDenied) {
        print("Storage Permission Permanently Denied. Opening app settings...");
        await openAppSettings();
        return false;
      }
    }
    return true; // Assume granted for non-Android platforms
  }

  // Get Downloads directory path
  Future<String?> _getDownloadsDirectoryPath() async {
    if (Platform.isAndroid) {
      // For Android, manually define the Downloads folder
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (downloadsDirectory.existsSync()) {
        return downloadsDirectory.path;
      }
    } else if (Platform.isIOS) {
      // For iOS, use the application documents directory
      Directory? documentsDirectory = await getApplicationDocumentsDirectory();
      return documentsDirectory.path;
    }
    return null;
  }

  // Export data to JSON file
  Future<void> exportToJson() async {
    if (!await requestStoragePermission()) return;

    try {
      // Get data from the database
      List<Map<String, dynamic>> data = await DBHelper.instance.queryAllRows();
      String jsonData = jsonEncode(data);

      // Get the Downloads folder path
      String? downloadsPath = await _getDownloadsDirectoryPath();
      if (downloadsPath == null) {
        print("Error: Unable to access downloads directory.");
        return;
      }

      // Write the JSON data to a file
      final file = File('$downloadsPath/card_info.json');
      await file.writeAsString(jsonData);

      print('Data exported to JSON: ${file.path}');
    } catch (e) {
      print('Error exporting to JSON: $e');
    }
  }

  // Export data to Text file
  Future<void> exportToText() async {
    if (!await requestStoragePermission()) return;

    try {
      // Get data from the database
      List<Map<String, dynamic>> data = await DBHelper.instance.queryAllRows();

      // Format the data as text
      StringBuffer buffer = StringBuffer();
      for (var row in data) {
        buffer.writeln(
            'Bank Name: ${row['b_name']}, Type: ${row['type']}, Cardholder Name: ${row['name']}, Card Number: ${row['card_num']}, Code: ${row['code']}, Valid: ${row['valid_till']}');
      }

      // Get the Downloads folder path
      String? downloadsPath = await _getDownloadsDirectoryPath();
      if (downloadsPath == null) {
        print("Error: Unable to access downloads directory.");
        return;
      }

      // Write the text data to a file
      final file = File('$downloadsPath/card_info.txt');
      await file.writeAsString(buffer.toString());

      print('Data exported to Text: ${file.path}');
    } catch (e) {
      print('Error exporting to Text: $e');
    }
  }

// Export data to Excel file
//   Future<void> exportToExcel() async {
//     if (!await requestStoragePermission()) return;
//
//     try {
//       List<Map<String, dynamic>> data = await DBHelper.instance.queryAllRows();
//
//       var excel = Excel.createExcel();
//       Sheet sheet = excel['SKU Data'];
//
//       // Add headers
//       sheet.appendRow(["ID", "Name", "B_Name", "Type", "Card_Num", "Code", "Valid_Till"]);
//
//       // Add rows from database
//       for (var row in data) {
//         sheet.appendRow([
//           row['id']?.toString() ?? '',
//           row['name'] ?? '',
//           row['b_name'] ?? '',
//           row['type'] ?? '',
//           row['card_num'] ?? '',
//           row['code']?.toString() ?? '',
//           row['valid_till'] ?? '',
//         ]);
//       }
//
//       final directory = await getExternalStorageDirectory();
//       if (directory == null) {
//         print('Error: Unable to access storage directory.');
//         return;
//       }
//
//       final filePath = '${directory.path}/card_info.xlsx';
//
//       var encodedBytes = excel.encode();
//       if (encodedBytes == null) {
//         print("Error: Failed to encode Excel data.");
//         return;
//       }
//
//       File file = File(filePath);
//       await file.writeAsBytes(encodedBytes);
//
//       print('Data exported to Excel: $filePath');
//       shareFile(filePath);
//     } catch (e) {
//       print('Error exporting to Excel: $e');
//     }
//   }

// Function to share files
//   void shareFile(String filePath) {
//     try {
//       Share.shareFiles([filePath], text: 'Here is the exported file.');
//     } catch (e) {
//       print('Error sharing file: $e');
//     }
//   }
}
