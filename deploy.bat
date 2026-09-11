@echo off
echo [1/4] Compilazione Flutter Web in corso...
call flutter clean
call flutter build web --release

echo [2/4] Invio modifiche su GitHub (aggiorna Render)...
git add .
git commit -m "Aggiornamento automatico completo"
git push origin main

echo [3/4] Caricamento su Vercel...
call vercel --prod

echo [4/4] Fatto! Tutto aggiornato con successo.
pause