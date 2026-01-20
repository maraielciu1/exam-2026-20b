import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';
import 'package:flutter_logs_mobile_app/viewmodels/add_log_viewmodel.dart';
import 'package:provider/provider.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedType;

  static const List<String> _typeOptions = ['intake', 'burn'];
  String? _lastError;

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddLogViewModel(context.read<LogRepository>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Log'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<AddLogViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.errorMessage != null &&
                  viewModel.errorMessage != _lastError) {
                _lastError = viewModel.errorMessage;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage!)),
                  );
                });
              }
              return Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (viewModel.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: LinearProgressIndicator(),
                          ),
                        TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date (YYYY-MM-DD)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Amount is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Amount must be a number';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type (intake or burn)',
                      ),
                      items: _typeOptions
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Type is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                        ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              final draft = LogDraft(
                                date: _dateController.text.trim(),
                                amount:
                                    double.parse(_amountController.text.trim()),
                                type: _selectedType!.trim(),
                                category: _categoryController.text.trim(),
                                description:
                                    _descriptionController.text.trim(),
                              );
                              final created =
                                  await viewModel.createLog(draft);
                              if (!mounted) {
                                return;
                              }
                              if (created != null) {
                                Navigator.of(context).pop(created);
                              }
                            },
                          child: viewModel.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Log'),
                        ),
                      ],
                    ),
                  ),
                  if (viewModel.isLoading)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: Color(0x33000000),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
