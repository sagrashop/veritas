const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

// Middleware configurati per gestire immagini e dati JSON ampi
app.use(express.json({ limit: "50mb" }));
app.use(cors());

// Connessione a MongoDB Atlas (sostituisci con la tua stringa)
const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://sagrashopcatania_db_user:852123max@veritas.hswxfes.mongodb.net/?appName=Veritas"

mongoose.connect(MONGO_URI)
  .then(() => console.log("Connesso a MongoDB con successo!"))
  .catch(err => console.error("Errore di connessione a MongoDB:", err));

// Schema Unificato Utente e Profilo
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  nickname: { type: String, default: "" },
  profileImage: { type: String, default: "" } // Immagine in Base64
});

const User = mongoose.model("User", userSchema);

// Schema per i Post della Bacheca (Stile Facebook)
const postSchema = new mongoose.Schema({
  authorEmail: String,
  authorNickname: String,
  authorImage: String,
  content: String,
  media: { type: String, default: "" }, // Eventuale foto allegata al post
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

// 3. Aggiornamento Profilo (Nickname e Foto)
app.put("/api/user/profile", async (req, res) => {
  try {
    const { email, nickname, profileImage } = req.body;
    const updatedUser = await User.findOneAndUpdate(
      { email },
      { nickname, profileImage },
      { new: true }
    );
    if (!updatedUser) return res.status(404).json({ error: "Utente non trovato" });

    res.status(200).json({ message: "Profilo aggiornato", user: updatedUser });
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
  }
});

// 4. Lettura Profilo
app.get("/api/user/profile", async (req, res) => {
  try {
    const { email } = req.query;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: "Utente non trovato" });

    res.status(200).json({
      nickname: user.nickname || "",
      profileImage: user.profileImage || ""
    });
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
  }
});

// 5. Creazione Post (Bacheca)
app.post("/api/posts", async (req, res) => {
  try {
    const { authorEmail, authorNickname, authorImage, content, media } = req.body;
    const newPost = new Post({ authorEmail, authorNickname, authorImage, content, media });
    await newPost.save();
    res.status(201).json(newPost);
  } catch (err) {
    res.status(500).json({ error: "Errore del server" });
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