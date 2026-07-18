# UNO FAMILY — online-mode web release build (Supabase connected).
# Output: build/web/  (deploy that folder as-is).
#
# Usage: .\build_web_online.ps1

$defines = @(
    "--dart-define=SUPABASE_URL=https://qkrwrbeostnosimuqiii.supabase.co"
    "--dart-define=SUPABASE_ANON_KEY=sb_publishable_YIYmHuzo1jjmJ1T0vC2PXw_Ppu-lULq"

    # "--dart-define=FIREBASE_API_KEY=..."
    # "--dart-define=FIREBASE_APP_ID=..."
    # "--dart-define=FIREBASE_SENDER_ID=..."
    # "--dart-define=FIREBASE_PROJECT_ID=..."
    # "--dart-define=FIREBASE_VAPID_KEY=..."
)

flutter build web --release @defines
