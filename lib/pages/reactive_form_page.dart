import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveFormPage extends StatelessWidget {
  const ReactiveFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define form group (like useForm() in react-hook-form)
    final form = FormGroup({
      'firstName': FormControl<String>(
        value: '',
        validators: [
          Validators.required,
          Validators.minLength(2),
        ],
      ),
      'lastName': FormControl<String>(
        value: '',
        validators: [Validators.required],
      ),
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'age': FormControl<int>(
        validators: [
          Validators.required,
          Validators.min(18),
          Validators.max(100),
        ],
      ),
      'phone': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(r'^\d{10}$'),
        ],
      ),
      'gender': FormControl<String>(
        validators: [Validators.required],
      ),
      'country': FormControl<String>(
        validators: [Validators.required],
      ),
      'acceptTerms': FormControl<bool>(
        value: false,
        validators: [Validators.requiredTrue],
      ),
      'bio': FormControl<String>(
        validators: [Validators.maxLength(200)],
      ),
      // Nested form group (like nested objects in react-hook-form)
      'address': FormGroup({
        'street': FormControl<String>(validators: [Validators.required]),
        'city': FormControl<String>(validators: [Validators.required]),
        'zipCode': FormControl<String>(
          validators: [
            Validators.required,
            Validators.pattern(r'^\d{5}$'),
          ],
        ),
      }),
      // Password matching (cross-field validation)
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
        ],
      ),
      'confirmPassword': FormControl<String>(
        validators: [Validators.required],
      ),
    });

    return ReactiveForm(
        formGroup: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Introduction Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Reactive Forms Demo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is similar to react-hook-form in React. It features:\n'
                        '• Reactive value changes\n'
                        '• Built-in validation\n'
                        '• Nested form groups\n'
                        '• Cross-field validation\n'
                        '• No manual controller management',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // First Name
              ReactiveTextField<String>(
                formControlName: 'firstName',
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  hintText: 'Enter your first name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'First name is required',
                  ValidationMessage.minLength: (_) =>
                      'First name must be at least 2 characters',
                },
              ),
              const SizedBox(height: 16),

              // Last Name
              ReactiveTextField<String>(
                formControlName: 'lastName',
                decoration: const InputDecoration(
                  labelText: 'Last Name *',
                  hintText: 'Enter your last name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Last name is required',
                },
              ),
              const SizedBox(height: 16),

              // Email
              ReactiveTextField<String>(
                formControlName: 'email',
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validationMessages: {
                  ValidationMessage.required: (_) => 'Email is required',
                  ValidationMessage.email: (_) => 'Please enter a valid email',
                },
              ),
              const SizedBox(height: 16),

              // Age
              ReactiveTextField<int>(
                formControlName: 'age',
                decoration: const InputDecoration(
                  labelText: 'Age *',
                  hintText: 'Enter your age',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validationMessages: {
                  ValidationMessage.required: (_) => 'Age is required',
                  ValidationMessage.min: (_) => 'Must be at least 18 years old',
                  ValidationMessage.max: (_) => 'Must be less than 100 years old',
                  ValidationMessage.number: (_) => 'Please enter a valid number',
                },
              ),
              const SizedBox(height: 16),

              // Phone
              ReactiveTextField<String>(
                formControlName: 'phone',
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '1234567890',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validationMessages: {
                  ValidationMessage.required: (_) => 'Phone number is required',
                  ValidationMessage.pattern: (_) =>
                      'Please enter a valid 10-digit phone number',
                },
              ),
              const SizedBox(height: 16),

              // Gender (Dropdown)
              ReactiveDropdownField<String>(
                formControlName: 'gender',
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(
                      value: 'prefer_not_to_say',
                      child: Text('Prefer not to say')),
                ],
                validationMessages: {
                  ValidationMessage.required: (_) => 'Please select your gender',
                },
              ),
              const SizedBox(height: 24),

              // Address Section (Nested Form Group)
              Text(
                'Address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Street
              ReactiveTextField<String>(
                formControlName: 'address.street',
                decoration: const InputDecoration(
                  labelText: 'Street Address *',
                  hintText: '123 Main St',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Street address is required',
                },
              ),
              const SizedBox(height: 16),

              // City
              ReactiveTextField<String>(
                formControlName: 'address.city',
                decoration: const InputDecoration(
                  labelText: 'City *',
                  hintText: 'New York',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'City is required',
                },
              ),
              const SizedBox(height: 16),

              // Zip Code
              ReactiveTextField<String>(
                formControlName: 'address.zipCode',
                decoration: const InputDecoration(
                  labelText: 'Zip Code *',
                  hintText: '12345',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validationMessages: {
                  ValidationMessage.required: (_) => 'Zip code is required',
                  ValidationMessage.pattern: (_) =>
                      'Please enter a valid 5-digit zip code',
                },
              ),
              const SizedBox(height: 16),

              // Country (Dropdown)
              ReactiveDropdownField<String>(
                formControlName: 'country',
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'usa', child: Text('United States')),
                  DropdownMenuItem(value: 'canada', child: Text('Canada')),
                  DropdownMenuItem(value: 'uk', child: Text('United Kingdom')),
                  DropdownMenuItem(value: 'australia', child: Text('Australia')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                validationMessages: {
                  ValidationMessage.required: (_) => 'Please select your country',
                },
              ),
              const SizedBox(height: 24),

              // Security Section (Password with cross-field validation)
              Text(
                'Security',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Password
              ReactiveTextField<String>(
                formControlName: 'password',
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Enter password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validationMessages: {
                  ValidationMessage.required: (_) => 'Password is required',
                  ValidationMessage.minLength: (_) =>
                      'Password must be at least 8 characters',
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              ReactiveTextField<String>(
                formControlName: 'confirmPassword',
                decoration: const InputDecoration(
                  labelText: 'Confirm Password *',
                  hintText: 'Re-enter password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validationMessages: {
                  ValidationMessage.required: (_) =>
                      'Please confirm your password',
                  'mustMatch': (_) => 'Passwords do not match',
                },
              ),
              const SizedBox(height: 24),

              // Additional Information
              Text(
                'Additional Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Bio (Multiline)
              ReactiveTextField<String>(
                formControlName: 'bio',
                decoration: const InputDecoration(
                  labelText: 'Bio (Optional)',
                  hintText: 'Tell us about yourself...',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validationMessages: {
                  ValidationMessage.maxLength: (_) =>
                      'Bio must not exceed 200 characters',
                },
              ),
              const SizedBox(height: 16),

              // Accept Terms (Checkbox)
              InkWell(
                onTap: () {
                  final control = form.control('acceptTerms') as FormControl<bool>;
                  control.value = !(control.value ?? false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ReactiveCheckbox(
                        formControlName: 'acceptTerms',
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'I accept the terms and conditions *',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'acceptTerms',
                builder: (context, control, child) {
                  if (control.hasErrors && control.touched) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                      child: Text(
                        'You must accept the terms and conditions',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),

              // Form Status (shows validation state)
              ReactiveFormConsumer(
                builder: (context, formGroup, child) {
                  return Column(
                    children: [
                      if (formGroup.hasErrors)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please fix the errors above',
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Submit Button
                      FilledButton.icon(
                        onPressed: () {
                          // Mark all fields as touched to show errors
                          formGroup.markAllAsTouched();

                          if (formGroup.valid) {
                            // Get form values (like form.getValues() in react-hook-form)
                            final values = formGroup.value;

                            // Check password matching manually since we removed the validator
                            final password = form.control('password').value;
                            final confirmPassword = form.control('confirmPassword').value;
                            if (password != confirmPassword) {
                              form.control('confirmPassword').setErrors({'mustMatch': true});
                              return;
                            }

                            // Show success dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Form Submitted Successfully!'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Submitted Data:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(values.toString()),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Reset form (like reset() in react-hook-form)
                                      formGroup.reset();
                                    },
                                    child: const Text('Reset Form'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Submit Form'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reset Button
                      OutlinedButton.icon(
                        onPressed: () {
                          formGroup.reset();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Form'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Watch Value Demo (like watch() in react-hook-form)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Live Form State (watch)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ReactiveValueListenableBuilder<String>(
                        formControlName: 'firstName',
                        builder: (context, control, child) {
                          return _buildFieldState(
                            'First Name',
                            control.value ?? '(empty)',
                            control.valid,
                            control.touched,
                            control.errors,
                          );
                        },
                      ),
                      const Divider(),
                      ReactiveValueListenableBuilder<String>(
                        formControlName: 'email',
                        builder: (context, control, child) {
                          return _buildFieldState(
                            'Email',
                            control.value ?? '(empty)',
                            control.valid,
                            control.touched,
                            control.errors,
                          );
                        },
                      ),
                      const Divider(),
                      ReactiveValueListenableBuilder<int>(
                        formControlName: 'age',
                        builder: (context, control, child) {
                          return _buildFieldState(
                            'Age',
                            control.value?.toString() ?? '(empty)',
                            control.valid,
                            control.touched,
                            control.errors,
                          );
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      ReactiveFormConsumer(
                        builder: (context, formGroup, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    formGroup.valid
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: formGroup.valid
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Form Valid: ${formGroup.valid ? "✓ Yes" : "✗ No"}',
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Form Touched: ${formGroup.touched ? "Yes" : "No"}',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ExpansionTile(
                                title: Text(
                                  'View All Form Values (JSON)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SelectableText(
                                      _formatJson(formGroup.value),
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // Helper method to build field state display
  Widget _buildFieldState(
    String label,
    String value,
    bool valid,
    bool touched,
    Map<String, dynamic>? errors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              valid ? Icons.check_circle : Icons.error,
              color: valid ? Colors.green : Colors.red,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Value: $value',
          style: TextStyle(
            color: Colors.green.shade900,
            fontSize: 12,
          ),
        ),
        Text(
          'Valid: ${valid ? "✓" : "✗"} | Touched: ${touched ? "Yes" : "No"}',
          style: TextStyle(
            color: Colors.green.shade700,
            fontSize: 11,
          ),
        ),
        if (errors != null && errors.isNotEmpty)
          Text(
            'Errors: ${errors.keys.join(", ")}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  // Helper method to format JSON for display
  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}
