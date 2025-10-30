import 'package:flutter/material.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/widgets/custom_text_field.dart';

class PostBookScreen extends StatefulWidget {
  const PostBookScreen({super.key});

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _swapForController = TextEditingController();
  
  BookCondition _selectedCondition = BookCondition.good;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _swapForController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Post a Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Book Title',
              hint: 'Enter the book title',
              controller: _titleController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a book title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            CustomTextField(
              label: 'Author',
              hint: 'Enter the author name',
              controller: _authorController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the author name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            CustomTextField(
              label: 'Swap For',
              hint: 'What book would you like in exchange?',
              controller: _swapForController,
            ),
            
            const SizedBox(height: 20),
            
            _buildConditionSelector(),
            
            const SizedBox(height: 32),
            
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: AppTheme.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: BookCondition.values.map((condition) {
            final isSelected = _selectedCondition == condition;
            return ChoiceChip(
              label: Text(condition.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCondition = condition;
                });
              },
              selectedColor: AppTheme.accentGold,
              backgroundColor: AppTheme.cardBackground,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryNavy : AppTheme.subtleGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book posted successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }
}
