import 'dart:convert';

UserResModel userResModelFromJson(String str) =>
    UserResModel.fromJson(json.decode(str));

String userResModelToJson(UserResModel data) => json.encode(data.toJson());

class UserResModel {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<UserData> data;
  final Support support;
  final Meta meta;

  UserResModel({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
    required this.support,
    required this.meta,
  });

  factory UserResModel.empty() => UserResModel(
    page: 0,
    perPage: 0,
    total: 0,
    totalPages: 0,
    data: [],
    support: Support.empty(),
    meta: Meta.empty(),
  );

  factory UserResModel.fromJson(Map<String, dynamic> json) => UserResModel(
    page: json["page"] ?? 0,
    perPage: json["per_page"] ?? 0,
    total: json["total"] ?? 0,
    totalPages: json["total_pages"] ?? 0,
    data: json["data"] == null
        ? []
        : List<UserData>.from(json["data"]!.map((x) => UserData.fromJson(x))),
    support: json["support"] == null
        ? Support.empty()
        : Support.fromJson(json["support"]),
    meta: json["_meta"] == null ? Meta.empty() : Meta.fromJson(json["_meta"]),
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "per_page": perPage,
    "total": total,
    "total_pages": totalPages,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "support": support.toJson(),
    "_meta": meta.toJson(),
  };
}

class UserData {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory UserData.empty() =>
      UserData(id: 0, email: '', firstName: '', lastName: '', avatar: '');

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"] ?? 0,
    email: json["email"] ?? '',
    firstName: json["first_name"] ?? '',
    lastName: json["last_name"] ?? '',
    avatar: json["avatar"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "avatar": avatar,
  };
}

class Meta {
  final String poweredBy;
  final String upgradeUrl;
  final String docsUrl;
  final String templateGallery;
  final String message;
  final List<String> features;
  final String upgradeCta;

  Meta({
    required this.poweredBy,
    required this.upgradeUrl,
    required this.docsUrl,
    required this.templateGallery,
    required this.message,
    required this.features,
    required this.upgradeCta,
  });

  factory Meta.empty() => Meta(
    poweredBy: '',
    upgradeUrl: '',
    docsUrl: '',
    templateGallery: '',
    message: '',
    features: [],
    upgradeCta: '',
  );

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    poweredBy: json["powered_by"] ?? '',
    upgradeUrl: json["upgrade_url"] ?? '',
    docsUrl: json["docs_url"] ?? '',
    templateGallery: json["template_gallery"] ?? '',
    message: json["message"] ?? '',
    features: json["features"] == null
        ? []
        : List<String>.from(json["features"]!.map((x) => x)),
    upgradeCta: json["upgrade_cta"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "powered_by": poweredBy,
    "upgrade_url": upgradeUrl,
    "docs_url": docsUrl,
    "template_gallery": templateGallery,
    "message": message,
    "features": List<dynamic>.from(features.map((x) => x)),
    "upgrade_cta": upgradeCta,
  };
}

class Support {
  final String url;
  final String text;

  Support({required this.url, required this.text});

  factory Support.empty() => Support(url: '', text: '');

  factory Support.fromJson(Map<String, dynamic> json) =>
      Support(url: json["url"] ?? '', text: json["text"] ?? '');

  Map<String, dynamic> toJson() => {"url": url, "text": text};
}
