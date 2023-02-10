; extensions
extensions [ sound ]


; breeds
breed [ players player ]
breed [ player-bullets player-bullet ]
breed [ enemy-bullets enemy-bullet ]
breed [ landing-zones landing-zone ]
breed [ enemies enemy ]
breed [ explosions explosion ]
breed [ final-statuses final-status ]
breed [stars star]
breed [ loves love ]
breed [ monsters  monster ]
breed [monster-bullets monster-bullet ]

; Global variables
globals [
  mouse-was-down
  stop-game
    final-stage
]

; Private varaiabled
players-own [
 health
]

enemies-own [
 health
  target
  speed
]

monsters-own
[
  health
]

to next


      if count enemies = 0 and stop-game = false
  [
 if not any?  monsters
    [
    setup-monsters
       set final-stage  true
  ]
  ]

end






; Setup procedures
to setup

 clear-all
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;new new
              ; set-default-shape turtles "star"
              ; draw-walls
               create-stars 50                                ;; create some turtles
              [ set shape "star"
                set size 2
    randomize

  ]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;new
 reset-ticks

 set stop-game false

 setup-players
 setup-landing-zones
 setup-enemies
  ;;;;;;;;;;;;;;;;;;;;;;
 ; setup-turtles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 set mouse-was-down false

  ask patches with [ count neighbors != 8 ]
    [ set pcolor blue ]

end

to setup-loves

  create-loves 1
   [
    set shape "circle"
    setxy random-xcor random-ycor
    set size 3
   ; set label health
    ]

end
to love-rule
  ask loves
  [
    fd 0.001


  if [pcolor] of patch-here = blue [
      die
    ]




    ask players in-radius 3 [
      if health < 100
      [
      set health (health + 0.01)

    ]
      ask loves in-radius 2 [

      die
    ]


    ]






 ]

end







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                      ; draws the boundaries of the billiard table
;to draw-walls
;ask patches with [abs pxcor = max-pxcor]
 ; [ set pcolor blue ]
 ;ask patches with [abs pycor = max-pycor]
;  [ set pcolor blue ]
;end

; set random coordinates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to randomize
 setxy random-xcor random-ycor
 if pcolor = blue       ; if it's on the wall...
   [ randomize ]        ; ...try again
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;to bounce  ;; turtle procedure
;if abs [pxcor ] of  patch-ahead 0 = max-pxcor
; [ die ]
;if abs [pycor ] of  patch-ahead 0 = max-pycor
;[ die ]
;end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;








to setup-players
create-players 1

 ask players [
   set shape "ufo side"
   set color blue
   set size 3
   setxy 40 50
   set heading 0
   set health 200


 ]

end


to setup-enemies
  ask enemies [
    set shape "cannon"
    set size 4
    set color red
    set heading 180
    set health 25
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    set target one-of players
    face target
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ]
end



to setup-monsters
  create-monsters 1
    ask monsters
    [
      set shape "cannon carriage"
    set size 8
    setxy random-pxcor random-pycor
    set color red
    set heading 180
    set health 100
    ]


end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LANDING ZONES COMMENTED
to setup-landing-zones

  let y 0

  create-landing-zones 4
  ask landing-zones [
    set shape "circle"
    set size 3
    set color black

    set y ( y + 16 )

    setxy y  (max-pycor - 40)

   hatch-enemies 1 [
     create-link-from myself [
       set color black
     ]

]

  ]

end



; Play procedures (forever procedures)
to play
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ask stars [
    ;ifelse leave-trace?             ;; the turtle puts its pen up or down depending on the
     ; [ pen-down ]                  ;;   value of the LEAVE-TRACE? switch
     ; [ pen-up ]
   ;bounce
   fd 0.0002
    if [pcolor] of patch-here = blue
    [die]
  ]
  tick
  ;;;;;;;;;;;;;;;;;;;;;;;
 tick

 if stop-game = true [
    stop
  ]

 player-rules
 player-bullet-rules
 enemy-bullet-rules
 enemy-rules
 explosion-rules
 check-mouse-button

love-rule
 if not any? loves
      [
       setup-loves
      ]

       monster-rules
      monster-bullet-rules

  if final-stage = true and not any? enemies and not any? monsters
  [
    game-win
  ]

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;to go
;  ask stars [
;    ifelse leave-trace?             ;; the turtle puts its pen up or down depending on the
;      [ pen-down ]                  ;;   value of the LEAVE-TRACE? switch
;      [ pen-up ]
   ;bounce
 ;  fd 0.0001
 ;   if [pcolor] of patch-here = blue
 ;   [die]
 ; ]
 ; tick
