import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_model.dart';
import '../models/auth_model.dart';
import 'package:soen343/components/auth_service.dart';

class SignUpController {
    final AuthService _authService;

    SignUpController(this._authService);

    Future<Auth> signUp(String email, String password, String name, String role ) async {
        try {
            await _authService.signUp(
                email: email,
                password:password,
                name:name,
                role:role,
            );

            final user = await _authService.loginUserWithEmailAndPassword(email,password);
            if (user!= null){
                return Auth(
                    id: user.uid,
                    email: user.email ??'',
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