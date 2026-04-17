# Creating Custom Unit Sprites for War1gus

## Overview

War1gus uses the Stratagus engine which requires sprites in a specific format:
- **8-bit indexed PNG** (palette-based color)
- **Stratagus color palette** (256 colors)
- **Multiple directional frames** (8 directions: N, NE, E, SE, S, SW, W, NW)
- **Animation frames** for different actions (idle, move, attack, die)

## Graphics Requirements

### Color Palette

War1gus uses a standard Stratagus palette. The palette is divided into sections:

```
0-15:     Standard colors (black, white, etc.)
16-31:    Grays
32-47:    Reds
48-63:    Greens
64-79:    Blues
80-95:    Yellows
96-111:   Purples
112-127:  Cyans
128-143:  Skin tones (human)
144-159:  Skin tones (orc)
160-175:  Hair colors
176-191:  Armor/metal
192-207:  Wood/brown
208-223:  Stone/gray
224-239:  Shadows
240-255:  Special effects/transparency
```

### Sprite Sheet Format

#### Frame Size
- **Unit size:** Typically 32x32 or 64x64 pixels
- **Padding:** Usually 2-4 pixels between frames
- **Background:** Transparent (use color 0 or designated transparent color)

#### Direction Order (8 directions)
```
Direction mapping (like a clock):
   NW  N  NE
    \ | /
W ---unit--- E
    / | \
   SW  S  SE

Indices: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW
```

#### Animation Sequences Example (32x32 unit)

**Still/Idle Animation:**
```
Row of 8 frames (one for each direction):
[Facing N] [Facing NE] [Facing E] [Facing SE] [Facing S] [Facing SW] [Facing W] [Facing NW]
```

**Move Animation:**
```
8 rows × 8 directions = 64 total frames
Each row = one walking frame repeated in 8 directions
Row 0: Walking frame 1 in all 8 directions
Row 1: Walking frame 2 in all 8 directions
...
Row 7: Walking frame 8 in all 8 directions
```

**Attack Animation:**
```
Similar to move - multiple attack frames in 8 directions
Usually 4-6 frames showing the attack motion
```

**Die/Death Animation:**
```
Usually 3-4 frames showing falling/death
Can be single row (same death animation in all directions)
or 8 rows (different death animation per direction)
```

## Step-by-Step Creation Process

### Option 1: Using GIMP (Free)

1. **Create new image:**
   - Width: 256 pixels (8 frames × 32px)
   - Height: Variable based on animations
   - Mode: **Indexed Color** (not RGB!)

2. **Load Stratagus Palette:**
   - Image → Mode → Indexed Color
   - Choose "Use custom palette"
   - Load: `/path/to/stratagus/contrib/graphics/stratagus.pal`

3. **Draw your sprite:**
   - Create guides at 32px intervals
   - Draw each directional frame
   - Use only colors from the Stratagus palette

4. **Export:**
   - File → Export As
   - Format: **PNG**
   - Make sure indexed color is preserved
   - Name: `myfaction/myunit.png`

### Option 2: Using Aseprite (Paid but Easier)

1. Create sprite with 32x32 canvas
2. Set palette to Stratagus palette
3. Create frames for each direction
4. Use tags for animation sequences
5. Export as PNG (automatic palette indexing)

### Option 3: Using LibreSprite (Free, GIMP-like)

Similar to GIMP but built for sprite animation.

## File Organization

Place your sprites in:
```
War1gus.app/Resources/contrib/graphics/
├── human/
│   ├── knight.png          # Your new unit sprite
│   ├── archer.png
│   └── ...
├── orc/
│   ├── goblin.png
│   └── ...
└── shared/
    └── effects.png
```

Or if installed:
```
/usr/local/share/games/stratagus/war1gus/contrib/graphics/
```

## Converting Sprites with png2stratagus

Once you have your PNG sprite sheets, you may need to convert them to Stratagus internal format:

```bash
# Check if conversion is needed
png2stratagus input.png output.png

# The tool handles:
# - Color palette conversion
# - Format optimization
# - Transparency handling
```

## Defining Your Unit with Custom Sprites

Once your sprite is ready, define the unit in Lua:

