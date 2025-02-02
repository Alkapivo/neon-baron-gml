# Gameplay predicates/ideas
 - NEON BARON require RPG system
 - Player has experiance points and level
 - Player can gain experiance points by playing tracks, resolving quests, selecting dialogue options, interacting with map objects
 - Each level up gaves 5 skill points
 - Skill points can be used to unlock schematics
 - Skill points can be used to extend available chip slots for specified gameplay mode
 - Schematics can be used to create chip items
 - Each gameplay mode contains separate chip slots (amount depends on player level)
 - Player can add or remove chips from slots in NEON CITY gameplay mode.
 - Only one chip of type bomb can be equipped for each gameplay mode
 - Player inventory contains collection of items, amount of gold, 
 - Player can buy and sell items between NPC with trade option.
 - Item can be used in player inventory
 - Item can be used with map object
 - Credits can be earned by...?

## Game state model
```js
player = {
  "map": {
    "name": "neon-pub",
    "x": 0,
    "y": 0
  },
  "level": 1,
  "exp": 0,
  "sp": 0,
  "credits": 100,
  "visu": {
    "life": {
      "value": 1,
      "max": 3
    },
    "bomb": {
      "value": 2,
      "max": 3
    },
    "slotA": "chip-bomb-01",
    "slotB": null,
    "slotC": null
  },
  "schematics": [ "chip-bomb-01" ],
  "items": [
    {
      "amount": 3,
      "item": "empty-chip"
    }
  ],
  "quests": [
    {
      "name": "first-quest",
      "status": "finished",
      "steps": [
        "find-item",
        "return-item",
        "finished"
      ],
      "step": "finished"
    }
  ],
  "vars": {
    "quest_first-quest_npc-talked": true,
    "map_neon-pub_secret-lever": true,
    "map_neon-pub_secret-item": true
  }
}
```

LevelSystems:
- PlayerSystem
- NPCSystem
- NPCSpawnerSystem
- DoorSystem
- SwitchSystem
- ButtonSystem
- FieldTriggerSystem
- StaticDecoratorSystem
- DynamicDecoratorSystem
- LightSourceSystem

Entity:
- uid: String
  
LevelObject:
- entity: Entity
- x: Number
- y: Number
- width: Number
- height: Number
- margin: Margin
- flat: Boolean
- solid: Boolean
- enabled: Boolean

LevelObject abstract classes:
- StaticObject (it's  always loaded from LDTK, if state does not exists then execute with LDTK parameters)
- DynamicObject (if state exists then load DynamiObjects from state only)

LevelObject interfaces:
- Serialize
- Actor (sth which can be moved)
- Interactive (when player is nearby then it is possible to press key or mouse click)
- Trigger (when Actor enter or leave tile then execute some actions)
- Sprite
- Actions (e.g. set flag value)
- Conditions (e.g. list of required flags)

LevelObject classes:
- Player (DynamicObject):
  - Serialize
  - Actor
  - Solid
  - Sprite
- NPC (DynamicObject): 
  - Serialize
  - Actor
  - Solid
  - Interactive
  - Actions
  - Conditions
  - Sprite
- NPCSpawner (DynamicObject):
  - Serialize
  - Conditions
  - Actions
- Door (StaticObject):
  - Serialize
  - Solid
  - Interactive
  - Actions
  - Conditions
  - Sprite
- Switch (StaticObject): 
  - Serialize
  - Interactive
  - Actions
  - Conditions
  - Sprite
- Button (StaticObject): 
  - Interactive
  - Actions
  - Conditions
  - Sprite
- Trigger (StaticObject):
  - Trigger
  - Conditions
  - Actions
- Decorator (StaticObject):
  - Conditions
  - Sprite
  - Solid
- LightSource (StaticObject)
  - LightSource
  - Conditions

UI:
 - Player stats
 - Player inventory
 - Player skill tree
 - Visu skill EQ
 - Quests
 - Minimap
 - Dialog
 - NPC Trade
 - In-game menu
 - Main menu

# Scenes
```gml
{
  scene_intro: {
    init: {
      description: "init services",
      transition: [ "video", "quit" ]
    },
    video: {
      description: "load, play or skip the video",
      stages: [ "open", "play", "close", "goto scene_menu" ],
      transition: [ "quit" ]
    },
    quit: {
      description: "exit game or goto scene_menu"
    }
  },
  scene_menu: {
    init: {
      description: "init services",
      transition: [ "load", "quit" ]
    },
    load: {
      description: "parse save files",
      transition: [ "idle", "quit" ]
    },
    idle: {
      description: "handle menu",
      transition: [ "quit" ]
    },
    quit: {
      description: "exit game or goto scene_game"
    }
  },
  scene_game: {
    init: {
      description: "init services",
      transition: [ "loadWorld" ]
    },
    loadWorld: {
      description: "parse LDTK world state (save file)",
      transition: [ "loadLevel" ]
    },
    loadLevel: {
      description: "create layers and entities from LDTK world (state is already parsed)",
      transitions: [ "gameplay", "quit" ]
    },
    save: {
      description: "store game state on file system",
      transitions: [ "gameplay", "visu", "quit" ]
    },
    gameplay: {
      description: "handle game",
      transitions: [ "dialog", "loadVisu", "loadLevel", "quit" ]
    },
    dialog: {
      description: "handle dialog",
      transitions: [ "gameplay", "dialog", "loadVisu", "loadLevel", "quit" ]
    },
    loadVisu: {
      description: "run VisuTrackLoader"
      transitions: [ "visu", "gameplay", "quit" ]
    },
    visu: {
      description: "handle visu"
      transitions: [ "gameplay", "quit" ]
    },
    pause: {
      description: "esc menu",
      transitions: [ "gameplay", "save", "quit" ]
    },
    pauseVisu: {
      description: "esc menu with 3 sec delay",
      transitions: [ "visu", "gameplay", "quit" ]
    },
    quit: {
      description: "exit game or goto scene_menu or goto scene_game"
    }
  }
}
```
