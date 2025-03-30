# CoreML with scikit-learn

This project demonstrates how to create and use a CoreML model trained with scikit-learn in an iOS application.

## Project Structure

- `python/`: Contains Python scripts for model training
- `learn-swift-basic/`: iOS application that uses the trained CoreML model

## Development Setup

### iOS Development

1. Clone the repository
2. Open `learn-swift-basic.xcodeproj` in Xcode
3. Configure your development settings:
   - Copy `learn-swift-basic/local.xcconfig.example` to `learn-swift-basic/local.xcconfig`
   - Update the following values in `local.xcconfig`:
     ```
     DEVELOPMENT_TEAM = YOUR_TEAM_ID
     PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.learn-swift-basic
     ```
   - Replace `YOUR_TEAM_ID` with your Apple Developer Team ID
   - Replace `com.yourcompany.learn-swift-basic` with your desired bundle identifier

4. Build and run the project

Note: The `local.xcconfig` file is ignored by Git to protect personal development settings. Each developer should create their own configuration file based on the example.

### Python Development

See the [Python README](python/README.md) for instructions on model training and CoreML conversion. 