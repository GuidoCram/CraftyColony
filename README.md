# CraftyColony

A Minecraft ComputerCraft Tweaked mod project with autonomous turtle roles (foresting, storing, building, mining, farming, etc.)

## Overview

CraftyColony is a comprehensive autonomous turtle system for ComputerCraft Tweaked that provides specialized roles for different tasks in Minecraft. Each turtle can be assigned a specific role and will work autonomously to perform their designated tasks while communicating with other turtles in the colony.

## Project Structure

```
src/
├── lib/                    # Core support libraries
│   ├── utils.lua          # Common utility functions
│   ├── navigation.lua     # Movement and pathfinding utilities
│   ├── inventory.lua      # Inventory management utilities
│   └── communication.lua  # Turtle communication protocols
├── roles/                 # Role-specific modules
│   ├── forester.lua       # Tree farming and logging operations
│   ├── miner.lua          # Mining and excavation operations
│   ├── farmer.lua         # Crop farming operations
│   ├── builder.lua        # Construction and building operations
│   └── storage.lua        # Item storage and sorting operations
└── main.lua               # Main entry point
```

## Available Roles

### Forester
- Automatically detects and harvests trees
- Replants saplings for sustainable forestry
- Applies bone meal to accelerate growth
- Clears leaves and manages tree farms

### Miner
- Performs strip mining at specified depths
- Identifies and prioritizes valuable ores
- Manages fuel consumption and refueling
- Places torches for cave lighting

### Farmer
- Creates and maintains crop farms
- Supports multiple crop types (wheat, carrots, potatoes, etc.)
- Automatically harvests mature crops
- Applies bone meal and manages irrigation

### Builder
- Constructs buildings from patterns/blueprints
- Manages building materials and inventory
- Supports various construction patterns (houses, bridges, towers)
- Can repair damaged structures

### Storage
- Manages centralized item storage systems
- Automatically sorts items into categorized chests
- Responds to storage and retrieval requests
- Organizes existing storage infrastructure

## Installation

1. Place the CraftyColony files in your ComputerCraft computer or turtle
2. Ensure you have a wireless modem attached for communication
3. Run the main program: `lua src/main.lua`

## Usage

### Starting a Turtle

```lua
-- Auto-detect role based on equipment
lua src/main.lua

-- Specify a specific role
lua src/main.lua forester
lua src/main.lua miner
lua src/main.lua farmer
lua src/main.lua builder
lua src/main.lua storage
```

### Commands

```lua
-- Show system status
lua src/main.lua status

-- Test a role module
lua src/main.lua test forester

-- List available roles
lua src/main.lua roles

-- Discover nearby turtles
lua src/main.lua discover

-- Show help
lua src/main.lua help
```

## Features

### Communication System
- Automatic turtle discovery
- Message-based communication protocols
- Resource sharing and coordination
- Emergency broadcast system

### Navigation System
- GPS integration when available
- Pathfinding and obstacle avoidance
- Position tracking and return-to-base
- Multi-directional movement functions

### Inventory Management
- Automatic item categorization
- Inventory optimization and compacting
- Item counting and searching
- Storage capacity monitoring

### Modular Design
- Each role is a separate module
- Easy to extend with new roles
- Shared library functions
- Configurable parameters

## Configuration

Each role module has configurable parameters that can be adjusted:

```lua
-- Example: Forester configuration
forester.config = {
    saplingSlot = 1,
    boneMealSlot = 2,
    maxTreeHeight = 20,
    replantSaplings = true,
    useBoneMeal = true,
    workArea = {
        minX = -10, maxX = 10,
        minZ = -10, maxZ = 10
    }
}
```

## Requirements

- ComputerCraft Tweaked mod
- Wireless modem for communication
- Appropriate tools for each role:
  - Forester: Axe, saplings
  - Miner: Pickaxe, fuel, torches
  - Farmer: Hoe, seeds, bone meal
  - Builder: Building materials
  - Storage: Chests or barrels

## Communication Protocol

Turtles communicate using rednet with a custom protocol. Messages include:
- PING/PONG for connectivity testing
- STATUS_REQUEST/STATUS_RESPONSE for status checking
- RESOURCE_REQUEST/RESOURCE_OFFER for resource sharing
- TASK_ASSIGNMENT/TASK_COMPLETE for job coordination
- EMERGENCY for critical situations

## Contributing

To add a new role:

1. Create a new file in `src/roles/`
2. Implement the required functions: `init()`, `workLoop()`, `getStatus()`
3. Add the role to the roles table in `main.lua`
4. Follow the existing patterns for communication and configuration

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.
