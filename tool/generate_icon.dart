// One-off generator for the app icon (no image editor available in this
// environment). Draws a brand-colored gradient badge with two fanned,
// tilted cards and a star mark — run with `dart run tool/generate_icon.dart`
// then `dart run flutter_launcher_icons` to produce all platform assets.
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _purple = 0xFF6C4DF6;
const _blue = 0xFF2D2A6E;
const _red = 0xFFE84C3D;
const _yellow = 0xFFF7C948;
const _white = 0xFFFFFFFF;

img.Color _c(int argb) => img.ColorRgba8(
  (argb >> 16) & 0xFF,
  (argb >> 8) & 0xFF,
  argb & 0xFF,
  (argb >> 24) & 0xFF,
);

List<img.Point> _rotatedRect(
  double cx,
  double cy,
  double halfW,
  double halfH,
  double angle,
) {
  final cos = math.cos(angle);
  final sin = math.sin(angle);
  final corners = [
    (-halfW, -halfH),
    (halfW, -halfH),
    (halfW, halfH),
    (-halfW, halfH),
  ];
  return [
    for (final (x, y) in corners)
      img.Point(cx + x * cos - y * sin, cy + x * sin + y * cos),
  ];
}

List<img.Point> _star(double cx, double cy, double outerR, double innerR) {
  final points = <img.Point>[];
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outerR : innerR;
    final angle = (math.pi / 5) * i - math.pi / 2;
    points.add(img.Point(cx + r * math.cos(angle), cy + r * math.sin(angle)));
  }
  return points;
}

img.Image _paintIcon({required bool withBackground}) {
  const size = 1024;
  final image = img.Image(width: size, height: size, numChannels: 4);

  if (withBackground) {
    for (var y = 0; y < size; y++) {
      final t = y / size;
      final r = _lerp((_purple >> 16) & 0xFF, (_blue >> 16) & 0xFF, t);
      final g = _lerp((_purple >> 8) & 0xFF, (_blue >> 8) & 0xFF, t);
      final b = _lerp(_purple & 0xFF, _blue & 0xFF, t);
      img.fillRect(
        image,
        x1: 0,
        y1: y,
        x2: size,
        y2: y + 1,
        color: img.ColorRgba8(r, g, b, 255),
      );
    }
  }

  const cx = size / 2;
  const cy = size / 2;

  // Back card (yellow, tilted left).
  img.fillPolygon(
    image,
    vertices: _rotatedRect(cx - 40, cy + 30, 220, 300, -0.30),
    color: _c(_yellow),
  );
  // Front card (red, tilted right) — drawn on top.
  img.fillPolygon(
    image,
    vertices: _rotatedRect(cx + 30, cy - 10, 230, 310, 0.18),
    color: _c(_red),
  );
  // Star mark, centered on the front card.
  img.fillPolygon(
    image,
    vertices: _star(cx + 30, cy - 10, 130, 52),
    color: _c(_white),
  );

  return image;
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

Future<void> main() async {
  Directory('assets/icon').createSync(recursive: true);
  await img.encodePngFile(
    'assets/icon/icon.png',
    _paintIcon(withBackground: true),
  );
  // Foreground-only (transparent bg) for Android adaptive icons.
  await img.encodePngFile(
    'assets/icon/icon_foreground.png',
    _paintIcon(withBackground: false),
  );
  // ignore: avoid_print
  print('Wrote assets/icon/icon.png and icon_foreground.png');
}
