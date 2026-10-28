import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/account/data/datasources/theme_local_data_source.dart';
import '../../features/account/data/repositories/theme_repository_impl.dart';
import '../../features/account/domain/repositories/theme_repository.dart';
import '../../features/account/domain/usecases/get_theme_usecase.dart';
import '../../features/account/domain/usecases/save_theme_usecase.dart';
import '../../features/account/presentation/provider/theme_provider.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_session_usecase.dart';
import '../../features/auth/domain/usecases/get_saved_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';
import '../../features/auth/presentation/provider/login_provider.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart_usecase.dart';
import '../../features/cart/domain/usecases/change_quantity_usecase.dart';
import '../../features/cart/domain/usecases/get_cart_items_usecase.dart';
import '../../features/cart/domain/usecases/place_order_usecase.dart';
import '../../features/cart/domain/usecases/remove_from_cart_usecase.dart';
import '../../features/cart/presentation/provider/cart_provider.dart';
import '../../features/categories/data/datasources/categories_remote_data_source.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/domain/usecases/get_products_by_category_usecase.dart';
import '../../features/categories/presentation/provider/categories_provider.dart';
import '../../features/categories/presentation/provider/category_products_provider.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/usecases/get_product_details_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/search_products_usecase.dart';
import '../../features/products/presentation/provider/product_details_provider.dart';
import '../../features/products/presentation/provider/product_list_provider.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_factory.dart';
import '../network/token_provider.dart';
import '../router/app_router.dart';
import '../session/session_expired_notifier.dart';
import '../storage/prefs_service.dart';

/// Service locator. Widgets get everything from here, never `new` it.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---- Core ----
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<PrefsService>(PrefsService(prefs))
    ..registerSingleton<SessionExpiredNotifier>(SessionExpiredNotifier())
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<TokenProvider>(() => sl<AuthLocalDataSource>())
    ..registerLazySingleton<Dio>(
      () => DioFactory.create(
        authInterceptor: AuthInterceptor(
          tokens: sl(),
          plainDio: DioFactory.plain(),
          sessionNotifier: sl(),
        ),
      ),
    );

  _registerAuth();
  _registerProducts();
  _registerCategories();
  _registerCart();
  _registerAccount();

  sl.registerLazySingleton<GoRouter>(
    () => AppRouter.create(sl<AuthProvider>()),
  );
}

void _registerAuth() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), local: sl()),
    )
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => GetSavedUserUseCase(sl()))
    ..registerLazySingleton(() => CheckSessionUseCase(sl()))
    ..registerLazySingleton(
      () => AuthProvider(
        checkSession: sl(),
        getSavedUser: sl(),
        logout: sl(),
        sessionNotifier: sl(),
      ),
    )
    ..registerFactory(() => LoginProvider(sl()));
}

void _registerProducts() {
  sl
    ..registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetProductsUseCase(sl()))
    ..registerLazySingleton(() => SearchProductsUseCase(sl()))
    ..registerLazySingleton(() => GetProductDetailsUseCase(sl()))
    ..registerFactory(
      () => ProductListProvider(getProducts: sl(), searchProducts: sl()),
    )
    ..registerFactory(() => ProductDetailsProvider(sl()));
}

void _registerCategories() {
  sl
    ..registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetCategoriesUseCase(sl()))
    ..registerLazySingleton(() => GetProductsByCategoryUseCase(sl()))
    ..registerFactory(() => CategoriesProvider(sl()))
    ..registerFactory(() => CategoryProductsProvider(sl()));
}

void _registerCart() {
  sl
    ..registerLazySingleton<CartLocalDataSource>(
      () => CartLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetCartItemsUseCase(sl()))
    ..registerLazySingleton(() => AddToCartUseCase(sl()))
    ..registerLazySingleton(() => ChangeQuantityUseCase(sl()))
    ..registerLazySingleton(() => RemoveFromCartUseCase(sl()))
    ..registerLazySingleton(() => PlaceOrderUseCase(sl()))
    ..registerLazySingleton(
      () => CartProvider(
        getCartItems: sl(),
        addToCart: sl(),
        changeQuantity: sl(),
        removeFromCart: sl(),
        placeOrder: sl(),
      ),
    );
}

void _registerAccount() {
  sl
    ..registerLazySingleton<ThemeLocalDataSource>(
      () => ThemeLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetThemeUseCase(sl()))
    ..registerLazySingleton(() => SaveThemeUseCase(sl()))
    ..registerLazySingleton(
      () => ThemeProvider(getTheme: sl(), saveTheme: sl()),
    );
}
