import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/story_provider.dart';
import '../models/child_info.dart';
import '../widgets/steps/step_data.dart';
import '../widgets/steps/welcome_step.dart';
import '../widgets/steps/upload_step.dart';
import '../widgets/steps/name_step.dart';
import '../widgets/steps/adventure_step.dart';
import '../widgets/steps/look_step.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  // Steps: 0=welcome, 1=upload, 2=name, 3=adventure, 4=look
  int _step = 0;
  Uint8List? _photoBytes;
  String? _photoFileName;
  final _nameController = TextEditingController();
  int _selectedCategory = 0;
  int _selectedStyle = 0;

  late AnimationController _contentController;
  late AnimationController _foxController;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentFade;
  late Animation<Offset> _foxSlide;
  late Animation<double> _foxFade;

  bool get _foxIsLeft => foxConfig[_step][1] as bool;
  String get _foxAsset => foxConfig[_step][0] as String;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _foxController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _setupAnimations();
    _contentController.forward();
    _foxController.forward();
  }

  void _setupAnimations({bool forward = true}) {
    final contentBegin = forward ? const Offset(1.0, 0) : const Offset(-1.0, 0);
    _contentSlide = Tween<Offset>(begin: contentBegin, end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    final foxBegin = _foxIsLeft ? const Offset(-1.0, 0) : const Offset(1.0, 0);
    _foxSlide = Tween<Offset>(begin: foxBegin, end: Offset.zero).animate(
      CurvedAnimation(parent: _foxController, curve: Curves.easeOutBack),
    );
    _foxFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _foxController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
  }

  Future<void> _animateToStep(int newStep) async {
    final goingForward = newStep > _step;
    await Future.wait([
      _contentController.reverse(),
      _foxController.reverse(),
    ]);

    setState(() => _step = newStep);
    _setupAnimations(forward: goingForward);

    _contentController.forward();
    _foxController.forward();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _photoBytes = result.files.single.bytes;
        _photoFileName = result.files.single.name;
      });
    }
  }

  void _next() {
    if (_step == 2 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your hero\'s name'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_step < 4) {
      _animateToStep(_step + 1);
    } else {
      _submit();
    }
  }

  void _submit() {
    final childInfo = ChildInfo(
      name: _nameController.text.trim(),
      age: 5,
      photoBytes: _photoBytes,
      photoFileName: _photoFileName,
      theme: categories[_selectedCategory].key,
      style: styles[_selectedStyle].key,
    );
    final provider = context.read<StoryProvider>();
    provider.startStory(childInfo);
    context.go('/story');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _foxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;
    final foxHeight = _step == 0
        ? (isDesktop ? size.height * 0.88 : size.height * 0.6)
        : (isDesktop ? size.height * 0.70 : size.height * 0.6);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fox
          Positioned(
            left: _foxIsLeft ? (isDesktop ? 32 : -15) : null,
            right: _foxIsLeft ? null : (isDesktop ? 42 : -15),
            bottom: isDesktop && !(_step == 3 || _step == 4) ? -100 :  -180,
            child: AnimatedBuilder(
              animation: _foxController,
              builder: (context, child) => FadeTransition(
                opacity: _foxFade,
                child: SlideTransition(position: _foxSlide, child: child),
              ),
              child: Transform.flip(
                flipX: !_foxIsLeft,
                child: Image.asset(
                  _foxAsset,
                  height: foxHeight,
                  width: isDesktop ? foxHeight * 0.88 : foxHeight * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (context, child) => FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(position: _contentSlide, child: child),
              ),
              child: Center(child: _buildStep(isDesktop)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(bool isDesktop) {
    switch (_step) {
      case 0:
        return WelcomeStep(isDesktop: isDesktop, onNext: _next);
      case 1:
        return UploadStep(isDesktop: isDesktop, photoBytes: _photoBytes, onPickPhoto: _pickPhoto, onNext: _next);
      case 2:
        return NameStep(isDesktop: isDesktop, nameController: _nameController, onNext: _next);
      case 3:
        return AdventureStep(
          isDesktop: isDesktop,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (i) => setState(() => _selectedCategory = i),
          onNext: _next,
        );
      case 4:
        return LookStep(
          isDesktop: isDesktop,
          selectedStyle: _selectedStyle,
          onStyleChanged: (i) => setState(() => _selectedStyle = i),
          onNext: _next,
        );
      default:
        return const SizedBox();
    }
  }
}
