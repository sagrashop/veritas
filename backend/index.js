const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const fs = require('fs');

// Crea la cartella 'uploads' se non esiste
if (!fs.existsSync('uploads')) {
    fs.mkdirSync('uploads');
}

const app = express();

// ATTIVA CORS
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.options('*', cors()); // Abilita le richieste preflight per tutte le rotte

// Middleware configurati per gestire dati ampi
app.use(express.json({ limit: '100mb' }));
app.use(express.urlencoded({ limit: '100mb', extended: true }));

// Rende la cartella "uploads" accessibile pubblicamente via URL
// Rende la cartella "uploads" accessibile pubblicamente forzando l'header CORS direttamente nel file server
app.use('/uploads', express.static(path.join(__dirname, 'uploads'), {
    setHeaders: (res, path, stat) => {
        res.set('Access-Control-Allow-Origin', '*');
    }
}));
// Configurazione corretta di Multer (mantiene l'estensione originale del file)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// UNICA ROTTA UFFICIALE per l'upload delle immagini
app.post('/api/upload-image', upload.single('image'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'Nessun file caricato' });
        }
        // Restituisce la chiave esatta che si aspetta Flutter (imageUrl)
        const imageUrl = `/uploads/${req.file.filename}`;
        res.status(200).json({ imageUrl });
    } catch (error) {
        console.error("Errore upload immagine:", error);
        res.status(500).json({ error: error.message });
    }
});

// Connessione a MongoDB Atlas
const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://sagrashopcatania_db_user:852123max@veritas.hswxfes.mongodb.net/?appName=Veritas"

mongoose.connect(MONGO_URI)
  .then(() => console.log("Connesso a MongoDB con successo!"))
  .catch(err => console.error("Errore di connessione a MongoDB:", err));

// Schema Unificato Utente e Profilo
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  nickname: { type: String, default: "" },
  profileImage: { type: String, default: "" }, 
  coverImage: { type: String, default: "" },   
  bio: { type: String, default: "La strada è la migliore scuola della vita" },
  citta: { type: String, default: "Catania" },
  lavoro: { type: String, default: "Imprenditore" },
  userPhotos: { type: [String], default: [] }, 
  bachecaAttivita: { type: Array, default: [] } 
});

const User = mongoose.model("User", userSchema);

// Schema per i Post della Bacheca Pubblica
const postSchema = new mongoose.Schema({
  authorEmail: String,
  authorNickname: String,
  authorImage: String,
  content: String,
  media: { type: String, default: "" },
  createdAt: { type: Date, default: Date.now }
});

const Post = mongoose.model("Post", postSchema);

// 1. Registrazione
app.post("/api/register", async (req, res) => {
  try {
    const { email, password } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ error: "Email già registrata" });

    const newUser = new User({ email, password, nickname: email.split("@")[0] });
    await newUser.save();
    res.status(201).json({ message: "Registrazione avvenuta con successo" });
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
  }
});

// 2. Login
app.post("/api/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email, password });
    if (!user) return res.status(401).json({ error: "Credenziali non valide" });

    res.status(200).json({ 
      message: "Login riuscito", 
      email: user.email,
      nickname: user.nickname,
      profileImage: user.profileImage 
    });
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
  }
});

// 3. Aggiornamento Profilo + Sincronizzazione Automatica con la Bacheca Pubblica
app.put("/api/user/profile", async (req, res) => {
  try {
    const { email, nickname, profileImage, coverImage, bio, citta, lavoro, userPhotos, bachecaAttivita } = req.body;
    
    let user = await User.findOne({ email });
    const oldActivities = (user && user.bachecaAttivita) ? user.bachecaAttivita : [];

    if (bachecaAttivita && bachecaAttivita.length > oldActivities.length) {
      const newActivities = bachecaAttivita.slice(oldActivities.length);
      for (const act of newActivities) {
        let content = "";
        let media = "";

        if (typeof act === 'string') {
          content = act;
        } else if (typeof act === 'object' && act !== null) {
          content = act.content || act.testo || "Aggiornamento profilo";
          media = act.media || act.image || act.imageUrl || "";
        }

        const newPost = new Post({
          authorEmail: email,
          authorNickname: nickname || (user ? user.nickname : email.split("@")[0]),
          authorImage: profileImage || (user ? user.profileImage : ""),
          content: content,
          media: media
        });

        await newPost.save();
      }
    }

    const updatedUser = await User.findOneAndUpdate(
      { email },
      { 
        $set: { 
          nickname: nickname !== undefined ? nickname : (user?.nickname ?? ""),
          profileImage: profileImage !== undefined ? profileImage : (user?.profileImage ?? ""),
          coverImage: coverImage !== undefined ? coverImage : (user?.coverImage ?? ""),
          bio: bio !== undefined ? bio : (user?.bio ?? "La strada è la migliore scuola della vita"),
          citta: citta !== undefined ? citta : (user?.citta ?? "Catania"),
          lavoro: lavoro !== undefined ? lavoro : (user?.lavoro ?? "Imprenditore"),
          userPhotos: userPhotos !== undefined ? userPhotos : (user?.userPhotos ?? []),
          bachecaAttivita: bachecaAttivita !== undefined ? bachecaAttivita : (user?.bachecaAttivita ?? [])
        }
      },
      { new: true, upsert: true }
    );

    res.status(200).json({ message: "Profilo aggiornato con successo", user: updatedUser });
  } catch (err) {
    console.error("Errore aggiornamento profilo:", err);
    res.status(500).json({ error: err.message });
  }
});

// 4. Lettura Profilo da MongoDB
app.get("/api/user/profile", async (req, res) => {
  try {
    const { email } = req.query;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: "Utente non trovato" });

    res.status(200).json({
      nickname: user.nickname || "",
      profileImage: user.profileImage || "",
      coverImage: user.coverImage || "",
      bio: user.bio || "La strada è la migliore scuola della vita",
      citta: user.citta || "Catania",
      lavoro: user.lavoro || "Imprenditore",
      userPhotos: user.userPhotos || [],
      bachecaAttivita: user.bachecaAttivita || []
    });
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
  }
});

// 5. Creazione Post (Bacheca)
app.post("/api/posts", async (postReq, postRes) => {
  try {
    const { authorEmail, authorNickname, authorImage, content, media } = postReq.body;
    const newPost = new Post({ authorEmail, authorNickname, authorImage, content, media });
    await newPost.save();
    postRes.status(201).json(newPost);
  } catch (err) {
    postRes.status(500).json({ error: "Errore del server" });
  }
});

// 6. Lettura Post (Bacheca)
app.get("/api/posts", async (req, res) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 }).limit(50);
    res.status(200).json(posts);
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server avviato sulla porta ${PORT}`));