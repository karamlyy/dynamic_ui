import 'dart:io' show Platform;
import 'package:dynamic_ui/cubit/dynamic_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/dynamic_repository.dart';
import 'cubit/dynamic_cubit.dart';
import 'ui/section_view.dart';

void main() {
  runApp(const DynamicApp());
}

String _getBaseUrl({String? overrideForDevice}) {
  if (overrideForDevice != null && overrideForDevice.isNotEmpty) {
    return overrideForDevice;
  }

  if (kIsWeb) {
    return 'http://localhost:8080';
  }

  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080';
  } else if (Platform.isIOS) {
    return 'http://localhost:8080';
  } else {
    return 'http://localhost:8080';
  }
}

class DynamicApp extends StatelessWidget {
  const DynamicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseUrl = _getBaseUrl();
    return MaterialApp(
      title: 'Dinamik App (Cubit + HTTP)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RepositoryProvider(
        create: (_) => DynamicRepository(baseUrl: baseUrl),
        child: BlocProvider(
          create: (context) => DynamicCubit(repository: context.read<DynamicRepository>()),
          child: const HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _loadUser(BuildContext context, int userId) {
    context.read<DynamicCubit>().loadForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinamik App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () => _loadUser(context, 1), child: const Text('Load user 1')),
                ElevatedButton(onPressed: () => _loadUser(context, 2), child: const Text('Load user 2')),
                ElevatedButton(onPressed: () => _loadUser(context, 3), child: const Text('Load user 3')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<DynamicCubit, DynamicState>(
                builder: (context, state) {
                  if (state is DynamicInitial) {
                    return const Center(child: Text('İstifadəçi yükləyin (yuxarıdakı düymələrdən seçin)'));
                  } else if (state is DynamicLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DynamicError) {
                    return Center(child: Text('Xəta: ${state.message}'));
                  } else if (state is DynamicLoaded) {
                    return SectionView(
                      sections: state.sections,
                      selectedSectionId: state.selectedSectionId,
                      onSelectSection: (id) => context.read<DynamicCubit>().selectSection(id),
                      repository: context.read<DynamicRepository>(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}