```lua
-- scripts/human/units.lua (or orc/units.lua)

DefineUnitType("unit-custom-archer", {
    Name = "Custom Archer",
    File = "human/custom-archer",  -- References: human/custom-archer.png
    Width = 32,
    Height = 32,
    Animations = "animations-human-custom-archer",
    Icon = "icon-human-custom-archer",
    
    -- ... rest of unit definition
})

-- Define animations that match your sprite frames
DefineAnimations("animations-human-custom-archer", {
    Still = {
        "frame 0", "wait 5",
        "frame 1", "wait 5",
        "frame 0", "wait 6"
    },
    Move = {
        "unbreakable begin",
        "frame 2", "move 1",
        "frame 3", "move 1",
        "frame 4", "move 1",
        "frame 5", "move 1",
        "frame 6", "move 1",
        "frame 7", "move 1",
        "unbreakable end",
        "wait 1"
    },
    Attack = {
        "unbreakable begin",
        "frame 8", "wait 3",
        "frame 9", "wait 3",
        "frame 10", "wait 3",
        "unbreakable end",
        "wait 1"
    },
    Die = {
        "unbreakable begin",
        "frame 11", "wait 5",
        "frame 12", "wait 10",
        "unbreakable end"
    }
})
```

## Icon Creation

You also need a **unit icon** for the UI:

**Requirements:**
- Size: 32x32 or 46x46 pixels
- Format: 8-bit indexed PNG
- Should be a simplified/top-down view of the unit
- Clear and recognizable at small size

**Location:**
```
contrib/graphics/icons/human/custom-archer.png
```

**Define in Lua:**
```lua
DefineIcon("icon-human-custom-archer", {
    File = "icons/human/custom-archer",
    Size = 32
})
```

## Animation Frame Reference

### Common Frame Counts

| Animation | Typical Frames |
|-----------|----------------|
| Still/Idle | 1-4 |
| Move | 8 (varying number of poses) |
| Attack | 4-6 |
| Die | 2-4 |
| Special ability | 4-8 |

### Frame Format in Lua

```lua
-- "frame X" - display frame number X
-- "move N" - move unit N pixels
-- "wait N" - wait N frames
-- "unbreakable begin" - can't interrupt animation
-- "unbreakable end" - animation can now be interrupted
```

## Testing Your Sprite

1. **Place PNG in correct location:**
   ```
   War1gus.app/Resources/contrib/graphics/human/myunit.png
   ```

2. **Define unit in Lua script:**
   ```lua
   -- Add to scripts/human/units.lua or create custom mod file
   ```

3. **Load mod file:**
   - Create `scripts/mods/mymod.lua` with your unit definitions
   - Add to `scripts/stratagus.lua`: `load("scripts/mods/mymod.lua")`

4. **Test in game:**
   - Run war1gus
   - Create map with your unit available
   - Verify sprite displays correctly in all directions and animations

## Troubleshooting

### Sprite doesn't appear
- Check file path matches `File = "..."` in Lua
- Verify PNG is 8-bit indexed color (not RGB)
- Ensure transparency color is correct (usually color 0)

### Wrong colors
- Verify Stratagus palette is being used
- Check PNG color mode is indexed, not RGB
- Reimport/reexport palette if needed

### Animation jumps around
- Check frame numbers in animation definition
- Verify sprite sheet has frames in correct positions
- Ensure frame indices match your sprite layout

### Unit rotates wrong direction
- Check direction order (0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW)
- Verify frames are arranged in correct direction sequence

## Resources

### Existing Unit Sprites
Study existing War1gus sprites for reference:
```
War1gus.app/Resources/contrib/graphics/
```

### Stratagus Tools
- `png2stratagus` - sprite converter (already installed at `/usr/local/bin/`)
- Stratagus headers - API reference

### Community
- Wargus GitHub: https://github.com/Wargus/wargus
- Stratagus Forums: Community modding discussions

## Quick Checklist

- [ ] Create sprite PNG (8-bit indexed)
- [ ] Arrange frames for all 8 directions
- [ ] Create animation frames (move, attack, die)
- [ ] Save with Stratagus color palette
- [ ] Place in `contrib/graphics/` folder
- [ ] Create icon (32x32 PNG)
- [ ] Define animations in Lua
- [ ] Define unit type in Lua
- [ ] Test in game
- [ ] Adjust sprite/animations as needed
- [ ] Repeat for each animation state

Good luck with your custom sprites!
