import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/domain/repositories/news_repository.dart';

class GetCachedNewsUseCase {
  final NewsRepository repository;

  const GetCachedNewsUseCase(this.repository);

  Future<List<NewsEntity>> call() {
    return repository.getCachedNews();
  }
}