;end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-mouse-button

  if mouse-down? = false [
    set mouse-was-down false
  ]

  if mouse-down? and mouse-was-down = false [
     set mouse-was-down true

     ask players [
       hatch-player-bullets 1 [
        set size 1
        set shape "default"
        set color random 140
        set label ""
       ]

     ]

    sound:play-note "Gunshot" 65 64 2

  ]

end


to player-rules

  ask players [

   if health <= 0 [
     game-over
   ]

   set label round(health)
   facexy mouse-xcor mouse-ycor
 ]

end


to monster-rules
;  if count enemies = 0   [
;    if count monsters = 0 [
;    game-win
;  ]
;  ]
  ask monsters[
     set label round(health)

      ask players in-radius 1 [
    ;  explode
      set health 0
  ]

   ;    if health <= 0 [
  ;   game-over
 ;  ]

    if health <= 0 [
      explode
      die
    ]

      if distance one-of players < 70 [
      set heading towards one-of players
      fd 0.001

      if remainder ticks one-of [10000 15000 25000] = 0 [

        hatch-monster-bullets 1 [
          set size 1
          set shape "default"
          set color random 140
          set label ""
        ]

        sound:play-note "Gunshot" 65 64 2
      ]


    ]
  ]

end



to enemy-rules

 ; if count enemies = 0 [
;    game-win
 ; ]






  ask enemies [

    if health <= 20[
    set color yellow
    ]
    if health <= 0 [
      explode
      die
    ]

    set label round(health)

    ifelse distance one-of players < 50 [
      set heading towards one-of players
      fd 0.0001

      if remainder ticks one-of [10000 15000 25000] = 0 [

        hatch-enemy-bullets 1 [
          set size 1
          set shape "default"
          set color random 140
          set label ""
        ]

        sound:play-note "Gunshot" 65 64 2
      ]


    ] [
      face one-of link-neighbors

      ifelse distance one-of link-neighbors < 1 [
        move-to one-of link-neighbors
        set heading 180
      ] [
        fd 0.0001
      ]


    ]
  ]


end


to player-bullet-rules
  ask player-bullets [
   fd 0.01

    if [pcolor] of patch-here = blue [
      die
    ]

    if distance one-of landing-zones < 5 [
     die
    ]

    ask enemy-bullets in-radius 3 [
      bullet-explode
      die
    ]

    if one-of enemy-bullets != nobody and distance one-of enemy-bullets < 3 [
        bullet-explode
        die
    ]

    ask enemies in-radius 3 [
      set health (health - 0.01)
    ]

       ask monsters in-radius 3 [
      set health (health - 0.01)
    ]

  ]
end


to monster-bullet-rules
    ask monster-bullets [
   fd 0.01

   if [pcolor] of patch-here = blue [
      die
   ]

    ask player-bullets in-radius 3 [
      bullet-explode
      die
    ]

    if one-of player-bullets != nobody and distance one-of player-bullets < 3 [
      bullet-explode
      die
    ]

   ask players in-radius 3 [
       set health (health - 0.01)
   ]

  ]
end

to enemy-bullet-rules

  ask enemy-bullets [
   fd 0.01

   if [pcolor] of patch-here = blue [
      die
   ]

    ask player-bullets in-radius 3 [
      bullet-explode
      die
    ]

    if one-of player-bullets != nobody and distance one-of player-bullets < 3 [
      bullet-explode
      die
    ]

   ask players in-radius 3 [
       set health (health - 0.01)
   ]

  ]

end


to explosion-rules
  ask explosions [
    fd 0.01

    if [pcolor] of patch-here = blue [
      die
    ]
  ]

end


to explode
  hatch-explosions 25 [
    set shape "Default"
    set color orange
    set size 2
    set heading random 360
    set label ""
  ]

  sound:play-note "Gunshot" 0 64 2
end


to bullet-explode
  hatch-explosions 3 [
    set shape "Default"
    set color grey
    set size 1
    set heading random 360
    set label ""
  ]

  sound:play-note "Gunshot" 50 64 2
end



; Game end procedures
to game-over
  hatch-final-statuses 1 [
     setxy 40 40
     set shape "x"
     set size 50
     set label "game over"
     set color red
  ]

  set stop-game true
end


to game-win
  create-final-statuses 1 [
     setxy 40 40
     set shape "face happy"
     set size 15
     set label ""
     set color yellow
  ]

  set stop-game true

end



; Player movements
to go-up

  ask players [
    set heading 0

    if ycor < max-pycor [
      set ycor (ycor + 1)
    ]

  ]
end


to go-down

  ask players [
    set heading 180

    if ycor > min-pycor [
      set ycor (ycor - 1)
    ]
  ]

end


to go-left

  ask players [
    set heading -90

    if xcor > min-pxcor [
      set xcor (xcor - 1)
    ]
  ]
