{\rtf1\ansi\ansicpg1252\cocoartf2870
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fmodern\fcharset0 CourierNewPS-BoldMT;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\b\fs24 \cf0 # Migla\
\
A cozy 2D side-scrolling exploration game built in Godot 4, following a small fox through a procedurally generated Latvian-inspired countryside \'97 forests, meadows, fog, rain, and a mysterious barn along the way.\
\
Built as a CS A-level programming project.\
\
## Gameplay\
\
Walk endlessly through procedurally generated terrain, collecting mushrooms, flowers, stones, coins and wild berries along the way. Your furthest distance is saved and can be loaded again later under your chosen name.\
\
## Controls\
\
| Key | Action |\
|---|---|\
| Left / Right Arrow | Move |\
| Up Arrow | Jump |\
| B | Open / close backpack |\
| G | Drop items |\
| E | Eat nearby berries |\
\
## Features\
\
- Procedurally generated terrain using Perlin noise, with jump-clamped height variation\
- Persistent save/load system backed by a local SQLite database (username, furthest distance)\
- Dynamic parallax backgrounds: layered trees, drifting clouds, atmospheric fog, and occasional weather (rain)\
- A rare landmark (a barn) that appears at fixed distance intervals\
- Custom-drawn pixel art fox character with walk animation\
- Inventory system with a capped backpack UI\
\
## Tech stack\
\
- **Engine:** Godot 4.6 (GDScript)\
- **Database:** SQLite via the [godot-sqlite](https://github.com/2shady4u/godot-sqlite) addon\
- **Art:** Hand-drawn in Procreate\
\
## Project structure\
\
- `chunk.gd` \'97 procedural terrain generation, decoration spawning (trees, clouds, fog, barn)\
- `world.gd` \'97 chunk streaming, distance tracking, weather system\
- `player.gd` \'97 movement, jumping, inventory interface\
- `database.gd` \'97 save/load logic\
- `main_menu.gd` \'97 title screen, new/load game flow}