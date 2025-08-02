import 'package:flutter/material.dart';
import 'package:pocket_split/core/theme/app_theme.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  
  bool _hasGroupImage = false;
  String _selectedGroupType = 'Trip';
  
  // Trip specific fields
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Home specific fields
  bool _enableSettleUpReminders = false;
  
  // Couple specific fields
  bool _enableBalanceAlert = false;
  double _balanceAlertAmount = 100.0;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.5),
          border: Border.all(color: AppTheme.neutralGray, width: 1),
          color: value 
              ? AppTheme.primary2.withValues(alpha: 0.3)
              : AppTheme.neutralGray.withValues(alpha: 0.3),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27,
            height: 27,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? AppTheme.primary2 : Colors.white,
              border: Border.all(color: AppTheme.neutralGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _hasGroupImage = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _hasGroupImage = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera picker coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildGroupImage() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightGray,
            border: Border.all(color: AppTheme.neutralGray, width: 2),
          ),
          child: _hasGroupImage
              ? const Icon(
                  Icons.group,
                  size: 40,
                  color: AppTheme.primary2,
                )
              : const Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: AppTheme.neutralGray,
                ),
        ),
      ),
    );
  }

  Widget _buildGroupTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Trip', 'Home', 'Couple', 'Other'].map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: _selectedGroupType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedGroupType = type;
                  });
                }
              },
              selectedColor: AppTheme.primary2,
              backgroundColor: AppTheme.lightGray,
              labelStyle: TextStyle(
                color: _selectedGroupType == type ? Colors.black : AppTheme.darkGray,
                fontWeight: _selectedGroupType == type ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTripSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary1.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.secondary2, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PocketSplit will remind friends to join, add expenses, and settle up',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.neutralGray),
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.lightGray,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Select date',
                            style: TextStyle(
                              color: _startDate != null ? AppTheme.darkGray : AppTheme.neutralGray,
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: AppTheme.neutralGray),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _startDate != null ? () => _selectDate(context, false) : null,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.neutralGray),
                        borderRadius: BorderRadius.circular(12),
                        color: _startDate != null ? AppTheme.lightGray : AppTheme.lightGray.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select date',
                            style: TextStyle(
                              color: _endDate != null 
                                  ? AppTheme.darkGray 
                                  : _startDate != null 
                                      ? AppTheme.neutralGray 
                                      : AppTheme.neutralGray.withValues(alpha: 0.5),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today, 
                            color: _startDate != null 
                                ? AppTheme.neutralGray 
                                : AppTheme.neutralGray.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHomeSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.secondary1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.secondary1.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.home, color: AppTheme.secondary2, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enable notifications to remind members to settle up',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settle Up Reminders',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get notifications to remind group members',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildCustomSwitch(
                value: _enableSettleUpReminders,
                onChanged: (bool value) {
                  setState(() {
                    _enableSettleUpReminders = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoupleSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PocketSplit will alert the group when someone\'s balance reaches a set amount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Alert',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Alert when balance reaches \$${_balanceAlertAmount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildCustomSwitch(
                value: _enableBalanceAlert,
                onChanged: (bool value) {
                  setState(() {
                    _enableBalanceAlert = value;
                  });
                },
              ),
            ],
          ),
        ),
        if (_enableBalanceAlert) ...[
          const SizedBox(height: 16),
          Text(
            'Alert Amount: \$${_balanceAlertAmount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _balanceAlertAmount,
            min: 10,
            max: 1000,
            divisions: 99,
            label: '\$${_balanceAlertAmount.toStringAsFixed(0)}',
            onChanged: (double value) {
              setState(() {
                _balanceAlertAmount = value;
              });
            },
            activeColor: AppTheme.primary2,
          ),
        ],
      ],
    );
  }

  Widget _buildGroupTypeSpecificFields() {
    switch (_selectedGroupType) {
      case 'Trip':
        return _buildTripSpecificFields();
      case 'Home':
        return _buildHomeSpecificFields();
      case 'Couple':
        return _buildCoupleSpecificFields();
      case 'Other':
      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.neutralGray.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.neutralGray.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.group, color: AppTheme.neutralGray, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'General group for sharing expenses',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  void _createGroup() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement group creation logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating group "${_groupNameController.text}"...'),
          backgroundColor: AppTheme.primary2,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Image
              _buildGroupImage(),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to add group photo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),

              // Group Name
              Text(
                'Group Name',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter group name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Group Type Selector
              _buildGroupTypeSelector(),
              const SizedBox(height: 24),

              // Type-specific fields
              _buildGroupTypeSpecificFields(),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary2,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Create Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}