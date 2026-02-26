import 'package:expensive/core/network/dio_service.dart';
import 'package:expensive/core/services/notification_service.dart';
import 'package:expensive/core/services/prefs_service.dart';
import 'package:expensive/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expensive/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expensive/features/auth/domain/repositories/auth_repository.dart';
import 'package:expensive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expensive/features/home/presentation/bloc/home_bloc.dart';
import 'package:expensive/features/profile/bloc/profile_bloc.dart';
import 'package:expensive/features/profile/data/datasources/sync_remote_data_source.dart';
import 'package:expensive/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expensive/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expensive/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:expensive/features/welcome/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  final dioService = DioService();
  final prefsService = PrefsService();
  final remoteDataSource = AuthRemoteDataSource(dioService);
  final authRepository = AuthRepositoryImpl(remoteDataSource, prefsService);
  final syncRemoteDataSource = SyncRemoteDataSource(dioService);
  final transactionRepository = TransactionRepositoryImpl(syncRemoteDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (context) => authRepository),
        RepositoryProvider<TransactionRepository>(
          create: (context) => transactionRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc(authRepository)),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(transactionRepository),
          ),
          BlocProvider<TransactionsBloc>(
            create: (context) => TransactionsBloc(transactionRepository),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(transactionRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
