class Auth{
    final String id;
    final String email;
    final String? name;
    final String? role;
    final bool? loggedIn;

    Auth({
        required this.id,
        required this.email,
        this.name, 
        this.role,
        this.loggedIn,
    });

}