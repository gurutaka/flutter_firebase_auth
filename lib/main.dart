import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

enum EnumAuth {
  google,
  twitter,
  facebook,
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'auth sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthPage(
        title: 'Auth Sample with Firebase',
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  AuthPage({
    Key key,
    this.title,
  }) : super(
          key: key,
        );

  final String title;

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final TwitterLogin twitterLogin = TwitterLogin(
    consumerKey: "consumer-key",
    consumerSecret: "consumer-secret",
  );
  final FacebookLogin facebookSignIn = new FacebookLogin();

  bool logined = false;
  EnumAuth enumAuth;

  void login() {
    setState(() {
      logined = true;
    });
  }

  void logout() {
    setState(() {
      logined = false;
    });
  }

  void setEnumAuth(EnumAuth sns) {
    setState(() {
      enumAuth = sns;
    });
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    //userのid取得
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    login();
    setEnumAuth(EnumAuth.google);
  }

  Future signInWithTwitter() async {
    // twitter認証の許可画面が出現
    final TwitterLoginResult result = await twitterLogin.authorize();

    //Firebaseのユーザー情報にアクセス & 情報の登録 & 取得
    final AuthCredential credential = TwitterAuthProvider.getCredential(
      authToken: result.session.token,
      authTokenSecret: result.session.secret,
    );

    //Firebaseのuser id取得
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    login();
    setEnumAuth(EnumAuth.twitter);
  }

  Future signInWithFacebook() async {
    final facebookLogin = FacebookLogin();
    // final facebookLoginResult =
    //     await facebookLogin.loginWithPublishPermissions((['email']));
    final facebookLoginResult = await facebookLogin.logIn((['email']));

    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: facebookLoginResult.accessToken.token,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    login();
    setEnumAuth(EnumAuth.facebook);
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out Google");
  }

  void signOutTwitter() async {
    await twitterLogin.logOut();
    print("User Sign Out Twittter");
  }

  void signOutFacebook() async {
    await facebookSignIn.logOut();
    print("User Sign Out Twittter");
  }

  void signOut(EnumAuth sns) async {
    switch (sns) {
      case EnumAuth.google:
        signOutGoogle();
        break;
      case EnumAuth.twitter:
        signOutTwitter();
        break;
      case EnumAuth.facebook:
        signOutFacebook();
        break;
    }

    logout();
  }

  @override
  Widget build(BuildContext context) {
    Widget logoutText = Text("Logout");
    Widget loginText = Text("Login");

    Widget loginBtnGoogle = RaisedButton(
      child: Text("Sign in with Google"),
      color: Color(0xFFDD4B39),
      textColor: Colors.white,
      onPressed: signInWithGoogle,
    );

    Widget loginBtnTwitter = RaisedButton(
      child: Text("Sign in with Twitter"),
      color: Color(0xFF1DA1F2),
      textColor: Colors.white,
      onPressed: signInWithTwitter,
    );

    Widget loginBtnFb = RaisedButton(
      child: Text("Sign in with Facebook"),
      color: Color(0xFF3B5998),
      textColor: Colors.white,
      onPressed: signInWithFacebook,
    );

    Widget logoutBtn = RaisedButton(
      child: Text("Sign out"),
      color: Colors.black38,
      textColor: Colors.white,
      onPressed: () => signOut(enumAuth),
    );
    Widget loginBtns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        loginBtnGoogle,
        loginBtnFb,
        loginBtnTwitter,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            logined ? loginText : logoutText,
            logined ? logoutBtn : loginBtns,
          ],
        ),
      ),
    );
  }
}
