import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:newsapp/l10n/app_localizations.dart';

import 'core/connectivity/connectivity_cubit.dart';
import 'core/connectivity/connectivity_state.dart';
import 'core/themes/app_theme.dart';
import 'core/localization/localization_service.dart';
import 'core/widgets/offline_banner.dart';
import 'routes/app_router.dart';
import 'dependency_injection/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ConnectivityCubit>()),
      ],
      child: ListenableBuilder(
        listenable: sl<LocalizationService>(),
        builder: (context, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'News App',
            theme: AppTheme.lightTheme,
            routerConfig: appRouter,
            locale: sl<LocalizationService>().currentLocale,
            builder: (context, child) {
              return Column(
                children: [
                  BlocBuilder<ConnectivityCubit, ConnectivityState>(
                    builder: (context, connectivityState) {
                      if (connectivityState is ConnectivityOffline) {
                        return OfflineBanner(
                          message: AppLocalizations.of(context)
                              .noInternetConnection,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            },
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
