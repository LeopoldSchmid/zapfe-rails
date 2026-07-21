# Runtime-Assets

Produktionsseiten verwenden ausschließlich die optimierten Bildvarianten in
`public/optimized`, die WebP-Produktbilder unter `app/assets/images` und die
beiden Videos mit Suffix `_720.mp4` in `public/videos`.

Die hochauflösenden JPG-/PNG-Dateien und doppelten Originalvideos bleiben als
nicht reproduzierbare Quelldateien im Repository erhalten. `.dockerignore`
schließt sie jedoch explizit aus dem Build-Kontext aus. Damit gelangen sie
weder in die Asset-Kompilierung noch in das finale Runtime-Image.

Bei neuen Medien gilt:

1. Optimierte, tatsächlich ausgelieferte Varianten explizit einchecken.
2. Views nur auf diese Varianten verweisen lassen.
3. Große Quelldateien in `.dockerignore` ergänzen.
4. Vor dem Release `SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile`
   und den Browser-Test ausführen.
