@echo off
setlocal enabledelayedexpansion

:: 1. Legge il numero attuale dal file version.txt (se non esiste parte da 100)
if not exist version.txt (
    echo 100 > version.txt
)
set /p V= version.txt

set "COMMIT_MSG=Releaseapp%NEXT_V%"

echo [1/4] Compilazione Flutter Web in corso...
call flutter clean
call flutter build web --release

echo [2/4] Invio modifiche su GitHub (aggiorna Render) con messaggio: !COMMIT_MSG!...
git add .
git commit -m "!COMMIT_MSG!"
git push origin main

echo [3/4] Caricamento su Vercel...
call vercel --prod

echo [4/4] Fatto! Aggiornato con successo come !COMMIT_MSG!.
pause