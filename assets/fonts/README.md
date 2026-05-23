# Fonts

This folder should contain the Nunito font files referenced in pubspec.yaml.

## Download Instructions

Download Nunito from Google Fonts:
https://fonts.google.com/specimen/Nunito

Extract and place these files here:
- Nunito-Regular.ttf
- Nunito-Bold.ttf
- Nunito-ExtraBold.ttf

## Quick Download (terminal)

```bash
# Using curl
curl -L "https://fonts.gstatic.com/s/nunito/v25/XRXI3I6Li01BKofiOc5wtlZ2di8HDLshdTk3j6zbXWjgeg.woff2" -o Nunito-Regular.ttf
```

## Alternative: Use google_fonts package

Instead of local fonts, you can use the `google_fonts` package and skip
placing fonts here. Add to pubspec.yaml:

```yaml
dependencies:
  google_fonts: ^6.1.0
```

Then in app_theme.dart replace `fontFamily: 'Nunito'` with:
```dart
import 'package:google_fonts/google_fonts.dart';

// In ThemeData:
textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
```

And remove the fonts section from pubspec.yaml entirely.
