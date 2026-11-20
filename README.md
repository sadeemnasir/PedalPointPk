# PedalPoint Flutter

Flutter Web conversion of the supplied **PedalPoint - Premium Cycle Rental Pakistan** HTML page.

## Included

- Responsive Flutter Web layout
- PedalPoint navigation/header
- Hero section with city/type/date search
- Cycle fleet cards and category/city filters
- Booking bottom sheet
- Rental duration calculation
- Helmet, GPS, pannier bag and repair-kit add-ons
- Doorstep delivery fee
- Rider details form
- Booking confirmation receipt
- Saved rentals using `shared_preferences`
- My Rentals dialog
- How It Works section
- Why Choose Us section
- Rider reviews
- Footer
- Floating quick-rent button
- Material 3 styling
- Network cycle images from the URLs used by the supplied HTML

## Run in VS Code

1. Extract the ZIP.
2. Open the extracted `pedalpoint_flutter` folder in VS Code.
3. Make sure Flutter and Chrome are installed.
4. Run:

```bash
flutter pub get
flutter run -d chrome
```

For a release web build:

```bash
flutter build web
```

The generated website will be in `build/web`.

## Notes

The original HTML uses Tailwind CSS, Font Awesome, Google Fonts, browser localStorage and JavaScript. This version maps those features to Flutter widgets, Material icons, Google Fonts and `shared_preferences`.

The app does not include a backend or real payment gateway. "Confirm & Pay" creates a local booking/receipt only.

### Receipt PDF
The booking confirmation receipt now has:
- Print button
- Download PDF button
- A4 PDF receipt with booking and rider details
- PDF filename based on the booking reference

Run:
```bash
flutter pub get
flutter run -d chrome
```
