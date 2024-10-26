class UserProfile {
  final String? uid;
  final String? name;
  final String? pfpURL;

  UserProfile({this.uid, this.name, this.pfpURL});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      pfpURL: json['pfpURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'pfpURL': pfpURL,
    };
  }
}
