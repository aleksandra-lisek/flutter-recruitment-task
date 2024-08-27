// Define Events
import 'package:flutter_recruitment_task/models/products_page.dart';

sealed class FilterPageState {
  const FilterPageState();
}

class LoadingFilterPage extends FilterPageState {
  const LoadingFilterPage();
}

class LoadedFilterPage extends FilterPageState {
  final List<Tag>? listOfAvailableTags;
  final List<Tag>? listOfSelectedTags;
  final List<String>? listOfSellers;
  final String? selectedSeller;
  final List<Product>? filteredProducts;

  LoadedFilterPage({
    this.listOfAvailableTags,
    this.listOfSelectedTags,
    this.listOfSellers,
    this.selectedSeller,
    this.filteredProducts,
  });

  LoadedFilterPage copyWith({
    List<Tag>? listOfAvailableTags,
    List<Tag>? listOfSelectedTags,
    List<String>? listOfSellers,
    String? selectedSeller,
    List<Product>? filteredProducts,
  }) {
    return LoadedFilterPage(
      listOfAvailableTags: listOfAvailableTags ?? this.listOfAvailableTags,
      listOfSelectedTags: listOfSelectedTags ?? this.listOfSelectedTags,
      listOfSellers: listOfSellers ?? this.listOfSellers,
      selectedSeller: selectedSeller ?? this.selectedSeller,
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }
}

class ErrorFilterPage extends FilterPageState {
  const ErrorFilterPage({required this.error});
  final dynamic error;
}
