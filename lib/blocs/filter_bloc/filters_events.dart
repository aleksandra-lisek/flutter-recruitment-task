import 'package:flutter_recruitment_task/models/products_page.dart';

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
