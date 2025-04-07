import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../db/db_helper.dart';
import '../../db/model/db_model.dart';
import '../../service/export_service.dart';
import '../../utility/show_alert.dart';
import '../../utility/show_progress.dart';
import 'home_bottomsheet.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<SKU> _skuList = [];
  Map<int, bool> _isCodeVisibleMap = {}; // Map to track visibility per card
  bool _isLoading = true; // Loader state

  @override
  void initState() {
    super.initState();
    _loadSKUList();
  }

  Future<void> _loadSKUList() async {
    try {
      List<Map<String, dynamic>> rows = await DBHelper.instance.queryAllRows();
      setState(() {
        _skuList = rows.map((row) => SKU.fromMap(row)).toList();
        _isLoading = false;
        // Initialize visibility map for all cards
        _isCodeVisibleMap = {
          for (var sku in _skuList) sku.id!: false,
        };
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _deleteSKU(int id) async {
    await DBHelper.instance.delete(id);
    _loadSKUList();
  }

  String _formatCardNumber(String cardNum) {
    // Remove any existing spaces
    cardNum = cardNum.replaceAll(RegExp(r'\s+'), '');
    // Add spaces after every 4 characters
    return cardNum.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ");
  }

  Future<void> _syncDatabase() async {
    try {
      ShowProgress.showProgressDialogWithMsg(context);
      ExportService exportService = ExportService();
      await exportService.exportToText();
      ShowProgress.hideProgressDialog(context);
      ShowAlert.showSnackBar(context, 'File is Downloaded Successfully', Colors.teal);
    } catch (e) {
      ShowAlert.showSnackBar(context, 'Error to Download: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: const Color(0xFFEAEFF6),
        backgroundColor: Colors.teal,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Card Manager', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _syncDatabase,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while data is loading
          : _skuList.isEmpty
              ? const Center(child: Text('No Card is available. Add one!'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _skuList.length,
                  itemBuilder: (context, index) {
                    final sku = _skuList[index];
                    return Dismissible(
                      key: Key(sku.id.toString()),
                      background: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        color: Colors.blue,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          showBottomSheetForm(context, sku, _loadSKUList);
                          return false;
                        } else if (direction == DismissDirection.endToStart) {
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Card"),
                              content: const Text("Are you sure you want to delete this Card?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          return confirmDelete;
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _deleteSKU(sku.id!);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sku.bName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    sku.type,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sku.name,
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20, color: Colors.black87),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: sku.name));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Copied to clipboard"),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _formatCardNumber(sku.card_num),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20, color: Colors.black87),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: sku.card_num));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Copied to clipboard"),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Validity + Badge Container
                                  Row(
                                    children: [
                                      Text(
                                        'Valid: ${sku.valid_till}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(width: 10), // Space between Validity and Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.teal, // Background color
                                          borderRadius: BorderRadius.circular(20), // Rounded corners
                                        ),
                                        child: Text(
                                          '${sku.count}/${sku.waive}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white, // White text color
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Code & Actions
                                  Row(
                                    children: [
                                      Text(
                                        'Code: ${_isCodeVisibleMap[sku.id] == true ? sku.code : '***'}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isCodeVisibleMap[sku.id] == true ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isCodeVisibleMap[sku.id!] = !_isCodeVisibleMap[sku.id!]!;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, color: Colors.black87),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: sku.code.toString()));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Code copied to clipboard"),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheetForm(context, null, _loadSKUList),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