end


to go-right

  ask players [
    set heading 90
    if xcor < max-pxcor [
      set xcor (xcor + 1)
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
221
10
1282
1072
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
80
0
80
0
0
1
ticks
30.0

BUTTON
17
53
95
95
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
114
54
201
97
Play
play
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
68
179
132
213
UP
go-up
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
64
253
134
287
DOWN
go-down
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
4
217
68
251
LEFT
go-left
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
135
215
203
249
RIGHT
go-right
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
53
113
116
146
NIL
next
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?
This is a model of a "Space game" named "Space Mission". 

## HOW IT WORKS

Stage 01:
Initially, there are 4 cannons(enemies) in the game.
Once you click on the play button the enemies start to shoot the user. 
The enemies are bounded to a particular region that they can shoot. Also, they cannot move.
In order to be safe from the shots the user should move accordingly. Also, the user can shoot back at the enemies to save his life.
To increase the power limit, the user can collect the power balls which appear on the screen randomly.
Once the life of the user(power limit) becomes 30, it turns yellow. 
After the power limit of the user becomes 0 he is considered killed.

Stage 02:
To resume the game the user needs to press the next button. 
Once you click on the next button all 4 enemies will disappear and another single large enemy will appear on the screen. 
Unlike the previous enemies, this single enemy can move and can shoot at any region. Also, it can chase after the user.

Winning Conditions:
If the user is able to kill all four enemies he will win the game, otherwise, it is considered as “Losing the game”.

## HOW TO USE IT

First, click the setup button and set up the agents on the game window. (player, enemies, stars).
Then click on the play button and start playing.
To move the user up, down, right and left use the keys available.
Also, you can use the keyboard arrow keys to move the user.
The mouse can be used to shoot back enemies.  


## THINGS TO NOTICE

Notice the power balls appearing in the gaming window randomly which can increase the power of the user.
Notice the life increases and decreases of the user and the enemies.
After the power level of 20, the user will be turned yellow.

## THINGS TO TRY

Try collecting more power balls.

## EXTENDING THE MODEL

This game is expected to expand into levels. To increase levels one after one.
When the level increases, the hardness of the game will increase.

## RELATED MODELS

We have used some existing models in the Netlogo library such as Bounce Example and Label Position Example.

## CREDITS AND REFERENCES

https://www.youtube.com/watch?v=ZGuHuMfUjTU


PS: This is an extension of the above game.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

cannon
true
0
Polygon -7500403 true true 165 0 165 15 180 150 195 165 195 180 180 195 165 225 135 225 120 195 105 180 105 165 120 150 135 15 135 0
Line -16777216 false 120 150 180 150
Line -16777216 false 120 195 180 195
Line -16777216 false 165 15 135 15
Polygon -16777216 false false 165 0 135 0 135 15 120 150 105 165 105 180 120 195 135 225 165 225 180 195 195 180 195 165 180 150 165 15

cannon carriage
false
0
Circle -7500403 false true 105 105 90
Circle -7500403 false true 90 90 120
Line -7500403 true 180 120 120 180
Line -7500403 true 120 120 180 180
Line -7500403 true 150 105 150 195
Line -7500403 true 105 150 195 150
Polygon -7500403 false true 0 195 0 210 180 150 180 135

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

rocket
true
0
Polygon -7500403 true true 120 165 75 285 135 255 165 255 225 285 180 165
Polygon -1 true false 135 285 105 135 105 105 120 45 135 15 150 0 165 15 180 45 195 105 195 135 165 285
Rectangle -7500403 true true 147 176 153 288
Polygon -7500403 true true 120 45 180 45 165 15 150 0 135 15
Line -7500403 true 105 105 135 120
Line -7500403 true 135 120 165 120
Line -7500403 true 165 120 195 105
Line -7500403 true 105 135 135 150
Line -7500403 true 135 150 165 150
Line -7500403 true 165 150 195 135

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

ufo side
false
0
Polygon -1 true false 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 195 105 150 105 105 105 60 105 15 120 0 135
Polygon -16777216 false false 105 105 60 105 15 120 0 135 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 210 105
Polygon -7500403 true true 60 131 90 161 135 176 165 176 210 161 240 131 225 101 195 71 150 60 105 71 75 101
Circle -16777216 false false 255 135 30
Circle -16777216 false false 180 180 30
Circle -16777216 false false 90 180 30
Circle -16777216 false false 15 135 30
Circle -7500403 true true 15 135 30
Circle -7500403 true true 90 180 30
Circle -7500403 true true 180 180 30
Circle -7500403 true true 255 135 30
Polygon -16777216 false false 150 59 105 70 75 100 60 130 90 160 135 175 165 175 210 160 240 130 225 100 195 70

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
