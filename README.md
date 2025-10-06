# Alt Configurator

A World of Warcraft addon designed to help you quickly configure alternate characters by saving and applying action bar layouts across different characters and classes.

## 🎯 What It Does

Alt Configurator captures and stores your current action bar setup (all 120 action slots) and allows you to apply these layouts to other characters. This is perfect for:

- Setting up new alts with proven action bar configurations
- Sharing layouts between characters of the same class
- Quickly restoring your preferred setup after UI resets
- Testing different action bar arrangements

## ✨ Features

### Action Bar Management

- **Capture Current Bars**: Save your current action bar layout with one click
- **Smart Layout Storage**: Automatically detects class, specialization, and timestamps
- **Apply Layouts**: Transfer saved layouts to any character with confirmation dialogs
- **Layout Operations**: Rename, delete, and copy layouts with full data export

### User Interface

- **Tabbed Interface**: Clean, organized GUI with Overview and Action Bars tabs
- **Class Filtering**: Filter saved layouts by character class for easy navigation
- **Color-Coded Rows**: Class-specific colors and alternating row backgrounds for visual clarity
- **Responsive Design**: Adapts to different screen sizes with scrollable content

### Data Management

- **Persistent Storage**: All layouts saved to your WoW account using SavedVariables
- **Cross-Character Access**: Layouts available to all characters on your account
- **Smart Naming**: Automatic layout naming with character-class-spec format
- **Conflict Resolution**: Handles duplicate names and missing data gracefully

## 🚀 Getting Started

### First Use

1. Open the addon with `/altconfig` or `/ac`
2. Set up your action bars exactly how you want them
3. Click "Capture Current Bars" to save your layout
4. Switch to another character and apply the layout!

## 🎮 How to Use

### Capturing Layouts

1. **Set Up Your Bars**: Arrange spells, abilities, and items on your action bars
2. **Open Alt Configurator**: Use `/altconfig` command or keybind
3. **Click "Capture Current Bars"**: This saves your current setup
4. **Automatic Naming**: Layout named as "CharacterName-ClassName-SpecName"

### Applying Layouts

1. **Switch Characters**: Log in to the character you want to configure
2. **Open Alt Configurator**: Use `/altconfig` command
3. **Browse Layouts**: Use the class filter to find relevant layouts
4. **Click "Apply"**: Confirm the dialog to transfer the layout
5. **Combat Safety**: Application blocked during combat for safety

### Managing Layouts

- **Rename**: Click "Rename" to give layouts custom names
- **Delete**: Remove layouts you no longer need
- **Copy**: Export layout data for sharing or backup
- **Filter**: Use the class dropdown to show only relevant layouts

## 🏗️ Technical Details

### Action Bar Coverage

- **120 Action Slots**: Covers all standard action bar positions
- **Action Types Supported**:
  - Spells and abilities
  - Items and consumables  
  - Macros
  - Equipment sets
  - Mounts and pets

### Data Storage

- **SavedVariables**: Uses WoW's built-in account-wide storage
- **JSON-Compatible**: Data can be exported and shared
- **Metadata Tracking**: Stores class, spec, and timestamp information
- **Conflict Resolution**: Handles naming conflicts automatically

## 🔧 Commands

- `/altconfig` or `/ac` - Open the main interface
- `/altconfig gui` - Force open the GUI
- `/altconfig debug` - Toggle debug mode (for development)

## 🎨 User Interface Guide

### Main Window

- **Overview Tab**: Future home for statistics and quick actions
- **Action Bars Tab**: Main interface for layout management

### Action Bars Interface

- **Capture Button**: Save your current action bar setup
- **Class Filter**: Dropdown to filter layouts by character class
- **Layout List**: Scrollable list of saved layouts with operation buttons

### Layout Operations

Each layout row provides:

- **Apply**: Transfer this layout to current character
- **Rename**: Change the layout name
- **Delete**: Remove the layout permanently
- **Copy**: Export layout data for sharing

### Visual Features

- **Class Colors**: Layout names colored by character class
- **Alternating Rows**: Dark/light backgrounds for easy reading
- **Button Backgrounds**: Buttons colored to match their row
- **Timestamps**: See when each layout was captured

## 🛠️ For Developers

### Project Structure

```text
alt-configurator/
├── core/           # Core addon functionality
├── modules/        # Feature modules (GUI, ActionBars)
├── utils/          # Utility functions
├── config/         # Configuration and options
├── libs/           # Third-party libraries (Ace3)
└── build/          # Build and deployment scripts
```

### Key Components

- **ActionBarManager**: Handles capturing and applying layouts
- **GuiManager**: Manages the user interface
- **Dialogs**: Confirmation and input dialogs
- **ClassColors**: Class-specific color theming
- **Serialization**: Data export and import functionality

### Development Setup

1. Clone the repository
2. Symlink to your AddOns folder for testing
3. Use the build scripts for packaging
4. Follow WoW addon development best practices

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Test thoroughly in-game
5. Submit a pull request

## 🐛 Bug Reports & Feature Requests

Please use the GitHub issues tracker to report bugs or request new features. When reporting bugs, include:

- Your WoW version
- Addon version
- Steps to reproduce
- Any error messages
- Screenshots if applicable
