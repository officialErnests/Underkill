# Underkill
## Undertale x ultrakill
It's an unedrtale un ultrakill mashup
> Whole project was writen by human, 0 ai since i like pain raw B) so bugs to be expected XD
# Play in browser -> https://n0o0b090lv.itch.io/underkill
# What did i learn?
- How to setup godot with github and vscode
- Godots enum variables
- How to work with enum types
- Some shader scripting in godot
- Json and it quirks
- Best programming practices around enum (honestly its funny how i didn't use these XD)

# Updates
## Day 1
### Initial commit
Was used to create githubvs page and it is sorta started since it was a project of mine before
### Testing commits ~18min - 18min
Was used to test if vscode could also save to github, it can :)
## Day 2
### [UPDATED ITCH] Rewriting movement ~3h 15m - 3h 33m
I unspagetified my code and started using enum for my player movement to make it more clearer as there still is some of my old code that i will go trogh later :)
but now break time and write devlog
> As well implemented better movement
> - walking - simple AD
> - dashing - shift (takes 1 stamina)
> - jump - space
> - walljump - space when on wall (has coyote time) (only 3 times)
> - wallslide - sliding on walls makes you fallslower for time
### [UPDATED ITCH] Adding more movement ~1s 37m - 5h 10m
More movement :D
> - jumpdash - takes 2 stamina but makes you even more faster
> - groundslam - when in air ctrl and you start to fast fall and can't move, but after landing you can jump again to get to same hights or slide in biger speeds
> - jumpstorage - funny ultrakilltech where if you groundslam the walljump you get full groundslam
> - sliding - ctrl hitbox gets smaller and you slide along in one direction (Litraly still figuring this out with velocity n stuff as thunderstorm is coming so can't work on it D: )
### [UPDATED ITCH] Fixed Slide and weird slides particle effects ~1h 5m -6h  15m
Thats it player has basic movement and now i'm ready to create healt system enemies then guns and some music. Now clocking out of second day after creating this devlog B)
> - sliding - ctrl (fully functional)
> - slide jump - jump when sliding
> - groundslide - after groundslam slide it gives you alot of speed
> - fixed particles - befrore this sometimes they bugged and didn't turn off XD
## Day 3
### Stage ~ 2h - 8h 15m
Added turn order, aswell learned json in order to make enemies esier later.
Aswell more pixelart (i suck at it but ey it's works for now :D)
Player stuck in menue since haven't done fully the switch XD
> - Added some pixel art buttons
> - Made player switch from attack mode to dodge mode and so on
> - Now you can move left and right in diologue and select with w and s
## -- YSWS --
Joined YSWS programm (Jumpstart) soo i have 20 hrs top go :)
> at 8h 28m so have to subtract that from YSWS time :<
### Fight Update ~3h 2m - 11h 17m
Still working on main script, added turns(somewhat) and made cage more animated, now you can spawn inf enemies and they are auto placed :D
> - Filfth sprites :D
> - Cool cage
> - Soul movement in menu
> - made cool transition between your turn and enemies
> - menu selection O: (just move in menu nothing mutch)
> - Menu TEXT XD
## Day 4
### Menu ~2h 11m - 13h 28m
I got so menu actualy works and brings you to battle altho there is nothing to doge and menu dosn't do anything... still happy bout it since i also unspagetify the code a bit :D So now taking break and later will implament menu json fully, then will make you able to attack enemies and after that will make enemies attack you (IMO this is straight up FIRE :firex2:)
> - menu travelsar (basics [just there for my own use])
> - Enemies bob their heads now
> - Easy enemy json aswell menu json
### [UPDATED ITCH] MENU DONE ~3h 11m - 16h 39m
Well the menu works flawlesly (dunno but close enogh), next up enemies, damage and health equipment leveling and so much more (mod support, as evrything is stored in arrays)
> - cleaned up so much code
> - cleaned up some parts
> - went trogh the mess of setting up cool json [litraly all you need to mod is download github and edit array and recompile XD]
## Day 5
### [UPDATED ITCH] KILL ~3h 28m -20h 7m
I made so you can kill enemies (so cool :D love em violence), mostly numbers so it looks fire XD
[Had big debug sesion since i had bug where game crashed when tried removing enemies so thats why its 3hrs ;-; at the end i decided to rewrite the code]
(also bc they are filth they die in one hit [lore acurate XD])
> - Enemy healthbar
> - Enemies die and cool animation plays
> - Fight animation
> - Victory screen
### Multi attacks ~2h 19m -22h 26m
Made so attacks can damage multiple enemies (had to rewrite alot XD) now only thing i need is some nice dmg numbers and only then i will move on. [experimented with hit lag but it looked horible ;-;]
> - Multikill