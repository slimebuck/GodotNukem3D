# GodotNukem3D
 duke nuke clone on godot

Controls:

"move_forward" - W

"move_backwards" - S

"move_left" - A

"move_right" - D

"jump" - SPACEBAR

"shoot" - MOUSE 1

"RESTART" - R

"toggle_music" - F1

make sure the three scripts are autoloaded in Project /Project settings 


  audio.gd

  game_state.gd 

  Sprite_Rotation.gd



Introduction

Greetings! This is slimebuck here with a godot 4.2 fps project that recreates the OVERLORD from DUKE NUKEM 3D in godot. This is an example project to help people learn the basics of enemy creation.

This is the very first iteration of this project so expect many updates in the future. I will be forking this project into 2 different projects.

One will be this free example project to learn from, and the other, will be the starting of a game I will be working on. The game I will be making, will be a mix of the holy trinity of oldschool fps game, duke nukem 3D, quake 1, and blood.

you will be able to select your hero, each with a unique power or 2, and will have a level or 2 inspired by each game. I will use Qogot and load in a quake level, then edit it in trenchbroom.

As this is the first version of the project, the code is subject to be kind of spegatti like. I wanted to get a working version uploaded as soon as possible so that people can try it out, and give suggestions and feedback to help make the code as clean as possible, as to be as best of a learning tool as possible. If you see ways to simplify my code, or do things better, please by all means contact me @

slimebuck@gmail.com

Project Information

Bosses behavior is it will chase the player at a certian distance. Once in range it will start doing ranged attacks, which it will stop moving while the ranged attack animation plays. Once it gets even closer it will do physical attacks.

Boss shoots missiles and barrels, which explode when they collide with the player. It has physical attacks when you get to close, and if you actually touch the boss it will instantly kill you.

Cars and trucks explode when hit by missiles and barrels Explosions leave crater decals, and a burning fire sprite complete with fire sounds, and will damage player if they stand in it.

There is also a fake bunny hopping system in the game, where if you hold forward, every jump makes you go slightly faster and faster but then if you press any other direction or let go of forward while on the ground speed returns to base speed.

This project is meant to show off the basics of godot coding. I tried to use coding methods that every godot noob should learn, such as using groups to dectect things, to despawn things on restart, check if object should get hit or not using global scripts so that multiple entites can use the same scripts. It uses the new @export var system in godot 4.

credits:

remasted duke nukem theme: - Lee Jackson

quake song - Trent Reznor

8 directional aimated sprite array matrix - Styr0x

mizizizizizi tutorials

overlord sprite - property of 3d Realms

Kenney Particles

Kenney Cars

godot discord

chatgpt (incredible tool to help troubleshoot coding problems. Chat GPT works with godot 3.5, but it is easy to translate it to godot 4)

Version LOG: 

Version - 2 - Fixed sound toggle button to allow turning music back on, added reflections, cleaned directory other fixes 

Version 1 - First release - enjoy!


