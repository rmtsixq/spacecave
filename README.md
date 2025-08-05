# Cave FRVR Game

A 2D cave exploration game built with Godot 4, featuring realistic physics, momentum-based movement, and engaging gameplay mechanics.

## 🎮 Features

- **Realistic Physics**: Enhanced momentum system with fluid movement
- **Thrust Mechanics**: Powerful thrust system for vertical movement
- **Health System**: 3-heart health system with wall collision damage
- **Win/Lose Conditions**: WinZone for victory, death screen for game over
- **WASD Controls**: Full keyboard support with WASD and arrow keys
- **Smooth Animations**: Tilt animations and responsive controls

## 🎯 Gameplay

- **Movement**: Use WASD or Arrow keys to move
- **Thrust**: Hold movement keys for powerful thrust
- **Avoid Walls**: Don't hit walls or lose hearts
- **Reach WinZone**: Navigate to the green zone to win
- **3 Lives**: You have 3 hearts, each wall collision costs 1 heart

## 🚀 Controls

- **W/Up Arrow**: Move up
- **S/Down Arrow**: Move down
- **A/Left Arrow**: Move left
- **D/Right Arrow**: Move right
- **Hold Keys**: For stronger thrust

## 📁 Project Structure

```
cavespace/
├── player.gd              # Main player physics and controls
├── WinZone.gd             # Win condition detection
├── win_screen.gd          # Win screen UI
├── win_screen.tscn        # Win screen scene
├── heart_display.gd       # Health display system
├── death_screen.gd        # Death screen UI
├── death_screen.tscn      # Death screen scene
└── README.md              # This file
```

## 🛠️ Technical Details

### Physics System
- **Momentum**: Realistic momentum preservation
- **Thrust**: 400-800 force range with ramp-up
- **Gravity**: 250 units with buoyancy support
- **Collision**: Wall bouncing with damage system

### Health System
- **3 Hearts**: Visual heart display
- **Damage Cooldown**: 0.5 second damage immunity
- **Wall Collision**: 1 heart per collision

### UI System
- **Win Screen**: Green overlay with restart button
- **Death Screen**: Red overlay with restart/quit options
- **Health Display**: 3 red hearts above player

## 🎨 Development

This project uses Godot 4 and features:
- CharacterBody2D for player physics
- Area2D for win condition detection
- CanvasLayer for UI screens
- Advanced momentum and thrust systems

## 📝 License

This project is open source. Feel free to modify and distribute!
