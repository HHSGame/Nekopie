# V2: Visual Overhaul — Card UI, Layout, and Asset Regeneration

## Vision
Replace all minimal/abstract SVG assets with thematic, detailed isekai-fantasy visuals.
Rebuild card area UI, button layout, and panel styling for a polished TCG-like experience.

## Scope
- Regenerate all 40+ card art SVGs with per-card thematic designs
- Regenerate card frame, gem, glow with card-game styling
- Regenerate all 13 portraits with distinct anime-style characters
- Regenerate all 20+ icons (intents, stats, UI buttons) with consistent visual language
- Regenerate mountain background with detailed environment
- Regenerate scene frame, title banner with isekai theming
- Rebuild CardWidget scene with proper TCG card layout (frame, art, name, cost, desc, badge)
- Add hover/selection state styling to buttons
- Improve theme colors in default_theme.tres
- Add button icon + hover panel effects in RunScreen hand dock
- Ensure all assets have `uid` and .import files tracked

## Non-Goals
- No gameplay logic changes
- No new card effects or balance changes
- No structural refactoring

## Visual Direction
- Color palette: deep purples (#2a1a3a), midnight blues (#121826), gold accents (#f1c86b)
- Card style: rounded rect with gradient border, art block, name/cost header, desc area
- Portrait style: bust-up character with frame, status overlay
- Icon style: white-on-transparent with 24px baseline
- Button style: gradient fill with gold border, hover brighten

## Deliverables
1. All SVG files rewritten (~50 files)
2. CardWidget.tscn rebuilt with new layout
3. RunScreen.tscn panel/layout refinements
4. default_theme.tres expanded with button/panel styles
5. .import files updated

