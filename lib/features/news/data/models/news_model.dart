import 'package:json_annotation/json_annotation.dart';
import 'package:newsapp/features/news/domain/entities/news_entity.dart';

part 'news_model.g.dart';

@JsonSerializable()
class NewsModel {
  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: '')
  final String content;

  @JsonKey(name: 'urlToImage', defaultValue: '')
  final String imageUrl;

  @JsonKey(defaultValue: '')
  final String author;

  @JsonKey(name: 'url', defaultValue: '')
  final String articleUrl;

  @JsonKey(defaultValue: '')
  final String publishedAt;

  // 👇 added toJson converter so source saves as Map, not String
  @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
  final String source;

  const NewsModel({
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.articleUrl,
    required this.publishedAt,
    required this.source,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsModelToJson(this);

  NewsEntity toEntity() {
    return NewsEntity(
      title: title,
      description: description,
      content: content,
      imageUrl: imageUrl,
      author: author,
      articleUrl: articleUrl,
      publishedAt: publishedAt,
      source: source,
    );
  }

  static String _sourceFromJson(dynamic source) {
    // 👇 handles both Map (from API) and String (from cache)
    if (source is Map<String, dynamic>) {
      return source['name'] ?? '';
    }
    if (source is String) {
      return source;
    }
    return '';
  }

  // 👇 added - saves source as Map so fromJson can always read it
  static Map<String, dynamic> _sourceToJson(String source) {
    return {'name': source};
  }
}
