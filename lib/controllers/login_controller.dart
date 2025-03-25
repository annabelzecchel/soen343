import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_model.dart';
import '../models/auth_model.dart';
import 'package:soen343/components/auth_service.dart';

class LoginController {
    final AuthService _authService;

    LoginController(this._authService);

    Future<Auth> login(String email, String password) async {
        try {
            final user = await _authService.loginUserWithEmailAndPassword(email,password);
            if (user!= null){
                return Auth(
                    id: user.uid,
                    email: user.email ?? '',
                    name: user.displayName ?? '',
                    role:'',
                    loggedIn: true, 
                );
            }
            return Auth(
        id: '',
        email: email,
        name: '',
        role: '',
        loggedIn: false,
      );
        }catch (e){
            throw Exception('LOGIN FAILED');

        }

    }
}