import 'package:demo_course_app/core/presentation/auth/bloc/auth_bloc.dart';
import 'package:demo_course_app/core/presentation/auth/bloc/events/auth_events.dart';
import 'package:demo_course_app/core/presentation/auth/bloc/state/auth_state.dart';
import 'package:demo_course_app/core/domain/auth/service/auth_service.dart';
import 'package:demo_course_app/modules/auth/auth_page.dart';
import 'package:demo_course_app/modules/auth/root_navi.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_bloc.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_event.dart';
import 'package:demo_course_app/core/domain/cart/service/cart_firebase_service.dart';
import 'package:demo_course_app/core/data_storage/cart/services/cart_hive_service.dart';
import 'package:demo_course_app/core/domain/cart/service/cart_sync.dart';
import 'package:demo_course_app/core/presentation/product/bloc/product_bloc.dart';
import 'package:demo_course_app/core/presentation/product/bloc/product_event.dart';
import 'package:demo_course_app/core/data/product/models/product_hive.dart';
import 'package:demo_course_app/core/domain/product/service/product_firebase_service.dart';
import 'package:demo_course_app/core/data_storage/product/service/product_local_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await dotenv.load(fileName: "api/.env");
  await Firebase.initializeApp();

  await Hive.initFlutter();

  //  Register adapters
  Hive.registerAdapter(ProductHiveModelAdapter());

  //  Open boxes
  final productBox = await Hive.openBox<ProductHiveModel>('products');

  final cartBox = await Hive.openBox('cart_box'); 

  //  Initialize services
  final productHiveService = ProductHiveService(productBox);
  final productFirebaseService = ProductFirebaseService();

  final cartHiveService = CartHiveService(cartBox);
  final cartFirebaseService = CartFirebaseService();
  final cartSyncService = CartSyncService(cartHiveService, cartFirebaseService);

  runApp(
    MyApp(
      productHiveService: productHiveService,
      productFirebaseService: productFirebaseService,
      cartHiveService: cartHiveService,
      cartSyncService: cartSyncService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ProductHiveService productHiveService;
  final ProductFirebaseService productFirebaseService;

  final CartHiveService cartHiveService;
  final CartSyncService cartSyncService;

  const MyApp({
    super.key,
    required this.productHiveService,
    required this.productFirebaseService,
    required this.cartHiveService,
    required this.cartSyncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: productHiveService),
        RepositoryProvider.value(value: productFirebaseService),
        RepositoryProvider.value(value: cartHiveService),
        RepositoryProvider.value(value: cartSyncService),
      ],
      child: MultiBlocProvider(
        providers: [
          /// AUTH BLOC
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(AuthService())..add(AppStarted()),
          ),

          /// PRODUCT BLOC
          BlocProvider<ProductBloc>(
            create: (_) => ProductBloc(
              hiveService: productHiveService,
              firebaseService: productFirebaseService,
            )..add(LoadProducts()),
          ),

          ///  CART BLOC
          BlocProvider<CartBloc>(
            create: (_) => CartBloc(cartHiveService, cartSyncService)
              ..add(LoadCart())
              ..add(SyncCart()), // auto sync on start
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<CartBloc>().add(LoadCart());
            context.read<ProductBloc>().add(LoadProducts());
            return MainNavigationScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
