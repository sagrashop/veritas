import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? savedEmail = prefs.getString('userEmail');
  runApp(VeritasApp(initialEmail: savedEmail));
}

class VeritasApp extends StatelessWidget {
  final String? initialEmail;

  const VeritasApp({super.key, this.initialEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veritasocial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B101D),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFD4AF37),
          surface: Color(0xFF131B2E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: initialEmail != null
          ? FeedScreen(
              userEmail: initialEmail!,
              userNickname: initialEmail!.split('@')[0],
            )
          : const LoginScreen(),
    );
  }
}

// ================= SCHERMATA DI LOGIN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String baseUrl = "https://veritas-3t1r.onrender.com/api";
  bool isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci email e password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail',
            _emailController.text.trim()); // Salva l'email corretta
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedScreen(
              userEmail: email,
              userNickname: data['nickname'] ?? email.split('@')[0],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email o password non valide")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore di connessione al server")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text("Trasparenza e Cookie",
            style: TextStyle(color: Color(0xFFD4AF37))),
        content: const SingleChildScrollView(
          child: Text(
            "In conformità con le normative vigenti, Veritasocial tutela i tuoi dati personali. "
            "I dati inseriti vengono utilizzati esclusivamente per il corretto funzionamento del social network. "
            "Utilizziamo cookie tecnici essenziali per mantenere la sessione attiva e garantire la connessione sicura con i nostri server.\n\n"
            "Per qualsiasi richiesta sulla gestione dei dati, puoi contattare l'amministratore.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Chiudi",
                style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome_banner.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    "Veritasocial",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 1.2),
                  ),
                  const Text("Il Social Network Reale",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          const Icon(Icons.email, color: Color(0xFFD4AF37)),
                      filled: true,
                      fillColor: const Color(0xFF131B2E),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xFFD4AF37)),
                      filled: true,
                      fillColor: const Color(0xFF131B2E),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Accedi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Non hai un account? Registrati",
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: _showPrivacyPolicy,
                    child: const Text(
                      "Politiche di trasparenza dati personali e gestione cookie",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SCHERMATA DI REGISTRAZIONE =================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final String baseUrl = "https://veritas-3t1r.onrender.com/api";
  bool isLoading = false;

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compila tutti i campi")),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le password non coincidono")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registrazione completata! Ora puoi accedere.")),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(data['error'] ?? "Errore durante la registrazione")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore di connessione al server")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101D),
        title: const Text('Registrazione',
            style: TextStyle(color: Color(0xFFD4AF37))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Unisciti a Veritasocial",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                prefixIcon: const Icon(Icons.person, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF131B2E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF131B2E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF131B2E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Conferma Password',
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF131B2E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Registrati',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SCHERMATA PRINCIPALE (FEED) =================
class FeedScreen extends StatefulWidget {
  final String userEmail;
  final String userNickname;

  const FeedScreen({
    super.key,
    required this.userEmail,
    required this.userNickname,
  });

  @override
  State createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final String baseUrl = "https://veritas-3t1r.onrender.com/api";
  List posts = [];
  bool isLoading = true;
  String? profileImage;
  String? coverImage;
  List userPhotos = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _caricaDatiUtenteDaServer();
  }

  Future _fetchPosts() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/posts"),
          )
          .timeout(const Duration(
              seconds: 40)); // <--- Dà il tempo a Render di accendersi

      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Errore caricamento post (probabile risveglio server): $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.startsWith('data:image')) {
      final base64String = imageData.split(',').last;
      try {
        final decodedBytes = base64Decode(base64String);
        return Image.memory(decodedBytes, fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image);
      }
    } else {
      return Image.network(imageData, fit: BoxFit.cover);
    }
  }

  // E incolla questa funzione subito sotto a _fetchPosts()
  // Funzione per caricare i dati del profilo da MongoDB all'avvio
  Future _caricaDatiUtenteDaServer() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile?email=${widget.userEmail}"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profileImage =
              (data['profileImage'] != null && data['profileImage'] != "")
                  ? data['profileImage']
                  : profileImage;
          coverImage = (data['coverImage'] != null && data['coverImage'] != "")
              ? data['coverImage']
              : coverImage;
          userPhotos = List.from(data['userPhotos'] ?? []);
        });
      }
    } catch (e) {
      print("Errore caricamento profilo: $e");
    }
  }

  Future _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _openCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: CreatePostSheet(
          userEmail:
              widget.userEmail, // Usa direttamente widget. del FeedScreenState
          userNickname: widget
              .userNickname, // Usa direttamente widget. del FeedScreenState
          onPostCreated: _fetchPosts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0B101D),
          elevation: 1,
          title: Row(
            children: [
              Image.asset('assets/images/logo.png', width: 32, height: 32),
              const SizedBox(width: 10),
              const Text('Veritasocial',
                  style: TextStyle(
                      color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Color(0xFFD4AF37)),
              tooltip: 'Il mio Profilo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                      userEmail: widget.userEmail,
                      userNickname: widget.userNickname,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
              tooltip: 'Esci',
              onPressed: _logout,
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
            : RefreshIndicator(
                onRefresh: () async {
                  await _fetchPosts(); // Ricarica i post quando trascini verso il basso
                },
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // FONDAMENTALE per far partire il refresh
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color:
                                const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFFFD4AF37),
                            backgroundImage: (profileImage != null &&
                                    profileImage!.isNotEmpty)
                                ? (profileImage!.startsWith('http')
                                    ? NetworkImage(profileImage!)
                                        as ImageProvider
                                    : profileImage!.startsWith('data:image')
                                        ? MemoryImage(base64Decode(
                                                profileImage!.split(',').last))
                                            as ImageProvider
                                        : FileImage(File(profileImage!))
                                            as ImageProvider)
                                : null,
                            child:
                                (profileImage == null || profileImage!.isEmpty)
                                    ? const Icon(Icons.person,
                                        color: Colors.black, size: 20)
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _openCreatePostModal,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B101D),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Text(
                                  "A cosa stai pensando?",
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, thickness: 1),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFD4AF37)
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFD4AF37),
                                    child: (profileImage != null &&
                                            profileImage!.isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            child: SizedBox.expand(
                                              child: _buildImageWidget(
                                                  profileImage!),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    post['authorNickname'] ?? 'Utente',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post['content'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ================= PROFILO UTENTE (STILE FACEBOOK) =================
class UserProfileScreen extends StatefulWidget {
  final String userEmail;
  final String userNickname;

  const UserProfileScreen({
    super.key,
    required this.userEmail,
    required this.userNickname,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String baseUrl = "https://veritas-3t1r.onrender.com/api";

  String bio = "La strada è la migliore scuola della vita";
  String citta = "Catania";
  String lavoro = "Imprenditore";
  String tabSelezionata = "Foto";
  late String nickname;

  String? profileImage;
  String? coverImage;

  final List userPhotos = [];
  final List<Map<String, dynamic>> bachecaAttivita = [];

  final ImagePicker _picker = ImagePicker();
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    nickname = widget.userNickname;
    _fetchUserProfile();
  }

  // 1. Scarica tutti i dati da MongoDB all'apertura del profilo
  Future _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile?email=${widget.userEmail}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profileImage =
              (data['profileImage'] != null && data['profileImage'] != "")
                  ? data['profileImage']
                  : null;
          coverImage = (data['coverImage'] != null && data['coverImage'] != "")
              ? data['coverImage']
              : null;
          bio = data['bio'] ?? bio;
          citta = data['citta'] ?? citta;
          lavoro = data['lavoro'] ?? lavoro;
          nickname = data['nickname'] ?? widget.userNickname;

          if (data['userPhotos'] != null) {
            userPhotos.clear();
            userPhotos.addAll(List.from(data['userPhotos']));
          }
          if (data['bachecaAttivita'] != null) {
            bachecaAttivita.clear();
            bachecaAttivita.addAll(
              List<Map<String, dynamic>>.from(data['bachecaAttivita']),
            );
          }
          isLoadingProfile = false;
        });
      } else {
        setState(() => isLoadingProfile = false);
      }
    } catch (e) {
      setState(() => isLoadingProfile = false);
    }
  }

  // 2. Invia e salva TUTTO su MongoDB
  Future _salvaTuttoSuMongo() async {
    try {
      await http.put(
        Uri.parse("$baseUrl/user/profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.userEmail,
          "nickname": nickname,
          "profileImage": profileImage ?? "",
          "coverImage": coverImage ?? "",
          "bio": bio,
          "citta": citta,
          "lavoro": lavoro,
          "userPhotos": userPhotos,
          "bachecaAttivita": bachecaAttivita,
        }),
      );
    } catch (e) {
      print("Errore di sincronizzazione con Mongo: $e");
    }
  }

  void _modificaDatiProfilo() {
    final TextEditingController bioController =
        TextEditingController(text: bio);
    final TextEditingController cittaController =
        TextEditingController(text: citta);
    final TextEditingController lavoroController =
        TextEditingController(text: lavoro);
    final TextEditingController nicknameController =
        TextEditingController(text: nickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text("Modifica Profilo",
            style: TextStyle(color: Color(0xFFD4AF37))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                    labelText: 'Biografia / Presentazione'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cittaController,
                decoration: const InputDecoration(labelText: 'Città'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lavoroController,
                decoration: const InputDecoration(labelText: 'Lavoro'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                bio = bioController.text;
                citta = cittaController.text;
                lavoro = lavoroController.text;
                nickname = nicknameController.text;
                bachecaAttivita.insert(0, {
                  "tipo": "aggiornamento",
                  "testo": "Ha aggiornato le informazioni del profilo.",
                  "data": "Oggi"
                });
              });

              await _salvaTuttoSuMongo();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Profilo aggiornato e salvato su MongoDB!")),
              );
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }

  Future _cambiaFotoProfilo() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

        setState(() {
          profileImage = base64Image;
          userPhotos.add(base64Image);
          bachecaAttivita.insert(0, {
            "tipo": "foto",
            "testo": "Ha aggiornato la foto del profilo.",
            "media": base64Image,
            "data": "Oggi"
          });
        });

        await _salvaTuttoSuMongo();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Foto profilo aggiornata e salvata su MongoDB!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Errore durante il caricamento della foto")),
      );
    }
  }

  Future _cambiaCopertina() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

        setState(() {
          coverImage = base64Image;
          userPhotos.add(base64Image);
          bachecaAttivita.insert(0, {
            "tipo": "copertina",
            "testo": "Ha aggiornato l'immagine di copertina.",
            "media": base64Image,
            "data": "Oggi"
          });
        });

        await _salvaTuttoSuMongo();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Copertina aggiornata e salvata su MongoDB!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Errore durante il caricamento della copertina")),
      );
    }
  }

  Future _aggiungiStoriaOFile(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

        setState(() {
          userPhotos.add(base64Image);
          bachecaAttivita.insert(0, {
            "tipo": "storia",
            "testo": "Ha pubblicato una nuova storia / foto.",
            "media": base64Image,
            "data": "Oggi"
          });
        });

        await _salvaTuttoSuMongo();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Contenuto aggiunto e salvato su MongoDB!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante il caricamento del file")),
      );
    }
  }

  void _mostraSceltaMultimedia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Aggiungi alla storia / Profilo",
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFD4AF37)),
              title: const Text("Scegli dalla Galleria",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _aggiungiStoriaOFile(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFD4AF37)),
              title: const Text("Scatta con la Fotocamera",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _aggiungiStoriaOFile(ImageSource.camera);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? path, {BoxFit fit = BoxFit.cover}) {
    if (path == null || path.isEmpty) {
      return Container(
        color: const Color(0xFF131B2E),
        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
      );
    }
    if (path.startsWith("data:image")) {
      try {
        final base64Str = path.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF131B2E),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
        );
      } catch (e) {
        return Container(
          color: const Color(0xFF131B2E),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        );
      }
    }
    if (kIsWeb || path.startsWith("http")) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF131B2E),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF131B2E),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B101D),
          title:
              Text(nickname, style: const TextStyle(color: Color(0xFFD4AF37))),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101D),
        title: Text(
          nickname, // <--- Aggiungi questa riga qui!
          style: const TextStyle(color: Color(0xFFFD4AF37)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          tooltip: 'Torna al Feed',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoadingProfile = true;
          });
          // Inserisci qui la funzione che scarica i dati dal server per il profilo
          // es: await fetchUserProfile();
          setState(() {
            isLoadingProfile = false;
          });
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Fondamentale per far partire il trascinamento
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: coverImage != null && coverImage!.isNotEmpty
                      ? _buildImageWidget(coverImage)
                      : Image.asset(
                          'assets/images/welcome_banner.jpeg',
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt,
                          size: 18, color: Color(0xFFD4AF37)),
                      tooltip: 'Cambia copertina',
                      onPressed: _cambiaCopertina,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _cambiaFotoProfilo,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFFD4AF37),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: const Color(0xFF131B2E),
                            child: profileImage != null &&
                                    profileImage!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(52),
                                    child: SizedBox.expand(
                                      child: _buildImageWidget(profileImage),
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 60, color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _cambiaFotoProfilo,
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFD4AF37),
                            child: Icon(Icons.camera_alt,
                                size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Center(
              child: Text(
                nickname,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work,
                          size: 16, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 6),
                      Text(lavoro,
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on,
                          size: 16, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 6),
                      Text(citta,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF131B2E),
                          side: const BorderSide(color: Color(0xFFD4AF37))),
                      onPressed: _modificaDatiProfilo,
                      icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                      label: const Text("Modifica profilo",
                          style: TextStyle(color: Color(0xFFD4AF37))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF131B2E),
                          side: const BorderSide(color: Color(0xFFD4AF37))),
                      onPressed: _mostraSceltaMultimedia,
                      icon: const Icon(Icons.add_circle,
                          color: Color(0xFFD4AF37)),
                      label: const Text("Aggiungi storia",
                          style: TextStyle(color: Color(0xFFD4AF37))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dettagli personali",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37))),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Color(0xFFD4AF37)),
                        onPressed: _modificaDatiProfilo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_city,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text("Vive a $citta",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.work_outline,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text("Lavora come $lavoro",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton("Foto"),
                _buildTabButton("Bacheca"),
              ],
            ),
            const Divider(color: Colors.white24),
            tabSelezionata == "Foto"
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: userPhotos.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                  "Nessuna foto caricata. Usa 'Aggiungi storia' per caricarne una!",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: userPhotos.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImageWidget(userPhotos[index]),
                              );
                            },
                          ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: bachecaAttivita.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                  "La bacheca è vuota. Qui apparirà la cronologia di tutto ciò che fai!",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bachecaAttivita.length,
                            itemBuilder: (context, index) {
                              final item = bachecaAttivita[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131B2E),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Color(0xFFD4AF37),
                                          child: Icon(Icons.person,
                                              size: 16, color: Colors.black),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.userNickname,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        const Spacer(),
                                        Text(
                                          item['data'] ?? 'Oggi',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['testo'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                    if (item['media'] != null &&
                                        item['media'] != "") ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          height: 180,
                                          width: double.infinity,
                                          child:
                                              _buildImageWidget(item['media']),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String titolo) {
    bool isSelected = tabSelezionata == titolo;
    return TextButton(
      onPressed: () => setState(() => tabSelezionata = titolo),
      child: Text(
        titolo,
        style: TextStyle(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ================= WIDGET CREAZIONE POST DAL BASSO =================
class CreatePostSheet extends StatefulWidget {
  final String userEmail;
  final String userNickname;
  final VoidCallback onPostCreated;

  const CreatePostSheet({
    super.key,
    required this.userEmail,
    required this.userNickname,
    required this.onPostCreated,
  });

  @override
  State createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _postController = TextEditingController();
  final String baseUrl = "https://veritas-3t1r.onrender.com/api";
  bool isPosting = false;

  Future _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    setState(() => isPosting = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/posts"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "authorEmail": widget.userEmail,
          "authorNickname": widget.userNickname,
          "authorImage": "assets/images/logo.png",
          "content": content,
          "media": "",
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onPostCreated();
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      widget.onPostCreated();
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crea Post',
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: isPosting ? null : _createPost,
                child: isPosting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Color(0xFFD4AF37), strokeWidth: 2))
                    : const Text('Pubblica',
                        style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            ),
            child: TextField(
              controller: _postController,
              maxLines: null,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'A cosa stai pensando?',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
