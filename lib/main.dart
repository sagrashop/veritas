import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const VeritasApp());
}

class VeritasApp extends StatelessWidget {
  const VeritasApp({super.key});

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
      home: const LoginScreen(),
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

    if (email.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FeedScreen(
            userEmail: email,
            userNickname: email.split('@')[0],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FeedScreen(
            userEmail: email,
            userNickname: email.split('@')[0],
          ),
        ),
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

    if (email.isEmpty || password.isEmpty || name.isEmpty) return;
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le password non coincidono")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "name": name}),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FeedScreen(
            userEmail: email,
            userNickname: name,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FeedScreen(
            userEmail: email,
            userNickname: name,
          ),
        ),
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

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future _fetchPosts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/posts"));
      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _logout() {
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: CreatePostSheet(
          userEmail: widget.userEmail,
          userNickname: widget.userNickname,
          onPostCreated: _fetchPosts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          : ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFD4AF37),
                        child:
                            Icon(Icons.person, color: Colors.black, size: 20),
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
                            color:
                                const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFD4AF37),
                                child: Icon(Icons.person,
                                    color: Colors.black, size: 20),
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
  State createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String bio = "La strada è la migliore scuola della vita";
  String citta = "Catania";
  String lavoro = "Imprenditore";
  String tabSelezionata = "Foto";

  String? profileImagePath;
  String? coverImagePath;

  final List<String> userPhotos = [];
  final List<Map<String, dynamic>> bachecaAttivita = [];

  final ImagePicker _picker = ImagePicker();

  void _modificaDatiProfilo() {
    final TextEditingController bioController =
        TextEditingController(text: bio);
    final TextEditingController cittaController =
        TextEditingController(text: citta);
    final TextEditingController lavoroController =
        TextEditingController(text: lavoro);

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
            onPressed: () {
              setState(() {
                bio = bioController.text;
                citta = cittaController.text;
                lavoro = lavoroController.text;
                bachecaAttivita.insert(0, {
                  "tipo": "aggiornamento",
                  "testo": "Ha aggiornato le informazioni del profilo.",
                  "data": "Oggi"
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Profilo aggiornato con successo!")),
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
        final path = image.path;
        setState(() {
          profileImagePath = path;
          userPhotos.add(path);
          bachecaAttivita.insert(0, {
            "tipo": "foto",
            "testo": "Ha aggiornato la foto del profilo.",
            "media": path,
            "data": "Oggi"
          });
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Foto profilo aggiornata con successo!")),
        );
      }
    } catch (e) {
      // Gestione sicura in caso di errore
    }
  }

  Future _cambiaCopertina() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final path = image.path;
        setState(() {
          coverImagePath = path;
          bachecaAttivita.insert(0, {
            "tipo": "copertina",
            "testo": "Ha aggiornato l'immagine di copertina.",
            "media": path,
            "data": "Oggi"
          });
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Immagine di copertina aggiornata con successo!")),
        );
      }
    } catch (e) {
      // Gestione sicura in caso di errore
    }
  }

  Future _aggiungiStoriaOFile(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final path = image.path;
        setState(() {
          userPhotos.add(path);
          bachecaAttivita.insert(0, {
            "tipo": "storia",
            "testo": "Ha pubblicato una nuova storia / foto.",
            "media": path,
            "data": "Oggi"
          });
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Contenuto aggiunto con successo alla bacheca e alle foto!")),
        );
      }
    } catch (e) {
      // Gestione sicura in caso di errore
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
    if (path == null) {
      return Container(
        color: const Color(0xFF131B2E),
        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
      );
    }
    if (kIsWeb) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          tooltip: 'Torna al Feed',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userNickname,
          style: const TextStyle(
              color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: coverImagePath != null
                      ? DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(coverImagePath!) as ImageProvider
                              : FileImage(File(coverImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image:
                              AssetImage('assets/images/welcome_banner.jpeg'),
                          fit: BoxFit.cover,
                        ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          backgroundImage: profileImagePath != null
                              ? (kIsWeb
                                  ? NetworkImage(profileImagePath!)
                                      as ImageProvider
                                  : FileImage(File(profileImagePath!)))
                              : null,
                          child: profileImagePath == null
                              ? const Icon(Icons.person,
                                  size: 60, color: Color(0xFFD4AF37))
                              : null,
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
              widget.userNickname,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              "2474 Follower · 958 seguiti · 4146 post",
              style: TextStyle(color: Colors.grey, fontSize: 13),
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
                    const Icon(Icons.work, size: 16, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 6),
                    Text(lavoro, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on,
                        size: 16, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 6),
                    Text(citta, style: const TextStyle(color: Colors.white70)),
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
                    icon:
                        const Icon(Icons.add_circle, color: Color(0xFFD4AF37)),
                    label: const Text("Aggiungi storia",
                        style: TextStyle(color: Color(0xFFD4AF37))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Dettagli personali posizionati subito sotto i pulsanti
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
                                  if (item['media'] != null) ...[
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        height: 180,
                                        width: double.infinity,
                                        child: _buildImageWidget(item['media']),
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
