@echo off
echo [1/4] Compilazione Flutter Web in corso...
call flutter clean
call flutter build web --release

echo [2/4] Invio modifiche su GitHub (aggiorna Render)...
git add .
for /f %%i in ('git rev-list --count HEAD') do set COMMIT_NUM=%%i
git commit -m "Aggiornamento automatico n. %COMMIT_NUM%"
git push origin main

echo [3/4] Caricamento su Vercel...
call vercel --prod

echo [4/4] Fatto! Tutto aggiornato con successo.
pause