import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/class_model.dart';
import 'class_cubit.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({Key? key}) : super(key: key);

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  @override
  void initState() {
    super.initState();
    // স্ক্রিন লোড হওয়ার সাথে সাথে ক্লাসগুলো ফেচ করা
    context.read<ClassCubit>().loadClasses();
  }

  // --- নতুন ক্লাস তৈরি বা এডিট করার ডায়ালগ ---
  void _showClassDialog(BuildContext context, {ClassModel? existingClass}) {
    final nameController = TextEditingController(text: existingClass?.name);
    final codeController = TextEditingController(
      text: existingClass?.classCode,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                existingClass == null
                    ? Icons.add_circle_outline_rounded
                    : Icons.edit_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded( // বড় টাইটেলের ক্ষেত্রে রেসপন্সিভ করতে Expanded
                child: Text(
                  existingClass == null
                      ? 'নতুন ক্লাস যোগ করুন'
                      : 'ক্লাস এডিট করুন',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // কীবোর্ড ওপেন হলে যেন ওভারফ্লো না হয় তাই SingleChildScrollView
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'ক্লাসের নাম (যেমন: Class 10)',
                      prefixIcon: const Icon(Icons.school_rounded),
                      filled: true,
                      fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'নাম প্রদান করা আবশ্যক' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'ক্লাস কোড (ঐচ্ছিক)',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      filled: true,
                      fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (existingClass == null) {
                    // Create New
                    final newClass = ClassModel(
                      id: '', // Supabase Auto-generate করবে
                      name: nameController.text.trim(),
                      classCode: codeController.text.trim(),
                      isActive: true,
                    );
                    context.read<ClassCubit>().addClass(newClass);
                  } else {
                    // Update Existing
                    context.read<ClassCubit>().updateClass(existingClass.id, {
                      'name': nameController.text.trim(),
                      'class_code': codeController.text.trim(),
                    });
                  }
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(
                existingClass == null ? 'সেভ করুন' : 'আপডেট করুন',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- ক্লাস ডিলিট করার কনফার্মেশন ডায়ালগ ---
  void _confirmDelete(BuildContext context, ClassModel classModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('সতর্কতা!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'আপনি কি সত্যিই "${classModel.name}" ক্লাসটি ডিলিট করতে চান? এর ভেতরের সব সাবজেক্ট ও কুইজ ডিলিট হয়ে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'না, বাতিল করুন',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<ClassCubit>().deleteClass(classModel.id);
              Navigator.pop(ctx);
            },
            child: const Text('হ্যাঁ, ডিলিট করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // যদি প্যারেন্ট ব্যাকগ্রাউন্ড থাকে
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClassDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'নতুন ক্লাস',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      // SafeArea যোগ করা হলো যেন সিস্টেম UI এর নিচে কনটেন্ট না চলে যায়
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // ছোট স্ক্রিনের জন্য অপটিমাইজড
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ক্লাস ম্যানেজমেন্ট 🏫',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার সিস্টেমের সব ক্লাস এখান থেকে ম্যানেজ করুন।',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: BlocConsumer<ClassCubit, ClassState>(
                  listener: (context, state) {
                    if (state is ClassError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ClassLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClassLoaded) {
                      if (state.classes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 80,
                                color: theme.dividerColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'কোনো ক্লাস পাওয়া যায়নি। নতুন ক্লাস যোগ করুন।',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.classes.length,
                        itemBuilder: (context, index) {
                          final cls = state.classes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E2C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    cls.name.isNotEmpty 
                                        ? cls.name.substring(0, 1).toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                cls.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis, // লম্বা নামের জন্য রেসপন্সিভ
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                // Row এর বদলে Wrap ব্যবহার করা হলো যেন ছোট স্ক্রিনে ভেঙে নিচে নেমে যায়
                                child: Wrap(
                                  spacing: 12, // আইটেমগুলোর মাঝের গ্যাপ
                                  runSpacing: 8, // নিচে নামলে গ্যাপ
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.tag_rounded,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          cls.classCode != null &&
                                                  cls.classCode!.isNotEmpty
                                              ? cls.classCode!
                                              : 'N/A',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cls.isActive
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cls.isActive ? 'অ্যাকটিভ' : 'আর্কাইভ',
                                        style: TextStyle(
                                          color: cls.isActive
                                              ? Colors.green
                                              : Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () => _showClassDialog(
                                      context,
                                      existingClass: cls,
                                    ),
                                    constraints: const BoxConstraints(), // ডিফল্ট মার্জিন কমাতে
                                    padding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, cls),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}