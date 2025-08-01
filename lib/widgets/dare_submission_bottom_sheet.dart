import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dare_model.dart';
import '../services/dare_service.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../utils/app_theme.dart';

class DareSubmissionBottomSheet extends StatefulWidget {
  const DareSubmissionBottomSheet({super.key});

  @override
  State<DareSubmissionBottomSheet> createState() => _DareSubmissionBottomSheetState();
}

class _DareSubmissionBottomSheetState extends State<DareSubmissionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DareType _selectedType = DareType.solo;
  DareDifficulty _selectedDifficulty = DareDifficulty.easy;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final dareService = Provider.of<DareService>(context);
    final authService = Provider.of<AuthService>(context);
    final paymentService = Provider.of<PaymentService>(context);
    
    final submissionFee = _getSubmissionFee(_selectedDifficulty);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Submit Dare',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Dare Title',
                        hintText: 'e.g., Eat a ghost pepper',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the dare in detail...',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Dare Type
                    const Text(
                      'Dare Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: DareType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(_getTypeLabel(type)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                          selectedColor: AppTheme.primaryRed,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Difficulty
                    const Text(
                      'Difficulty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: DareDifficulty.values.map((difficulty) {
                        final isSelected = _selectedDifficulty == difficulty;
                        return ChoiceChip(
                          label: Text(dareService.getDifficultyLabel(difficulty)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDifficulty = difficulty;
                            });
                          },
                          selectedColor: dareService.getDifficultyColor(difficulty),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Fee breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fee Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Submission Fee:',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Text(
                                '\$${submissionFee.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Platform Cut (20%):',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Text(
                                '\$${(submissionFee * 0.2).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Performer Gets:',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Text(
                                '\$${(submissionFee * 0.8).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Submit button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDare,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'PAY \$${submissionFee.toStringAsFixed(2)} & SUBMIT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(DareType type) {
    switch (type) {
      case DareType.solo:
        return 'Solo';
      case DareType.oneVsOne:
        return '1v1 Battle';
      case DareType.group:
        return 'Group';
    }
  }

  double _getSubmissionFee(DareDifficulty difficulty) {
    switch (difficulty) {
      case DareDifficulty.easy:
        return 1.0;
      case DareDifficulty.medium:
        return 2.5;
      case DareDifficulty.hard:
        return 5.0;
      case DareDifficulty.extreme:
        return 10.0;
      case DareDifficulty.insane:
        return 25.0;
    }
  }

  Future<void> _submitDare() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final dareService = Provider.of<DareService>(context, listen: false);
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    final user = authService.appUser!;
    final submissionFee = _getSubmissionFee(_selectedDifficulty);

    try {
      // Process payment first
      final paymentError = await paymentService.processPayment(
        amount: submissionFee,
        currency: 'usd',
        description: 'Dare submission fee',
        userId: user.id,
      );

      if (paymentError != null) {
        throw Exception(paymentError);
      }

      // Submit dare
      final dareError = await dareService.submitDare(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        difficulty: _selectedDifficulty,
        submitterId: user.id,
      );

      if (dareError != null) {
        throw Exception(dareError);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dare submitted successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}