import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filters_state.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

abstract class FilterEvent {}

class FetchDataForFilters extends FilterEvent {}

class UpdateSelectedTagEvent extends FilterEvent {
  final Tag tag;
  UpdateSelectedTagEvent(this.tag);
}

class UpdateSelectedSellersEvent extends FilterEvent {
  final String? sellerId;
  UpdateSelectedSellersEvent(this.sellerId);
}

class ClearFiltersEvent extends FilterEvent {}

class ApplyFiltersEvent extends FilterEvent {
  ApplyFiltersEvent();
}

class FilterBloc extends Bloc<FilterEvent, FilterPageState> {
  final ProductsRepository _productsRepository;

  FilterBloc(this._productsRepository)
      : super(
          const LoadingFilterPage(),
        ) {
    on<FetchDataForFilters>(_fetchDataForFilters);
    on<UpdateSelectedTagEvent>(_onUpdateSelectedTag);
    on<UpdateSelectedSellersEvent>(_onUpdateSelectedSellers);
    on<ApplyFiltersEvent>(_onApplyFilters);
  }

  Future<List<Product>> _getListOfAllProducts() async {
    final ProductsPage newPage = await _productsRepository
        .getProductsPage(GetProductsPage(pageNumber: 1));

    try {
      final List<Future<ProductsPage>> pageFutures = List.generate(
        newPage.totalPages,
        (index) => _productsRepository
            .getProductsPage(GetProductsPage(pageNumber: index + 1)),
      );

      final pages = await Future.wait(pageFutures);
      final products = pages.expand((page) => page.products).toList();

      return products;
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchDataForFilters(
      FetchDataForFilters event, Emitter<FilterPageState> emit) async {
    try {
      emit(await _onLoadAvailableFilters());
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }

  Future<FilterPageState> _onLoadAvailableFilters() async {
    try {
      final products = await _getListOfAllProducts();
      final uniqueTags =
          products.expand((product) => product.tags).toSet().toList();
      final sellers =
          products.map((product) => product.offer.sellerName).toSet().toList();

      return LoadedFilterPage().copyWith(
        listOfAvailableTags: uniqueTags,
        listOfAvailableSellers: sellers,
      );
    } catch (e) {
      return ErrorFilterPage(error: e);
    }
  }

  Future<void> _onUpdateSelectedTag(
      UpdateSelectedTagEvent event, Emitter<FilterPageState> emit) async {
    try {
      if (state is LoadedFilterPage) {
        final currentState = state as LoadedFilterPage;
        final List<Tag> updatedTags = currentState.listOfSelectedTags ?? [];

        if (updatedTags.contains(event.tag) == true) {
          updatedTags.removeWhere((element) => element.tag == event.tag.tag);
        } else {
          updatedTags.add(event.tag);
        }
        emit(currentState.copyWith(listOfSelectedTags: updatedTags));
      }
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }

  Future<void> _onUpdateSelectedSellers(
      UpdateSelectedSellersEvent event, Emitter<FilterPageState> emit) async {
    try {
      if (state is LoadedFilterPage) {
        final currentState = state as LoadedFilterPage;

        emit(currentState.copyWith(selectedSeller: event.sellerId));
      }
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }

  Future<void> _onApplyFilters(
      ApplyFiltersEvent event, Emitter<FilterPageState> emit) async {
    try {
      if (state is LoadedFilterPage) {
        final currentState = state as LoadedFilterPage;

        // Fetch all products
        final products = await _getListOfAllProducts();

        // Get selected filters
        final selectedSellerId = currentState.selectedSeller;
        final selectedTags = currentState.listOfSelectedTags ?? [];

        // Filter products by the selected seller and selected tags
        final filteredProducts = products.where((product) {
          final matchesSeller = selectedSellerId == null ||
              product.offer.sellerName == selectedSellerId;
          final matchesTags = selectedTags.isEmpty ||
              selectedTags.every((tag) => product.tags.contains(tag));
          return matchesSeller && matchesTags;
        }).toList();

        // Emit the state with the filtered products
        emit(currentState.copyWith(
          filteredProducts: filteredProducts,
          areProductsFiltered: true,
        ));
      }
    } catch (e) {
      emit(ErrorFilterPage(error: e));
    }
  }
}
