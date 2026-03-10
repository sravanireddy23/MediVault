import 'package:flutter/material.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;

  const SettingsScreen({
    super.key,
    this.userName = 'User',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _lightBg   = Color(0xFFF5F8FF);
  static const _darkText  = Color(0xFF1A1A2E);
  static const _red       = Color(0xFFD32F2F);

  bool _notificationsEnabled = true;
  bool _biometricEnabled     = false;
  final bool _darkModeEnabled = false;
  bool _twoFactorEnabled     = false;
  String _selectedLanguage   = 'English';

  String get _initials {
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSection('App Settings', Icons.settings_rounded,
                    _buildAppSettings()),
                const SizedBox(height: 16),
                _buildSection('Security & Privacy', Icons.shield_rounded,
                    _buildSecurityPrivacy()),
                const SizedBox(height: 16),
                _buildSection('Account', Icons.manage_accounts_rounded,
                    _buildAccountActions()),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      elevation: 0,
      backgroundColor: _blue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue, _blueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6), width: 2),
                    ),
                    child: Center(
                      child: Text(_initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('Settings & Preferences',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section wrapper ──────────────────────────────────────────────────────────
  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: _blue, size: 15),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: _darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: content,
          ),
        ],
      ),
    );
  }

  // ── App Settings ─────────────────────────────────────────────────────────────
  Widget _buildAppSettings() {
    return Column(
      children: [
        _toggleTile(
          icon: Icons.notifications_rounded,
          iconColor: const Color(0xFFEF6C00),
          iconBg: const Color(0xFFFFF3E0),
          label: 'Notifications',
          subtitle: 'Record reminders & updates',
          value: _notificationsEnabled,
          onChanged: (v) => setState(() => _notificationsEnabled = v),
        ),
        _divider(),
        _toggleTile(
          icon: Icons.fingerprint_rounded,
          iconColor: const Color(0xFF1565C0),
          iconBg: const Color(0xFFE3F2FD),
          label: 'Biometric Lock',
          subtitle: 'Fingerprint / Face unlock',
          value: _biometricEnabled,
          onChanged: (v) => setState(() => _biometricEnabled = v),
        ),
        _divider(),
        _toggleTile(
          icon: Icons.dark_mode_rounded,
          iconColor: const Color(0xFF1A1A2E),
          iconBg: const Color(0xFFECEFF1),
          label: 'Dark Mode',
          subtitle: 'Coming soon',
          value: _darkModeEnabled,
          onChanged: null,
        ),
        _divider(),
        _tappableTile(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF00897B),
          iconBg: const Color(0xFFE0F2F1),
          label: 'Language',
          subtitle: _selectedLanguage,
          onTap: () => _showLanguagePicker(),
        ),
      ],
    );
  }

  // ── Security & Privacy ───────────────────────────────────────────────────────
  Widget _buildSecurityPrivacy() {
    return Column(
      children: [
        _tappableTile(
          icon: Icons.lock_rounded,
          iconColor: const Color(0xFF1565C0),
          iconBg: const Color(0xFFE3F2FD),
          label: 'Change PIN / Password',
          onTap: () => _showComingSoon('Change PIN'),
        ),
        _divider(),
        _toggleTile(
          icon: Icons.security_rounded,
          iconColor: const Color(0xFF2E7D32),
          iconBg: const Color(0xFFE8F5E9),
          label: 'Two-Factor Authentication',
          subtitle: '2FA via SMS',
          value: _twoFactorEnabled,
          onChanged: (v) => setState(() => _twoFactorEnabled = v),
        ),
        _divider(),
        _tappableTile(
          icon: Icons.privacy_tip_rounded,
          iconColor: const Color(0xFF8E24AA),
          iconBg: const Color(0xFFF3E5F5),
          label: 'Data Privacy Settings',
          onTap: () => _showComingSoon('Data Privacy'),
        ),
        _divider(),
        _tappableTile(
          icon: Icons.download_rounded,
          iconColor: const Color(0xFF00838F),
          iconBg: const Color(0xFFE0F7FA),
          label: 'Download My Data',
          subtitle: 'Export all records as PDF',
          onTap: () => _showComingSoon('Export Data'),
        ),
      ],
    );
  }

  // ── Account Actions ──────────────────────────────────────────────────────────
  Widget _buildAccountActions() {
    return Column(
      children: [
        _tappableTile(
          icon: Icons.help_outline_rounded,
          iconColor: const Color(0xFF1565C0),
          iconBg: const Color(0xFFE3F2FD),
          label: 'Help & Support',
          onTap: () => _showComingSoon('Help & Support'),
        ),
        _divider(),
        _tappableTile(
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF546E7A),
          iconBg: const Color(0xFFECEFF1),
          label: 'About MediVault',
          subtitle: 'Version 1.0.0',
          onTap: () => _showAboutDialog(),
        ),
        _divider(),
        _tappableTile(
          icon: Icons.logout_rounded,
          iconColor: _red,
          iconBg: const Color(0xFFFFEBEE),
          label: 'Logout',
          labelColor: _red,
          onTap: () => _confirmLogout(),
        ),
        _divider(),
        _tappableTile(
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.grey.shade400,
          iconBg: Colors.grey.shade100,
          label: 'Delete Account',
          labelColor: Colors.grey.shade400,
          subtitle: 'Permanently removes all your data',
          onTap: () => _confirmDeleteAccount(),
        ),
      ],
    );
  }

  // ── Reusable Tiles ───────────────────────────────────────────────────────────
  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    String? subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: onChanged == null
                            ? Colors.grey.shade400
                            : _darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _blue,
            activeTrackColor: _blue.withValues(alpha: 0.4),
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _tappableTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    String? subtitle,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: labelColor ?? _darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.withValues(alpha: 0.1),
    indent: 16,
    endIndent: 16,
  );

  // ── Dialogs & Sheets ─────────────────────────────────────────────────────────
  void _showLanguagePicker() {
    final languages = ['English', 'Hindi', 'Telugu', 'Tamil', 'Kannada'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.language_rounded, color: _blue, size: 18),
                SizedBox(width: 8),
                Text('Select Language',
                    style: TextStyle(
                        color: _darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) => ListTile(
              title: Text(lang,
                  style: TextStyle(
                      color: _darkText,
                      fontWeight: _selectedLanguage == lang
                          ? FontWeight.bold
                          : FontWeight.normal)),
              trailing: _selectedLanguage == lang
                  ? const Icon(Icons.check_circle_rounded, color: _blue)
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style:
            TextStyle(color: _darkText, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: _red, size: 20),
            SizedBox(width: 8),
            Text('Delete Account',
                style:
                TextStyle(color: _red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'This will permanently delete your account and ALL medical records. This action cannot be undone.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Account deletion requested', isError: true);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _red,
              side: const BorderSide(color: _red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_hospital_rounded, color: _blue, size: 22),
            SizedBox(width: 8),
            Text('MediVault',
                style: TextStyle(
                    color: _darkText, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              'Your lifelong medical records — secure, organized, always accessible.',
              style:
              TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text('Built with ❤️ for better personal healthcare.',
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: _blue)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('$feature — Coming soon!'),
          ],
        ),
        backgroundColor: _blue,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _red : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}