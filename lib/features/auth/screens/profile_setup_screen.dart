import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admin/class_management/class_cubit.dart';
import '../cubit/auth_cubit.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    context.read<ClassCubit>().loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text('তোমার প্রোফাইল সেটআপ করো 🎓', 
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('তুমি কোন ক্লাসে পড়ো তা সিলেক্ট করো, আমরা সেই অনুযায়ী তোমার পড়া গুছিয়ে দেব।', 
                textAlign: TextAlign.center),
              const SizedBox(height: 40),

              // ক্লাস ড্রপডাউন
              BlocBuilder<ClassCubit, ClassState>(
                builder: (context, state) {
                  if (state is ClassLoaded) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'তোমার ক্লাস সিলেক্ট করো',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedClassId,
                      items: state.classes.map((cls) {
                        return DropdownMenuItem(value: cls.id, child: Text(cls.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedClassId = val),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _selectedClassId == null ? null : () {
                  // প্রোফাইল আপডেট লজিক
                  context.read<AuthCubit>().updateProfileClass(_selectedClassId!);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('শুরু করো 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}