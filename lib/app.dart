import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_cubit.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
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
        BlocProvider<FilterCubit>(
          create: (context) => FilterCubit(productsRepository)
            ..getListOfAllSellers()
            ..getListOfAvailableTags(),
        )
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
