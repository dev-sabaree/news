import 'package:json_annotation/json_annotation.dart';
import 'package:newsapp/features/news/domain/entities/news_entity.dart';

part 'news_model.g.dart';

@JsonSerializable()
class NewsModel {
  @JsonKey(defaultValue: '', fromJson: _stringFromJson)
  final String title;

  @JsonKey(defaultValue: '', fromJson: _stringFromJson)
  final String description;

  @JsonKey(defaultValue: '', fromJson: _stringFromJson)
  final String content;

  @JsonKey(name: 'urlToImage', defaultValue: '', fromJson: _stringFromJson)
  final String imageUrl;

  @JsonKey(defaultValue: '', fromJson: _stringFromJson)
  final String author;

  @JsonKey(name: 'url', defaultValue: '', fromJson: _stringFromJson)
  final String articleUrl;

  @JsonKey(defaultValue: '', fromJson: _stringFromJson)
  final String publishedAt;

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
    if (source is Map) {
      return _stringFromJson(source['name']);
    }
    if (source is String) {
      return source;
    }
    return '';
  }

  static Map<String, dynamic> _sourceToJson(String source) {
    return {'name': source};
  }

  static String _stringFromJson(Object? value) => value is String ? value : '';
}
