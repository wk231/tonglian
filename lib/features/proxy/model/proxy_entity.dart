import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/singbox/model/singbox_proxy_type.dart';

part 'proxy_entity.freezed.dart';

@freezed
class ProxyGroupEntity with _$ProxyGroupEntity {
  const ProxyGroupEntity._();

  const factory ProxyGroupEntity({
    required String tag,
    required ProxyType type,
    required String selected,
    @Default([]) List<ProxyItemEntity> items,
  }) = _ProxyGroupEntity;

  String get name => _sanitizedTag(tag);
}

@freezed
class ProxyItemEntity with _$ProxyItemEntity {
  const ProxyItemEntity._();

  const factory ProxyItemEntity({
    required String tag,
    required ProxyType type,
    required int urlTestDelay,
    String? selectedTag,
  }) = _ProxyItemEntity;

  String get name => _sanitizedTag(tag);
  String? get selectedName =>
      selectedTag == null ? null : _sanitizedTag(selectedTag!);
  bool get isVisible => !tag.contains("§hide§");
}

String _sanitizedTag(String tag) =>
    tag.replaceFirst(RegExp(r"\§[^]*"), "").trimRight();


class ProxyEntity {
  final int id;
  final String type;
  final String? version;
  final String name;
  final String rate;
  final List<dynamic> tags;
  final String icon;
  final int isOnline;
  final String cacheKey;
  final String lastCheckAt;

  ProxyEntity({
    required this.id,
    required this.type,
    this.version,
    required this.name,
    required this.rate,
    required this.tags,
    required this.icon,
    required this.isOnline,
    required this.cacheKey,
    required this.lastCheckAt,
  });

  factory ProxyEntity.fromJson(Map<String, dynamic> json) {
    return ProxyEntity(
      id: json['id'] as int,
      type: json['type'] as String,
      version: json['version'] as String?, // 安全处理null值
      name: json['name'] as String,
      rate: json['rate'] as String,
      tags: json['tags'] as List<dynamic>,
      icon: json['icon'] as String,
      isOnline: json['is_online'] as int,
      cacheKey: json['cache_key'] as String,
      lastCheckAt: json['last_check_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'version': version,
      'name': name,
      'rate': rate,
      'tags': tags,
      'icon': icon,
      'is_online': isOnline,
      'cache_key': cacheKey,
      'last_check_at': lastCheckAt,
    };
  }
}