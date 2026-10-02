// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsModel _$NewsModelFromJson(Map<String, dynamic> json) => NewsModel(
  title: json['title'] == null ? '' : NewsModel._stringFromJson(json['title']),
  description: json['description'] == null
      ? ''
      : NewsModel._stringFromJson(json['description']),
  content: json['content'] == null
      ? ''
      : NewsModel._stringFromJson(json['content']),
  imageUrl: json['urlToImage'] == null
      ? ''
      : NewsModel._stringFromJson(json['urlToImage']),
  author: json['author'] == null
      ? ''
      : NewsModel._stringFromJson(json['author']),
  articleUrl: json['url'] == null ? '' : NewsModel._stringFromJson(json['url']),
  publishedAt: json['publishedAt'] == null
      ? ''
      : NewsModel._stringFromJson(json['publishedAt']),
  source: NewsModel._sourceFromJson(json['source']),
);

Map<String, dynamic> _$NewsModelToJson(NewsModel instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'content': instance.content,
  'urlToImage': instance.imageUrl,
  'author': instance.author,
  'url': instance.articleUrl,
  'publishedAt': instance.publishedAt,
  'source': NewsModel._sourceToJson(instance.source),
};
