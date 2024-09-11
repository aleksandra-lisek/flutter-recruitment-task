import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/blocs/filter_bloc/filters_bloc.dart';
import 'package:flutter_recruitment_task/blocs/filter_bloc/filters_events.dart';
import 'package:flutter_recruitment_task/cubits/home_cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

class App extends StatelessWidget {
  const App({
    required this.productsRepository,
    super.key,
  });

  final ProductsRepository productsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(productsRepository)..getNextPage(),
        ),
        BlocProvider<FilterBloc>(
          lazy: false,
          create: (context) =>
              FilterBloc(productsRepository)..add(FetchDataForFilters()),
        )
      ],
      child: const MaterialApp(
        home: HomePage(
          scrollProductId: '8',
        ),
      ),
    );
  }
}
