/// Modèle Utilisateur
class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? role;
  final bool actif;
  final DateTime? dateCreation;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.role,
    this.actif = true,
    this.dateCreation,
  });

  String get nomComplet => '$prenom $nom';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'],
      actif: json['actif'] ?? true,
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'actif': actif,
    };
  }

  User copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? role,
    bool? actif,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      actif: actif ?? this.actif,
      dateCreation: dateCreation,
    );
  }
}

/// Réponse d'authentification
class AuthResponse {
  final String token;
  final String type;
  final User user;

  AuthResponse({
    required this.token,
    this.type = 'Bearer',
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // L'API retourne 'accessToken', on le mappe vers 'token'
    return AuthResponse(
      token: json['accessToken'] ?? json['token'] ?? '',
      type: json['tokenType'] ?? json['type'] ?? 'Bearer',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
