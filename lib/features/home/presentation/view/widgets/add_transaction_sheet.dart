import 'package:expensive/core/services/prefs_service.dart';
import 'package:expensive/core/utils/app_colors.dart';
import 'package:expensive/core/utils/app_toast.dart';
import 'package:expensive/features/home/presentation/bloc/home_bloc.dart';
import 'package:expensive/features/home/presentation/bloc/home_event.dart';
import 'package:expensive/features/transactions/data/models/category_model.dart';
import 'package:expensive/features/transactions/data/models/transaction_model.dart';
import 'package:expensive/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expensive/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:expensive/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool isExpense = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? selectedCategoryId;
  List<CategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = context.read<TransactionRepository>();
    final cats = await repo.getAllCategories();
    setState(() {
      categories = cats;
      if (cats.isNotEmpty) selectedCategoryId = cats.first.id;
      isLoading = false;
    });
  }

  Future<void> _saveTransaction() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        selectedCategoryId == null) {
      ShowToast.showCustomToast(
        context,
        "Please fill all fields",
        isError: true,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final userId = await PrefsService().getUserId() ?? "system";

    final tx = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      note: _titleController.text,
      type: isExpense ? 'debit' : 'credit',
      categoryId: selectedCategoryId!,
      userId: userId,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      isSynced: 0,
      isDeleted: 0,
    );

    if (mounted) {
      context.read<HomeBloc>().add(AddHomeTransactionEvent(tx));
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Transaction",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: TextStyle(color: AppColors.kWhite),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    _buildToggleButton("Expense", true),
                    _buildToggleButton("Income", false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Title", _titleController),
              const SizedBox(height: 15),
              _buildTextField("Amount (₹)", _amountController, isNumber: true),
              const SizedBox(height: 20),
              const Text(
                "CATEGORY",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              if (isLoading)
                const CircularProgressIndicator()
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories
                      .map((cat) => _categoryChip(cat))
                      .toList(),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.kWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Everything you add here is saved only on your device.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _saveTransaction,
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool value) {
    final selected = isExpense == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isExpense = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _categoryChip(CategoryModel cat) {
    final isSelected = selectedCategoryId == cat.id;
    return GestureDetector(
      onTap: () => setState(() => selectedCategoryId = cat.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.white24) : null,
        ),
        child: Text(cat.name, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
