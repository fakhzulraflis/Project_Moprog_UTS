import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../services/language_asset_service.dart';
import 'login_page.dart';

class CreateAccountPage extends StatefulWidget {
  final String selectedLanguage;

  const CreateAccountPage({super.key, required this.selectedLanguage});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const Map<int, String> _months = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  static const List<String> _countries = [
    'Australia',
    'Canada',
    'Indonesia',
    'Japan',
    'Malaysia',
    'Singapore',
    'South Korea',
    'United Kingdom',
    'United States',
    'Other',
  ];

  static const List<String> _nativeLanguages = [
    'Bahasa Indonesia',
    'English',
    'Japanese',
    'Korean',
  ];

  static const List<String> _learningLanguages = [
    'English',
    'Japanese',
    'Korean',
  ];

  int? _birthDay;
  int? _birthMonth;
  int? _birthYear;
  String? _country;
  String? _nativeLanguage;
  String? _learningLanguage;
  bool _termsAccepted = false;
  bool _showTermsError = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;

  List<int> get _years => List<int>.generate(
    DateTime.now().year - 1900 + 1,
    (index) => DateTime.now().year - index,
  );

  @override
  void initState() {
    super.initState();
    _learningLanguage = widget.selectedLanguage;
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.baloo2(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF20272B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7C249)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String helperText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.baloo2(color: Colors.white),
            decoration: _inputDecoration(
              'Enter $label',
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
          const SizedBox(height: 4),
          _buildHelperText(helperText),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.baloo2(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHelperText(String text) {
    return Text(
      text,
      style: GoogleFonts.pixelifySans(color: Colors.white54, fontSize: 12),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String helperText,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF20272B),
            style: GoogleFonts.baloo2(color: Colors.white),
            decoration: _inputDecoration('Select $label'),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: (selected) =>
                selected == null ? 'Please select $label.' : null,
          ),
          const SizedBox(height: 4),
          _buildHelperText(helperText),
        ],
      ),
    );
  }

  Widget _buildDateDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String? Function(T?) validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: const Color(0xFF20272B),
      style: GoogleFonts.baloo2(color: Colors.white),
      decoration: _inputDecoration(hint),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateOfBirthFields() {
    final days = List<int>.generate(31, (index) => index + 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Date of Birth'),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateDropdown<int>(
                  hint: 'Day',
                  value: _birthDay,
                  items: days
                      .map(
                        (day) =>
                            DropdownMenuItem(value: day, child: Text('$day')),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _birthDay = value),
                  validator: (value) {
                    if (value == null) return 'Required';
                    if (_birthMonth != null && _birthYear != null) {
                      final lastDay = DateTime(
                        _birthYear!,
                        _birthMonth! + 1,
                        0,
                      ).day;
                      if (value > lastDay) return 'Invalid date';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildDateDropdown<int>(
                  hint: 'Month',
                  value: _birthMonth,
                  items: _months.entries
                      .map(
                        (month) => DropdownMenuItem(
                          value: month.key,
                          child: Text(month.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _birthMonth = value),
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildDateDropdown<int>(
                  hint: 'Year',
                  value: _birthYear,
                  items: _years
                      .map(
                        (year) =>
                            DropdownMenuItem(value: year, child: Text('$year')),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _birthYear = value),
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildHelperText('Select your date of birth.'),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value.trim())) return 'Enter a valid email.';
    return null;
  }

  Future<void> _createAccount() async {
    final isFormValid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_termsAccepted);
    if (!isFormValid || !_termsAccepted) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiService.createAccount(
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        birthDay: _birthDay!,
        birthMonth: _birthMonth!,
        birthYear: _birthYear!,
        country: _country!,
        nativeLanguage: _nativeLanguage!,
        learningLanguage: _learningLanguage!,
        password: _passwordController.text,
      );
    } catch (error) {
      if (mounted) {
        final message = error.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: const Color(0xFF20272B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Account Created\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome to Quacko! Your account is ready.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                _buildPrimaryButton(
                  label: 'CONTINUE',
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldContinue == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 231, 194, 73),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 190, 155, 45),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 260,
                  height: 220,
                  child: Image.asset(
                    LanguageAssetService.avatarFor(widget.selectedLanguage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Create your account',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Join Qua and start your learning journey.',
                style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF20272B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        helperText: 'Enter your real name.',
                        controller: _fullnameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Full name is required.'
                            : null,
                      ),
                      _buildTextField(
                        label: 'Username',
                        helperText: 'Example: johndoe',
                        controller: _usernameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Username is required.'
                            : null,
                      ),
                      _buildTextField(
                        label: 'Email',
                        helperText:
                            "We'll use this email to secure your account.",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      _buildDateOfBirthFields(),
                      _buildDropdownField(
                        label: 'Country',
                        helperText: 'Choose your country.',
                        value: _country,
                        options: _countries,
                        onChanged: (value) => setState(() => _country = value),
                      ),
                      _buildDropdownField(
                        label: 'Native Language',
                        helperText: 'Your primary language.',
                        value: _nativeLanguage,
                        options: _nativeLanguages,
                        onChanged: (value) =>
                            setState(() => _nativeLanguage = value),
                      ),
                      _buildDropdownField(
                        label: 'Learning Language',
                        helperText: 'Your selected Quacko course.',
                        value: _learningLanguage,
                        options: _learningLanguages,
                        onChanged: (value) =>
                            setState(() => _learningLanguage = value),
                      ),
                      _buildTextField(
                        label: 'Password',
                        helperText: 'Minimum 8 characters.',
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white54,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required.';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Confirm Password',
                        helperText: 'Must match your password.',
                        controller: _confirmPasswordController,
                        obscureText: _hideConfirmPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          ),
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white54,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password.';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFFE7C249);
                              }
                              return Colors.white12;
                            }),
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                              _showTermsError = false;
                            });
                          },
                          title: Text(
                            'I agree to the terms and conditions.',
                            style: GoogleFonts.baloo2(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          activeColor: const Color(0xFFE7C249),
                        ),
                      ),
                      if (_showTermsError && !_termsAccepted)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Please accept the terms and conditions.',
                            style: GoogleFonts.baloo2(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      _buildPrimaryButton(
                        label: _isSubmitting
                            ? 'CREATING ACCOUNT...'
                            : 'CREATE ACCOUNT',
                        onPressed: _isSubmitting ? null : _createAccount,
                      ),
                    ],
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
