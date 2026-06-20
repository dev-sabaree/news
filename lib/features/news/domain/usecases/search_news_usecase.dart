import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/domain/repositories/news_repository.dart';

class SearchNewsUseCase {
  final NewsRepository repository;

  const SearchNewsUseCase(this.repository);

  Future<List<NewsEntity>> call({
    required String query,
    required int page,
  }) {
    return repository.searchNews(query: query, page: page);
  }
}
