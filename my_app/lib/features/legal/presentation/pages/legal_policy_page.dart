import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class LegalSection {
  final String title;
  final String body;

  const LegalSection({required this.title, required this.body});
}

class LegalPolicyPage extends StatelessWidget {
  static const _backgroundTop = Color(0xFF0A3A82);
  static const _backgroundBottom = Color(0xFF062A68);

  final String title;
  final List<LegalSection> sections;

  const LegalPolicyPage({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundBottom,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundTop, _backgroundBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 20, 20),
                child: Row(
                  children: [
                    _GlassBackButton(onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                    children: [
                      for (var i = 0; i < sections.length; i++) ...[
                        if (i > 0) const SizedBox(height: 26),
                        _SectionBlock(index: i + 1, section: sections[i]),
                      ],
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

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.index, required this.section});

  final int index;
  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${index.toString().padLeft(2, '0')}. ${section.title}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          section.body,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textMuted,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

const _placeholder = '[Placeholder - replace with your organization\'s copy.]';

List<LegalSection> termsOfServiceSections() => const [
  LegalSection(
    title: 'Welcome to Song List',
    body:
        'These Terms of Service govern your use of the Song List mobile app. '
        'By logging in and using the app, you agree to these terms. $_placeholder',
  ),
  LegalSection(
    title: 'Your account',
    body:
        'You are responsible for maintaining the confidentiality of your '
        'account credentials and for all activity that happens under your '
        'account. $_placeholder',
  ),
  LegalSection(
    title: 'User content',
    body:
        'You retain ownership of the song lists, lyrics, and notes you create '
        'in the app. You grant Song List a limited license to store, process, '
        'and display your content so the app can function. $_placeholder',
  ),
  LegalSection(
    title: 'Acceptable use',
    body:
        'You agree not to misuse the app, attempt to access it through means '
        'other than the interface provided, or interfere with its operation. '
        '$_placeholder',
  ),
  LegalSection(
    title: 'Changes to these terms',
    body:
        'We may update these terms from time to time. Material changes will be '
        'notified in the app. Continued use after changes take effect means you '
        'accept the updated terms. $_placeholder',
  ),
  LegalSection(
    title: 'Contact',
    body:
        'Questions about these terms can be sent through the Help & Feedback '
        'section in the app. $_placeholder',
  ),
];

List<LegalSection> privacyPolicySections() => const [
  LegalSection(
    title: 'Information we collect',
    body:
        'We collect the information you provide when you sign in, such as your '
        'name and email address, along with the song lists and content you '
        'create. $_placeholder',
  ),
  LegalSection(
    title: 'How we use information',
    body:
        'Your information is used to authenticate you, sync your data across '
        'devices, and improve the app. We do not sell your personal '
        'information. $_placeholder',
  ),
  LegalSection(
    title: 'Data sharing',
    body:
        'We share data only with service providers who help operate the app '
        '(such as hosting and authentication), and only to the extent needed '
        'to provide the service. $_placeholder',
  ),
  LegalSection(
    title: 'Data security',
    body:
        'We use industry-standard security measures to protect your data, '
        'including encrypted transmission and access controls. $_placeholder',
  ),
  LegalSection(
    title: 'Your choices',
    body:
        'You can update or delete content you created at any time. Deleting '
        'your account removes your personal data from our systems. '
        '$_placeholder',
  ),
  LegalSection(
    title: 'Contact',
    body:
        'Privacy questions can be sent through the Help & Feedback section in '
        'the app. $_placeholder',
  ),
];
