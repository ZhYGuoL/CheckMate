# CheckMate

A local-only iOS app that maps the top 200 Bay Area VCs and accelerators, with a compass that points to the nearest one from your current location.

This is not intended for App Store or TestFlight distribution — just open the project in Xcode and run it on your simulator or personal device.

## Requirements

- Xcode 16+ (Liquid Glass styling uses iOS 26 APIs when available)
- iOS 17+
- Location permission for compass and nearest-firm features

## Run locally

1. Open `CheckMate.xcodeproj` in Xcode.
2. Select an iPhone simulator or your own device.
3. Build and run (⌘R). No App Store Connect or TestFlight setup needed.
4. Allow location access when prompted on the Compass tab.

For a physical iPhone, Xcode’s default “Sign to Run Locally” is enough for personal use.

## If Xcode shows a DerivedData / “workspace arena” error

1. **Quit Xcode** completely (⌘Q).
2. Clear the stale global cache:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/CheckMate-*
```

3. Reopen `CheckMate.xcodeproj` and build again (⌘R).

This project is configured to use **workspace-relative DerivedData** (`CheckMate/DerivedData/` inside the repo), which avoids most `~/Library/Developer/Xcode/DerivedData` permission issues. If Xcode still uses the global folder, set **Xcode → Settings → Locations → Derived Data → Relative**.

## Project structure

- `CheckMate/Views/MapScreen.swift` — interactive map with category filters
- `CheckMate/Views/CompassScreen.swift` — heading-aware compass to nearest VC
- `CheckMate/Resources/vc_locations.json` — geocoded dataset (200 firms)
- `top_200_bay_area_vc_accelerators.csv` — source data

## Regenerate Xcode project

```bash
xcodegen generate
```

## Regenerate geocoded JSON

The bundled coordinates were generated from the CSV using OpenStreetMap Nominatim. Re-run geocoding only if addresses change.
