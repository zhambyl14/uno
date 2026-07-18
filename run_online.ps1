# UNO FAMILY — online-mode dev run (Supabase connected).
#
# Usage:  .\run_online.ps1                (Chrome, web)
#         .\run_online.ps1 -Device <id>   (any `flutter devices` id)
#
# Firebase push is OFF until you fill the FIREBASE_* values below (see
# README.md "Firebase push (қосымша)"). The app runs fine without it —
# just uncomment the lines once you have real Firebase config values.

param(
    [string]$Device = "chrome"
)

$defines = @(
    "--dart-define=SUPABASE_URL=https://qkrwrbeostnosimuqiii.supabase.co"
    "--dart-define=SUPABASE_ANON_KEY=sb_publishable_YIYmHuzo1jjmJ1T0vC2PXw_Ppu-lULq"

    # "--dart-define=FIREBASE_API_KEY=..."
    # "--dart-define=FIREBASE_APP_ID=..."
    # "--dart-define=FIREBASE_SENDER_ID=..."
    # "--dart-define=FIREBASE_PROJECT_ID=..."
    # "--dart-define=FIREBASE_VAPID_KEY=..."
)

flutter run -d $Device @defines
