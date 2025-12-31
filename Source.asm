; Super Mario Bros Clone - MASM615 Assembly
; Using Irvine32 Library
; COMPLETE UPDATED VERSION (Fixes + Level 2 Obstacles/Stars)

INCLUDE Irvine32.inc

; =============================================================
; PROTOTYPES
; =============================================================
Beep PROTO,
    dwFreq:DWORD,
    dwDuration:DWORD

.data
    ; ===== PLAYER STATE AND PHYSICS VARIABLES =====
    mario_xPos DWORD 20     
    mario_yPos DWORD 20     
    mario_xVel SDWORD 0     
    mario_yVel SDWORD 0     
    mario_state BYTE 0      ; 0=Small, 1=Super
    
    ; ===== RAIN SYSTEM =====
    RAIN_DROP_COUNT DWORD 15         
    rain_xPos DWORD 15 DUP(0)        
    rain_yPos DWORD 15 DUP(0)        
    old_rain_xPos DWORD 15 DUP(0)    
    old_rain_yPos DWORD 15 DUP(0)    
    rainActive BYTE 1    
    rainFrameCounter DWORD 0         

    ; ===== LEVEL 1: COLLECTIBLE STARS =====
    STAR_COUNT DWORD 3
    star1_x DWORD 31       
    star1_y DWORD 15       
    star1_active BYTE 1
    
    star2_x DWORD 52       
    star2_y DWORD 14
    star2_active BYTE 1
    
    star3_x DWORD 61       
    star3_y DWORD 14
    star3_active BYTE 1
    
    ; ===== LEVEL 2: CASTLE OBSTACLES & STARS (NEW) =====
    ; Obstacle 1 (Stone Pillar)
    c_obst1_x      DWORD 35
    c_obst1_height DWORD 4       ; 4 blocks high (reachable)
    
    ; Obstacle 2 (Tall Pillar)
    c_obst2_x      DWORD 55
    c_obst2_height DWORD 5       ; 5 blocks high

    ; Star 1 (Above Obstacle 1)
    c_star1_x      DWORD 35
    c_star1_y      DWORD 16      ; Reachable Y position
    c_star1_active BYTE 1

    ; Star 2 (Above Obstacle 2)
    c_star2_x      DWORD 55
    c_star2_y      DWORD 15      
    c_star2_active BYTE 1

    ; ===== PHYSICS CONSTANTS =====
    GRAVITY_ACCEL SDWORD 1
    JUMP_STRENGTH SDWORD -4
    MAX_X_SPEED SDWORD 3        
    MAX_Y_SPEED SDWORD 3
    ACCEL_AMOUNT SDWORD 2       
    FRICTION_AMOUNT SDWORD 1
    
    ; ===== ENEMY CONSTANTS =====
    GOOMBA_COUNT DWORD 2
    STOMP_BOUNCE SDWORD -2
    STOMP_SCORE DWORD 100
    
    ; ===== POWER-UP CONSTANTS =====
    POWERUP_SCORE DWORD 1000
    POWERUP_SPEED SDWORD 1
    
    ; ===== PLAYER POWER-UP STATE =====
    isSuper BYTE 0       
    isFire BYTE 0        
    fireCharge DWORD 0    
    isTurbo BYTE 0       
    turboTimer DWORD 0   

    ; ===== POWER-UP VARIABLES =====
    powerUp_xPos DWORD 0
    powerUp_yPos DWORD 0
    powerUp_active BYTE 0        
    
    ; ===== QUESTION BLOCK HIT FLAGS =====
    qblock1_hit BYTE 0           
    qblock2_hit BYTE 0
    qblock3_hit BYTE 0
    
    ; ===== ENEMIES =====
    goomba1_xPos DWORD 40
    goomba1_yPos DWORD 22
    goomba1_dir SDWORD 1  
    goomba1_leftBound DWORD 35
    goomba1_rightBound DWORD 55
    goomba1_active BYTE 1        
 
    goomba2_xPos DWORD 65
    goomba2_yPos DWORD 22
    goomba2_dir SDWORD 1
    goomba2_leftBound DWORD 58
    goomba2_rightBound DWORD 75
    goomba2_active BYTE 1

    koopa_xPos DWORD 40
    koopa_yPos DWORD 22
    koopa_dir SDWORD -1
    koopa_leftBound DWORD 30
    koopa_rightBound DWORD 50
    koopa_state BYTE 0       
    koopa_active BYTE 0          
    
    ; ===== BOWSER (BOSS) =====
    bowser_xPos DWORD 70
    bowser_yPos DWORD 21         
    bowser_dir SDWORD -1         
    bowser_leftBound DWORD 65
    bowser_rightBound DWORD 75
    bowser_active BYTE 0 
    bowser_health DWORD 3        
    AXE_X DWORD 78            
    AXE_Y DWORD 20
    BRIDGE_START_X DWORD 60
    BRIDGE_LENGTH DWORD 15
    
    ; ===== LEVEL MANAGEMENT =====
    currentLevel BYTE 1   
    currentLevelScreen BYTE 0    
    
    ; ===== LEVEL CONSTANTS =====
    GROUND_LEVEL DWORD 22
    FLAGPOLE_X DWORD 75         
    FLAGPOLE_HEIGHT DWORD 18    
    FLAGPOLE_BASE_Y DWORD 22    
    FLAG_INITIAL_Y DWORD 5      
    TIME_BONUS_MULTIPLIER DWORD 50  
    PIPE1_X DWORD 30
    PIPE1_WIDTH DWORD 3
    PIPE1_HEIGHT DWORD 4
    PIPE2_X DWORD 60
    PIPE2_WIDTH DWORD 3
    PIPE2_HEIGHT DWORD 5
    QBLOCK1_X DWORD 20
    QBLOCK1_Y DWORD 15
    QBLOCK2_X DWORD 24
    QBLOCK2_Y DWORD 15
    QBLOCK3_X DWORD 40
    QBLOCK3_Y DWORD 12
    BRICK1_X DWORD 45
    BRICK1_Y DWORD 15
    BRICK2_X DWORD 46
    BRICK2_Y DWORD 15
    BRICK3_X DWORD 47
    BRICK3_Y DWORD 15
    PLATFORM_X DWORD 50
    PLATFORM_Y DWORD 18
    PLATFORM_WIDTH DWORD 5
    
    ; ===== PLAYER STATE FLAGS =====
    isJumping BYTE 1
    inputChar BYTE 0
    gameRunning BYTE 1
    gameState BYTE 0
    gamePaused BYTE 0        
    levelComplete BYTE 0     
    flagY DWORD 5            
    flagDescending BYTE 0    
    
    ; ===== DRAWING STATE =====
    old_mario_x DWORD 0
    old_mario_y DWORD 0
    old_goomba1_x DWORD 0
    old_goomba1_y DWORD 0
    old_goomba2_x DWORD 0
    old_goomba2_y DWORD 0
    old_koopa_x DWORD 0
    old_koopa_y DWORD 0
    old_powerUp_x DWORD 0
    old_powerUp_y DWORD 0
    isFirstFrame BYTE 1        
    
    ; ===== GAME STATE VARIABLES =====
    score DWORD 0
    lives BYTE 3
    coins BYTE 0
    gameTime DWORD 300
    frameCounter DWORD 0
 
    ; ===== FILE HANDLING VARIABLES =====
    playerName BYTE 11 DUP(0)       
    highScore DWORD 0          
    lastWorld BYTE "1-1", 0, 0       
    fileName BYTE "playerData.txt", 0
    fileHandle DWORD ?
    bytesWritten DWORD ?
    
    fileBuffer BYTE 256 DUP(0)
    namePrompt BYTE "Enter your name (max 10 chars): ", 0
    saveMsg BYTE "Saving game data...", 0
    loadMsg BYTE "Loading player data...", 0
    highScoreLabel BYTE "HIGH SCORE: ", 0
    lastWorldLabel BYTE "LAST WORLD: ", 0
 
    ; ===== FRAME TIMING =====
    frameDelayMs DWORD 33
    
    ; ===== MENU STRINGS =====
    banner1 BYTE " ========================================", 0
    banner2 BYTE "   SUPER MARIO BROS            ", 0
    banner3 BYTE " ========================================", 0
    banner4 BYTE "   Assembly Game Project     ", 0
    banner5 BYTE "   Roll #: 24i-0613        ", 0
    banner6 BYTE " ========================================", 0
    menuTitle BYTE "MAIN MENU ", 0
    menuOpt1 BYTE " 1 - Start Game      ", 0
    menuOpt2 BYTE " 2 - Instructions           ", 0
    menuOpt3 BYTE " 3 - Exit      ", 0
    menuPrompt BYTE "Select an option (1-3), 4 for BOSS LEVEL : ", 0
    instTitle BYTE "  INSTRUCTIONS    ", 0
    inst1 BYTE "  W - Jump           ", 0
    inst2 BYTE "  A - Move Left  ", 0
    inst3 BYTE "  D - Move Right     ", 0
    inst4 BYTE "  X - Exit Game      ", 0
    inst5 BYTE "  P - Pause Game      ", 0
    inst6 BYTE "Jump on Goombas to defeat them!           ", 0
    inst7 BYTE "  Avoid obstacles and collect coins!        ", 0
    inst8 BYTE "  Press any key to return to menu...     ", 0
    
    ; ===== PAUSE MENU STRINGS =====
    pauseTitle BYTE "        GAME PAUSED        ", 0
    pauseOpt1 BYTE "      R - Resume Game  ", 0
    pauseOpt2 BYTE "      X - Exit to Menu       ", 0
    
    ; ===== LEVEL COMPLETE STRINGS =====
    completeTitle BYTE "      LEVEL COMPLETE!       ", 0
    completeMsg1 BYTE "   Congratulations!       ", 0
    completeMsg2 BYTE "   Time Bonus: ", 0
    completeMsg3 BYTE "   Press any key...        ", 0
    thankYouMsg BYTE "Thanks for playing!", 0
    pressKeyMsg BYTE "Press any key to continue...", 0
    
    ; ===== HUD STRINGS =====
    hudMario BYTE "MARIO", 0
    hudCoins BYTE "COINS", 0
    hudWorld BYTE "WORLD 1-1", 0
    hudTime BYTE "TIME", 0
    hudLives BYTE "MARIO x ", 0
    
    ; ===== CASTLE/BOSS LEVEL STRINGS =====
    hudWorldCastle BYTE "WORLD 1-4", 0
    castleMsg BYTE "BOWSER'S CASTLE!", 0
    bossDefeatMsg BYTE "BOWSER DEFEATED!", 0
    princessMsg BYTE "Thank you Mario!", 0

.code
main PROC
    call Clrscr
    call LoadPlayerData
    call ShowWelcomeScreen
    call GetPlayerName
    
mainStateLoop:
    cmp gameRunning, 0
    je exitGame
    mov al, gameState
    cmp al, 0
    je mainStateLoop_Menu
    cmp al, 1
    je mainStateLoop_Playing
    cmp al, 2
    je mainStateLoop_Instructions
    cmp al, 3
    je mainStateLoop_LevelComplete
    mov gameState, 0
    jmp mainStateLoop

mainStateLoop_Menu:
    call ShowMenu
    call GetMenuInput
    jmp mainStateLoop

mainStateLoop_Playing:
    ; Check if game is paused
    cmp gamePaused, 1
    je mainStateLoop_Paused
    
    ; Check if level is complete
    cmp levelComplete, 1
    je mainStateLoop_LevelComplete
    
    call GetInput
    call UpdatePhysics
    call UpdateEnemies
    call UpdateBowser
    call UpdatePowerUps
    call UpdateRainSystem
    call HandleCollisions
    call CheckEnemyCollisions
    call CheckBowserCollision
    call CheckPowerUpCollection
    call CheckBonusStarCollection  ; Level 1 Stars
    
    ; ===== NEW CALL FOR LEVEL 2 LOGIC =====
    call CheckCastleLogic          ; Level 2 Obstacles/Stars
    
    call CheckLevelCompletion
    call CheckCastleComplete
    call UpdateTimer
    call DrawScreen
    call FrameDelay
    jmp mainStateLoop

mainStateLoop_Paused:
    call DrawPauseScreen
    call GetPauseInput
    jmp mainStateLoop

mainStateLoop_LevelComplete:
    call UpdateFlagAnimation
    call DrawScreen
    call DrawLevelCompleteScreen
    call FrameDelay
    ; Check if flag reached bottom
    mov eax, flagY
    cmp eax, 20
    jl mainStateLoop_Playing
    
    ; Flag at bottom
    call UpdateHighScore
    call SavePlayerData
    
    ; Check which level just completed
    mov al, currentLevel
    cmp al, 1
    je mainStateLoop_LoadCastle
    cmp al, 2
    je mainStateLoop_GameWon
    
mainStateLoop_LoadCastle:
    ; Transition to Castle/Boss Level
    call WaitForKey
    call LoadCastleLevel
    mov gameState, 1  ; Resume playing
    jmp mainStateLoop
    
mainStateLoop_GameWon:
    ; Both levels complete
    call WaitForKey
    mov gameState, 0  ; Return to menu
    jmp mainStateLoop

mainStateLoop_Instructions:
    call ShowInstructions
    call WaitForKey
    mov gameState, 0
    jmp mainStateLoop

exitGame:
    call SavePlayerData
    call Clrscr
    mov dh, 12
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET banner2
    call WriteString
    mov dh, 14
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET thankYouMsg
    call WriteString
    call Crlf
    call WaitMsg
    exit
main ENDP

; =============================================================
; LEVEL 2 LOGIC AND DRAWING (UPDATED)
; =============================================================

DrawCastleLevel PROC
    push eax
    push ebx
    push ecx
    push edx
    
    ; 1. Draw Floor
    mov eax, GROUND_LEVEL
    add eax, 1
    mov dh, al
    mov dl, 0
    call Gotoxy
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov ecx, 80
    mov al, '#'
DrawCastleFloor_Loop:
    call WriteChar
    loop DrawCastleFloor_Loop
    
    ; 2. Draw Lava
    mov eax, lightRed + (red * 16)
    call SetTextColor
    mov dh, 24
    mov dl, 10
    call Gotoxy
    mov ecx, 20
    mov al, '~'
DrawLava1_Loop:
    call WriteChar
    loop DrawLava1_Loop
    
    mov dh, 24
    mov dl, 40
    call Gotoxy
    mov ecx, 15
    mov al, '~'
DrawLava2_Loop:
    call WriteChar
    loop DrawLava2_Loop
    
    ; 3. Draw Bridge
    mov eax, brown + (black * 16)
    call SetTextColor
    mov eax, GROUND_LEVEL
    mov dh, al
    mov dl, BYTE PTR BRIDGE_START_X
    call Gotoxy
    mov ecx, BRIDGE_LENGTH
    mov al, '='
DrawBridge_Loop:
    call WriteChar
    loop DrawBridge_Loop

    ; ==========================================
    ; 4. Draw Obstacles (Grey Pillars)
    ; ==========================================
    mov eax, lightGray + (black * 16)
    call SetTextColor

    ; Draw Obstacle 1
    mov ecx, c_obst1_height
    mov ebx, GROUND_LEVEL
    sub ebx, 1 ; Start from ground up
DrawObst1_Loop:
    mov dh, bl
    mov dl, byte ptr c_obst1_x
    call Gotoxy
    mov al, 178 ; Block character
    call WriteChar
    dec bl
    loop DrawObst1_Loop

    ; Draw Obstacle 2
    mov ecx, c_obst2_height
    mov ebx, GROUND_LEVEL
    sub ebx, 1
DrawObst2_Loop:
    mov dh, bl
    mov dl, byte ptr c_obst2_x
    call Gotoxy
    mov al, 178
    call WriteChar
    dec bl
    loop DrawObst2_Loop

    ; ==========================================
    ; 5. Draw Stars (Yellow)
    ; ==========================================
    mov eax, yellow + (black * 16)
    call SetTextColor

    ; Star 1
    cmp c_star1_active, 1
    jne DrawCStar2
    mov dh, byte ptr c_star1_y
    mov dl, byte ptr c_star1_x
    call Gotoxy
    mov al, '*'
    call WriteChar

DrawCStar2:
    ; Star 2
    cmp c_star2_active, 1
    jne DrawCastleItems_Axe
    mov dh, byte ptr c_star2_y
    mov dl, byte ptr c_star2_x
    call Gotoxy
    mov al, '*'
    call WriteChar
    
DrawCastleItems_Axe:
    ; Draw axe (goal)
    cmp bowser_active, 0
    jne DrawCastleLevel_Done
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, BYTE PTR AXE_Y
    mov dl, BYTE PTR AXE_X
    call Gotoxy
    mov al, '^'
    call WriteChar

DrawCastleLevel_Done:
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawCastleLevel ENDP

CheckCastleLogic PROC
    push eax
    push ebx
    push ecx
    push edx

    mov al, currentLevel
    cmp al, 2
    jne CastleLogic_Done

    ; ============================
    ; 1. STAR COLLECTION (+20 PTS)
    ; ============================
    
    cmp c_star1_active, 1
    jne CheckCStarLogic2
    mov eax, mario_xPos
    cmp eax, c_star1_x
    jne CheckCStarLogic2
    mov eax, mario_yPos
    cmp eax, c_star1_y
    jg CheckCStarLogic2       
    mov ebx, c_star1_y
    sub ebx, 2           
    cmp eax, ebx
    jl CheckCStarLogic2
    
    mov c_star1_active, 0
    add score, 20
    
    ; *** ADDED: INCREMENT COINS ***
    mov al, coins
    inc al
    mov coins, al
    
    INVOKE Beep, 1000, 50

CheckCStarLogic2:
    cmp c_star2_active, 1
    jne CheckObstacles
    mov eax, mario_xPos
    cmp eax, c_star2_x
    jne CheckObstacles
    mov eax, mario_yPos
    cmp eax, c_star2_y
    jg CheckObstacles
    mov ebx, c_star2_y
    sub ebx, 2
    cmp eax, ebx
    jl CheckObstacles

    mov c_star2_active, 0
    add score, 20

    ; *** ADDED: INCREMENT COINS ***
    mov al, coins
    inc al
    mov coins, al
    
    INVOKE Beep, 1000, 50

    ; ============================
    ; 2. OBSTACLE COLLISION
    ; ============================
CheckObstacles:
    
    mov eax, mario_xPos
    cmp eax, c_obst1_x
    jne CheckObstacleLogic2
    
    mov eax, mario_yPos
    mov ebx, GROUND_LEVEL
    sub ebx, c_obst1_height 
    cmp eax, ebx
    jl CheckObstacleLogic2       
    
    mov eax, mario_xVel
    sub mario_xPos, eax     
    jmp CastleLogic_Done

CheckObstacleLogic2:
    mov eax, mario_xPos
    cmp eax, c_obst2_x
    jne CastleLogic_Done
    
    mov eax, mario_yPos
    mov ebx, GROUND_LEVEL
    sub ebx, c_obst2_height
    cmp eax, ebx
    jl CastleLogic_Done
    
    mov eax, mario_xVel
    sub mario_xPos, eax

CastleLogic_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckCastleLogic ENDP

LoadCastleLevel PROC
    push eax
    mov currentLevel, 2
    mov mario_xPos, 10
    mov mario_yPos, 20
    mov mario_xVel, 0
    mov mario_yVel, 0
    mov isJumping, 1
    mov levelComplete, 0
    mov flagY, 5
    mov flagDescending, 0
    mov isFirstFrame, 1
    mov goomba1_active, 0
    mov goomba2_active, 0
    mov bowser_active, 1
    mov bowser_xPos, 70
    mov bowser_dir, -1
    mov bowser_health, 3
    mov rainActive, 0
    mov gameTime, 300
    
    ; Reset Level 2 Items
    mov c_star1_active, 1
    mov c_star2_active, 1
    
    pop eax
    ret
LoadCastleLevel ENDP

; =============================================================
; MISSING PROCEDURES (ADDED TO FIX ERRORS)
; =============================================================

FrameDelay PROC
    mov eax, frameDelayMs
    call Delay
    ret
FrameDelay ENDP

UpdateTimer PROC
    push eax
    inc frameCounter
    cmp frameCounter, 30
    jl UpdateTimer_Done
    
    mov frameCounter, 0
    cmp gameTime, 0
    je UpdateTimer_Done
    dec gameTime
    
UpdateTimer_Done:
    pop eax
    ret
UpdateTimer ENDP

CheckPipeCollisions PROC
    push eax
    push ebx
    push ecx
    
    mov al, currentLevel
    cmp al, 1
    jne CheckPipeCollisions_Done
    mov al, currentLevelScreen
    cmp al, 0
    jne CheckPipeCollisions_Done

    ; Check Pipe 1 
    mov eax, mario_xPos
    cmp eax, PIPE1_X
    jl CheckPipeCollisions_Check2
    mov ebx, PIPE1_X
    add ebx, PIPE1_WIDTH
    cmp eax, ebx
    jg CheckPipeCollisions_Check2
    
    mov eax, mario_yPos
    mov ebx, GROUND_LEVEL
    sub ebx, PIPE1_HEIGHT
    cmp eax, ebx
    jl CheckPipeCollisions_Check2 
    
    mov eax, mario_xVel
    sub mario_xPos, eax
    jmp CheckPipeCollisions_Done

CheckPipeCollisions_Check2:
    ; Check Pipe 2
    mov eax, mario_xPos
    cmp eax, PIPE2_X
    jl CheckPipeCollisions_Done
    mov ebx, PIPE2_X
    add ebx, PIPE2_WIDTH
    cmp eax, ebx
    jg CheckPipeCollisions_Done
    
    mov eax, mario_yPos
    mov ebx, GROUND_LEVEL
    sub ebx, PIPE2_HEIGHT
    cmp eax, ebx
    jl CheckPipeCollisions_Done
    
    mov eax, mario_xVel
    sub mario_xPos, eax

CheckPipeCollisions_Done:
    pop ecx
    pop ebx
    pop eax
    ret
CheckPipeCollisions ENDP

CheckPlatformLanding PROC
    push eax
    push ebx
    push ecx
    
    mov eax, mario_yVel
    cmp eax, 0
    jl CheckPlatformLanding_Done
    
    mov al, currentLevel
    cmp al, 1
    jne CheckPlatformLanding_Done

    mov ecx, PLATFORM_X     
    mov ebx, PLATFORM_Y
    
    mov al, currentLevelScreen
    cmp al, 1
    jne CheckPlatformLanding_Calc
    mov ecx, 38
    mov ebx, 19
    
CheckPlatformLanding_Calc:
    mov eax, mario_yPos
    cmp eax, ebx
    jne CheckPlatformLanding_Done
    
    mov eax, mario_xPos
    cmp eax, ecx
    jl CheckPlatformLanding_Done
    add ecx, 6 
    cmp eax, ecx
    jg CheckPlatformLanding_Done
    
    mov mario_yVel, 0
    mov isJumping, 0
    
CheckPlatformLanding_Done:
    pop ecx
    pop ebx
    pop eax
    ret
CheckPlatformLanding ENDP

SpawnPowerUp PROC
    push eax
    mov eax, mario_xPos
    mov powerUp_xPos, eax
    mov eax, mario_yPos
    sub eax, 4
    mov powerUp_yPos, eax
    mov powerUp_active, 1
    push eax
    push ecx
    push edx
    INVOKE Beep, 1000, 50
    pop edx
    pop ecx
    pop eax
    pop eax
    ret
SpawnPowerUp ENDP

DrawPowerUp PROC
    push eax
    push edx
    cmp powerUp_active, 0
    je DrawPowerUp_Done
    mov dh, byte ptr powerUp_yPos
    mov dl, byte ptr powerUp_xPos
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov al, 'P'
    call WriteChar
    mov eax, white + (black * 16)
    call SetTextColor
DrawPowerUp_Done:
    pop edx
    pop eax
    ret
DrawPowerUp ENDP

CheckPowerUpCollection PROC
    push eax
    push ebx
    cmp powerUp_active, 0
    je CheckPowerUpCollection_Done
    mov eax, mario_xPos
    cmp eax, powerUp_xPos
    jne CheckPowerUpCollection_Done
    mov eax, mario_yPos
    cmp eax, powerUp_yPos
    jne CheckPowerUpCollection_Done
    mov powerUp_active, 0
    mov mario_state, 1 
    add score, 1000
    push eax
    push ecx
    push edx
    INVOKE Beep, 1500, 200
    pop edx
    pop ecx
    pop eax
CheckPowerUpCollection_Done:
    pop ebx
    pop eax
    ret
CheckPowerUpCollection ENDP

UpdateOldPositions PROC
    push eax
    mov eax, mario_xPos
    mov old_mario_x, eax
    mov eax, mario_yPos
    mov old_mario_y, eax
    mov eax, goomba1_xPos
    mov old_goomba1_x, eax
    mov eax, goomba1_yPos
    mov old_goomba1_y, eax
    mov eax, goomba2_xPos
    mov old_goomba2_x, eax
    mov eax, goomba2_yPos
    mov old_goomba2_y, eax
    mov eax, koopa_xPos
    mov old_koopa_x, eax
    mov eax, koopa_yPos
    mov old_koopa_y, eax
    mov eax, powerUp_xPos
    mov old_powerUp_x, eax
    mov eax, powerUp_yPos
    mov old_powerUp_y, eax
    pop eax
    ret
UpdateOldPositions ENDP

ClearOldSprites PROC
    push eax
    push edx
    mov dh, byte ptr old_mario_y
    mov dl, byte ptr old_mario_x
    call Gotoxy
    mov al, ' '
    call WriteChar
    mov eax, old_mario_y
    dec eax
    mov dh, al
    mov dl, byte ptr old_mario_x
    call Gotoxy
    mov al, ' '
    call WriteChar
    mov dh, byte ptr old_goomba1_y
    mov dl, byte ptr old_goomba1_x
    call Gotoxy
    mov al, ' '
    call WriteChar
    mov dh, byte ptr old_goomba2_y
    mov dl, byte ptr old_goomba2_x
    call Gotoxy
    mov al, ' '
    call WriteChar
    mov dh, byte ptr old_koopa_y
    mov dl, byte ptr old_koopa_x
    call Gotoxy
    mov al, ' '
    call WriteChar
    cmp powerUp_active, 1
    jne ClearOldSprites_Done
    mov dh, byte ptr old_powerUp_y
    mov dl, byte ptr old_powerUp_x
    call Gotoxy
    mov al, ' '
    call WriteChar
ClearOldSprites_Done:
    pop edx
    pop eax
    ret
ClearOldSprites ENDP
UpdateHUDNumbers PROC
    push eax
    push edx
    
    ; Update Score (Existing Logic)
    mov dh, 1
    mov dl, 2
    call Gotoxy
    mov eax, score
    call WriteScorePadded
    
    ; Update Coins (Existing Logic)
    mov dh, 1
    mov dl, 21
    call Gotoxy
    movzx eax, coins
    call WriteCoinsPadded
    
    ; Update Time (Existing Logic)
    mov dh, 1
    mov dl, 56
    call Gotoxy
    mov eax, gameTime
    call WriteDec
    mov al, ' '
    call WriteChar

    ; =========================================
    ; *** NEW LOGIC TO UPDATE LIVES COUNT ***
    ; =========================================
    ; Go to position where the number for lives is printed (near MARIO x )
    mov dh, 0
    mov dl, 77   ; Assuming 'MARIO x ' starts at 70 (8 chars) + 7
    call Gotoxy

    ; Use light red color temporarily to make sure the digit stands out
    mov eax, lightRed + (black * 16)
    call SetTextColor 
    
    ; Print the decimal value of the lives variable
    movzx eax, lives
    call WriteDec
    
    ; Clear any trailing digits in case lives went from 10+ to single digit
    mov al, ' '
    call WriteChar 
    
    ; Reset color to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; =========================================
    
    pop edx
    pop eax
    ret
UpdateHUDNumbers ENDP

WriteScorePadded PROC
    push eax
    push ecx
    push edx
    cmp eax, 10
    jae WS_2
    mov al, '0'
    call WriteChar
WS_2:
    cmp eax, 100
    jae WS_3
    mov al, '0'
    call WriteChar
WS_3:
    cmp eax, 1000
    jae WS_4
    mov al, '0'
    call WriteChar
WS_4:
    cmp eax, 10000
    jae WS_5
    mov al, '0'
    call WriteChar
WS_5:
    cmp eax, 100000
    jae WS_Print
    mov al, '0'
    call WriteChar
WS_Print:
    pop edx 
    push edx
    call WriteDec
    pop edx
    pop ecx
    pop eax
    ret
WriteScorePadded ENDP

WriteCoinsPadded PROC
    push eax
    cmp eax, 10
    jae WC_Print
    push eax
    mov al, '0'
    call WriteChar
    pop eax
WC_Print:
    call WriteDec
    pop eax
    ret
WriteCoinsPadded ENDP

; =============================================================
; EXISTING PROCEDURES (Unchanged logic)
; =============================================================

ShowWelcomeScreen PROC
    push eax
    push edx
    call Clrscr
    mov eax, yellow + (blue * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET banner1
    call WriteString
    mov dh, 6
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET banner2
    call WriteString
    mov dh, 7
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET banner3
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 9
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET banner4
    call WriteString
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET banner5
    call WriteString
    mov dh, 11
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET banner6
    call WriteString
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 13
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET highScoreLabel
    call WriteString
    mov eax, highScore
    call WriteDec
    mov dh, 14
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET lastWorldLabel
    call WriteString
    mov edx, OFFSET lastWorld
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 17
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    mov gameState, 0
    pop edx
    pop eax
    ret
ShowWelcomeScreen ENDP

GetPlayerName PROC
    push eax
    push ecx
    push edx
    call Clrscr
    mov eax, lightCyan + (black * 16)
    call SetTextColor
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET namePrompt
    call WriteString
    mov edx, OFFSET playerName
    mov ecx, 10 
    call ReadString
    mov eax, white + (black * 16)
    call SetTextColor
    pop edx
    pop ecx
    pop eax
    ret
GetPlayerName ENDP

ShowMenu PROC
    push eax
    push edx
    call Clrscr
    mov eax, lightCyan + (black * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET menuTitle
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET menuOpt1
    call WriteString
    mov dh, 9
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET menuOpt2
    call WriteString
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET menuOpt3
    call WriteString
    mov dh, 13
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET menuPrompt
    call WriteString
    pop edx
    pop eax
    ret
ShowMenu ENDP

GetMenuInput PROC
    push eax
    push edx
    
GetMenuInput_WaitKey:
    call ReadChar
    jz GetMenuInput_WaitKey
    
    cmp al, '1'
    je GetMenuInput_StartGame
    cmp al, '2'
    je GetMenuInput_ShowInst
    cmp al, '3'
    je GetMenuInput_Exit
    
    ; ===== CHEAT KEY '4' =====
    cmp al, '4'
    je GetMenuInput_StartCastle
    
    jmp GetMenuInput_WaitKey

GetMenuInput_StartGame:
    mov mario_xPos, 20
    mov mario_yPos, 20
    mov mario_xVel, 0
    mov mario_yVel, 0
    mov isJumping, 1
    mov mario_state, 0
    mov gamePaused, 0
    mov levelComplete, 0
    mov flagY, 5
    mov flagDescending, 0
    mov score, 0
    mov lives, 3
    mov coins, 0
    mov gameTime, 300
    mov frameCounter, 0
    mov isTurbo, 0
    mov turboTimer, 0
    mov isFirstFrame, 1
    mov currentLevel, 1
    mov currentLevelScreen, 0
    mov rainActive, 1
    call InitRainSystem
    mov qblock1_hit, 0
    mov qblock2_hit, 0
    mov qblock3_hit, 0
    mov powerUp_active, 0
    mov goomba1_xPos, 40
    mov goomba1_dir, 1
    mov goomba1_active, 1
    mov goomba2_xPos, 65
    mov goomba2_dir, 1
    mov goomba2_active, 1
    mov koopa_active, 0
    mov bowser_active, 0
    mov star1_active, 1
    mov star2_active, 1
    mov star3_active, 1
    mov gameState, 1
    jmp GetMenuInput_Done

GetMenuInput_StartCastle:
    mov score, 0
    mov lives, 3
    mov coins, 0
    mov gameTime, 300
    mov frameCounter, 0
    mov isTurbo, 0
    mov turboTimer, 0
    call LoadCastleLevel
    mov gameState, 1
    jmp GetMenuInput_Done

GetMenuInput_ShowInst:
    mov gameState, 2
    jmp GetMenuInput_Done

GetMenuInput_Exit:
    mov gameRunning, 0

GetMenuInput_Done:
    pop edx
    pop eax
    ret
GetMenuInput ENDP

ShowInstructions PROC
    push eax
    push edx
    call Clrscr
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov dh, 4
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET instTitle
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 7
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst1
    call WriteString
    mov dh, 8
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst2
    call WriteString
    mov dh, 9
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst3
    call WriteString
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst4
    call WriteString
    mov dh, 11
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst5
    call WriteString
    mov dh, 12
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst6
    call WriteString
    mov dh, 13
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst7
    call WriteString
    mov dh, 16
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET inst8
    call WriteString
    pop edx
    pop eax
    ret
ShowInstructions ENDP

WaitForKey PROC
    push eax
WaitForKey_Loop:
    call ReadChar
    jz WaitForKey_Loop
    pop eax
    ret
WaitForKey ENDP

DrawPauseScreen PROC
    push eax
    push edx
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 10
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET banner1
    call WriteString
    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET pauseTitle
    call WriteString
    mov dh, 12
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET banner1
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 27
    call Gotoxy
    mov edx, OFFSET pauseOpt1
    call WriteString
    mov dh, 15
    mov dl, 27
    call Gotoxy
    mov edx, OFFSET pauseOpt2
    call WriteString
    pop edx
    pop eax
    ret
DrawPauseScreen ENDP

DrawLevelCompleteScreen PROC
    push eax
    push ebx
    push ecx
    push edx
    mov eax, flagY
    cmp eax, 20
    jl DrawLevelCompleteScreen_Done
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET banner1
    call WriteString
    mov dh, 9
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET completeTitle
    call WriteString
    mov dh, 10
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET banner1
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 12
    mov dl, 27
    call Gotoxy
    mov edx, OFFSET completeMsg1
    call WriteString
    mov dh, 14
    mov dl, 27
    call Gotoxy
    mov edx, OFFSET completeMsg2
    call WriteString
    mov eax, gameTime
    mov ebx, TIME_BONUS_MULTIPLIER
    mul ebx
    call WriteDec
    mov dh, 16
    mov dl, 27
    call Gotoxy
    mov edx, OFFSET completeMsg3
    call WriteString
DrawLevelCompleteScreen_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawLevelCompleteScreen ENDP

GetPauseInput PROC
    push eax
GetPauseInput_WaitKey:
    call ReadChar
    jz GetPauseInput_WaitKey
    cmp al, 'r'
    je GetPauseInput_Resume
    cmp al, 'R'
    je GetPauseInput_Resume
    cmp al, 'x'
    je GetPauseInput_Exit
    cmp al, 'X'
    je GetPauseInput_Exit
    jmp GetPauseInput_WaitKey
GetPauseInput_Resume:
    mov gamePaused, 0
    jmp GetPauseInput_Done
GetPauseInput_Exit:
    mov gamePaused, 0
    mov gameState, 0
GetPauseInput_Done:
    pop eax
    ret
GetPauseInput ENDP

GetInput PROC
    push eax
    push edx
    call ReadKey
    jz GetInput_End
    mov inputChar, al
    cmp al, 'x'
    je GetInput_Exit
    cmp al, 'X'
    je GetInput_Exit
    cmp al, 'p'
    je GetInput_Pause
    cmp al, 'P'
    je GetInput_Pause
    cmp al, 'd'
    je GetInput_MoveRight
    cmp al, 'D'
    je GetInput_MoveRight
    cmp al, 'a'
    je GetInput_MoveLeft
    cmp al, 'A'
    je GetInput_MoveLeft
    cmp al, 'w'
    je GetInput_Jump
    cmp al, 'W'
    je GetInput_Jump
    cmp al, 27 
    je GetInput_ToMenu
    jmp GetInput_End
GetInput_ToMenu:
    mov gameState, 0
    jmp GetInput_End
GetInput_Exit:
    mov gameRunning, 0
    jmp GetInput_End
GetInput_Pause:
    mov gamePaused, 1
    jmp GetInput_End
GetInput_MoveRight:
    mov eax, mario_xVel
    cmp eax, MAX_X_SPEED
    jge GetInput_End
    add eax, ACCEL_AMOUNT
    mov mario_xVel, eax
    jmp GetInput_End
GetInput_MoveLeft:
    mov eax, mario_xVel
    mov edx, MAX_X_SPEED
    neg edx
    cmp eax, edx
    jle GetInput_End
    sub eax, ACCEL_AMOUNT
    mov mario_xVel, eax
    jmp GetInput_End
GetInput_Jump:
    cmp isJumping, 0
    jne GetInput_End
    mov eax, JUMP_STRENGTH
    mov mario_yVel, eax
    mov isJumping, 1
    push eax
    push ecx
    push edx
    INVOKE Beep, 600, 50
    pop edx
    pop ecx
    pop eax
GetInput_End:
    pop edx
    pop eax
    ret
GetInput ENDP

UpdatePhysics PROC
    push eax
    push ebx
    push ecx
    push edx
    mov eax, mario_yVel
    add eax, GRAVITY_ACCEL
    mov mario_yVel, eax
    mov edx, MAX_Y_SPEED
    neg edx
    cmp eax, edx
    jge UpdatePhysics_CapFallSpeed
    mov eax, edx
    mov mario_yVel, eax
    jmp UpdatePhysics_GravityDone
UpdatePhysics_CapFallSpeed:
    cmp eax, MAX_Y_SPEED
    jle UpdatePhysics_GravityDone
    mov eax, MAX_Y_SPEED
    mov mario_yVel, eax
UpdatePhysics_GravityDone:
    mov eax, mario_xVel
    add mario_xPos, eax
    mov eax, mario_yVel
    add mario_yPos, eax
    mov eax, mario_xVel
    cmp eax, 0
    jg UpdatePhysics_FrictionRight
    cmp eax, 0
    jl UpdatePhysics_FrictionLeft
    jmp UpdatePhysics_FrictionDone
UpdatePhysics_FrictionRight:
    sub eax, FRICTION_AMOUNT
    cmp eax, 0
    jge UpdatePhysics_FrictionStore
    mov eax, 0
    jmp UpdatePhysics_FrictionStore
UpdatePhysics_FrictionLeft:
    add eax, FRICTION_AMOUNT
    cmp eax, 0
    jle UpdatePhysics_FrictionStore
    mov eax, 0
UpdatePhysics_FrictionStore:
    mov mario_xVel, eax
UpdatePhysics_FrictionDone:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdatePhysics ENDP

UpdateEnemies PROC
    push eax
    push ebx
    push ecx
    push edx
    cmp goomba1_active, 0
    je UpdateEnemies_Goomba2
    mov eax, goomba1_xPos
    mov ebx, goomba1_dir
    add eax, ebx
    mov ecx, PIPE1_X
    cmp eax, ecx
    jl UpdateEnemies_G1_NoPipeCollision
    add ecx, PIPE1_WIDTH
    cmp eax, ecx
    jge UpdateEnemies_G1_NoPipeCollision
    jmp UpdateEnemies_Goomba1_ReverseDir 
UpdateEnemies_G1_NoPipeCollision:
    mov ecx, PIPE2_X
    cmp eax, ecx
    jl UpdateEnemies_G1_Move
    add ecx, PIPE2_WIDTH
    cmp eax, ecx
    jge UpdateEnemies_G1_Move
    jmp UpdateEnemies_Goomba1_ReverseDir 
UpdateEnemies_G1_Move:
    mov eax, goomba1_xPos
    mov ebx, goomba1_dir
    add eax, ebx
    mov goomba1_xPos, eax
    mov ecx, goomba1_leftBound
    cmp eax, ecx
    jl UpdateEnemies_Goomba1_ReverseDir
    mov ecx, goomba1_rightBound
    cmp eax, ecx
    jg UpdateEnemies_Goomba1_ReverseDir
    jmp UpdateEnemies_Goomba2
UpdateEnemies_Goomba1_ReverseDir:
    mov eax, goomba1_dir
    neg eax
    mov goomba1_dir, eax
UpdateEnemies_Goomba2:
    cmp goomba2_active, 0
    je UpdateEnemies_Koopa
    mov eax, goomba2_xPos
    mov ebx, goomba2_dir
    add eax, ebx
    mov goomba2_xPos, eax
    mov ecx, goomba2_leftBound
    cmp eax, ecx
    jl UpdateEnemies_Goomba2_ReverseDir
    mov ecx, goomba2_rightBound
    cmp eax, ecx
    jg UpdateEnemies_Goomba2_ReverseDir
    jmp UpdateEnemies_Koopa
UpdateEnemies_Goomba2_ReverseDir:
    mov eax, goomba2_dir
    neg eax
    mov goomba2_dir, eax
UpdateEnemies_Koopa:
    mov al, currentLevel
    cmp al, 1
    jne UpdateEnemies_Done
    mov al, currentLevelScreen
    cmp al, 1
    jne UpdateEnemies_Done
    cmp koopa_active, 0
    je UpdateEnemies_Done
    cmp koopa_state, 1
    je UpdateEnemies_Done
    mov eax, koopa_xPos
    mov ebx, koopa_dir
    add eax, ebx
    mov koopa_xPos, eax
    mov ecx, koopa_leftBound
    cmp eax, ecx
    jl UpdateEnemies_KoopaReverseDir
    mov ecx, koopa_rightBound
    cmp eax, ecx
    jg UpdateEnemies_KoopaReverseDir
    jmp UpdateEnemies_Done
UpdateEnemies_KoopaReverseDir:
    mov eax, koopa_dir
    neg eax
    mov koopa_dir, eax
UpdateEnemies_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdateEnemies ENDP

DrawEnemies PROC
    push eax
    push ebx
    push ecx
    push edx
    cmp goomba1_active, 0
    je DrawEnemies_Goomba2
    mov eax, goomba1_yPos
    mov dh, al
    mov eax, goomba1_xPos
    mov dl, al
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov al, 'G'
    call WriteChar
    mov eax, white + (black * 16)
    call SetTextColor
DrawEnemies_Goomba2:
    cmp goomba2_active, 0
    je DrawEnemies_Koopa
    mov eax, goomba2_yPos
    mov dh, al
    mov eax, goomba2_xPos
    mov dl, al
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov al, 'G'
    call WriteChar
    mov eax, white + (black * 16)
    call SetTextColor
DrawEnemies_Koopa:
    mov al, currentLevelScreen
    cmp al, 1
    jne DrawEnemies_Done
    cmp koopa_active, 0
    je DrawEnemies_Done
    mov eax, koopa_yPos
    mov dh, al
    mov eax, koopa_xPos
    mov dl, al
    call Gotoxy
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    cmp koopa_state, 0
    je DrawEnemies_Koopa_Walk
    mov al, 'O'
    call WriteChar
    jmp DrawEnemies_Koopa_Done
DrawEnemies_Koopa_Walk:
    mov al, 'K'
    call WriteChar
DrawEnemies_Koopa_Done:
    mov eax, white + (black * 16)
    call SetTextColor
DrawEnemies_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawEnemies ENDP

UpdateBowser PROC
    push eax
    push ebx
    push ecx
    cmp bowser_active, 0
    je UpdateBowser_Done
    mov eax, bowser_xPos
    mov ebx, bowser_dir
    add eax, ebx
    mov bowser_xPos, eax
    cmp eax, bowser_leftBound
    jl UpdateBowser_Reverse
    cmp eax, bowser_rightBound
    jg UpdateBowser_Reverse
    jmp UpdateBowser_Done
UpdateBowser_Reverse:
    neg bowser_dir
UpdateBowser_Done:
    pop ecx
    pop ebx
    pop eax
    ret
UpdateBowser ENDP

CheckBowserCollision PROC
    push eax
    push ebx
    push ecx
    cmp bowser_active, 0
    je CheckBowserCollision_Done
    mov eax, mario_xPos
    inc eax
    cmp eax, bowser_xPos
    jle CheckBowserCollision_Done
    mov ebx, bowser_xPos
    add ebx, 2  
    mov ecx, mario_xPos
    cmp ecx, ebx
    jge CheckBowserCollision_Done
    mov eax, mario_yVel
    cmp eax, 0
    jle CheckBowserCollision_SideHit
    mov eax, mario_yPos
    mov ebx, bowser_yPos
    sub ebx, 1
    cmp eax, ebx
    jne CheckBowserCollision_SideHit
    dec bowser_health
    mov eax, STOMP_BOUNCE
    mov mario_yVel, eax
    mov eax, score
    add eax, 500  
    mov score, eax
    cmp bowser_health, 0
    jne CheckBowserCollision_Done
    mov bowser_active, 0
    jmp CheckBowserCollision_Done
CheckBowserCollision_SideHit:
    dec lives
    cmp lives, 0
    je CheckBowserCollision_GameOver
    mov mario_xPos, 10
    mov mario_yPos, 20
    mov mario_xVel, 0
    mov mario_yVel, 0
    jmp CheckBowserCollision_Done
CheckBowserCollision_GameOver:
    mov gameState, 0
CheckBowserCollision_Done:
    pop ecx
    pop ebx
    pop eax
    ret
CheckBowserCollision ENDP

DrawBowser PROC
    push eax
    push ebx
    push edx
    
    ; *** ADDED: CHECK LEVEL BEFORE DRAWING ***
    mov al, currentLevel
    cmp al, 2
    jne DrawBowser_Done
    
    cmp bowser_active, 0
    je DrawBowser_Done
    
    ; Set Bowser color (dark red)
    mov eax, lightRed + (black * 16)
    call SetTextColor
    
    ; Draw Bowser (2 units tall)
    ; Top part
    mov eax, bowser_yPos
    dec eax  ; One row above
    mov dh, al
    mov eax, bowser_xPos
    mov dl, al
    call Gotoxy
    mov al, 'B'
    call WriteChar
    
    ; Bottom part
    mov eax, bowser_yPos
    mov dh, al
    mov eax, bowser_xPos
    mov dl, al
    call Gotoxy
    mov al, 'B'
    call WriteChar
    
    ; Draw health indicator
    mov dh, 5
    mov dl, 65
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    
    mov ecx, bowser_health
    cmp ecx, 0
    je DrawBowser_NoHealth
    
DrawBowser_HealthLoop:
    mov al, '='
    call WriteChar
    loop DrawBowser_HealthLoop
    
DrawBowser_NoHealth:
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
DrawBowser_Done:
    pop edx
    pop ebx
    pop eax
    ret
DrawBowser ENDP
CheckCastleComplete PROC
    push eax
    cmp currentLevel, 2
    jne CheckCastleComplete_Done
    cmp bowser_active, 1
    je CheckCastleComplete_Done
    mov eax, mario_xPos
    cmp eax, AXE_X
    jl CheckCastleComplete_Done
    mov levelComplete, 1
    mov flagDescending, 1
CheckCastleComplete_Done:
    pop eax
    ret
CheckCastleComplete ENDP

InitRainSystem PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    mov ecx, RAIN_DROP_COUNT
    mov esi, 0  
InitRainSystem_Loop:
    mov eax, 79
    call RandomRange  
    mov ebx, esi
    shl ebx, 2  
    mov rain_xPos[ebx], eax
    mov eax, 20
    call RandomRange
    add eax, 3  
    mov rain_yPos[ebx], eax
    inc esi
    loop InitRainSystem_Loop
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
InitRainSystem ENDP

UpdateRainSystem PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    cmp rainActive, 0
    je UpdateRainSystem_Done
    inc rainFrameCounter
    mov eax, rainFrameCounter
    test eax, 1 
    jnz UpdateRainSystem_Done
    mov ecx, RAIN_DROP_COUNT
    mov esi, 0
UpdateRainSystem_Loop:
    mov ebx, esi
    shl ebx, 2  
    mov eax, rain_yPos[ebx]
    mov rain_yPos[ebx], eax
    inc eax
    mov rain_yPos[ebx], eax
    cmp eax, 22
    jge UpdateRainSystem_NextDrop
    mov eax, 79
    call RandomRange
    mov rain_xPos[ebx], eax
    mov rain_yPos[ebx], 3 
UpdateRainSystem_NextDrop:
    inc esi
    loop UpdateRainSystem_Loop
UpdateRainSystem_Done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdateRainSystem ENDP

DrawRainSystem PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    cmp rainActive, 0
    je DrawRainSystem_Done
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    mov ecx, RAIN_DROP_COUNT
    mov esi, 0
DrawRainSystem_Loop:
    mov ebx, esi
    shl ebx, 2
    mov eax, rain_yPos[ebx]
    mov dh, al
    mov eax, rain_xPos[ebx]
    mov dl, al
    call Gotoxy
    mov al, '|'  
    call WriteChar
    inc esi
    loop DrawRainSystem_Loop
    mov eax, white + (black * 16)
    call SetTextColor
DrawRainSystem_Done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawRainSystem ENDP

LoadPlayerData PROC
    push eax
    push ebx
    push ecx
    push edx
    mov edx, OFFSET fileName
    call OpenInputFile
    mov fileHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je LoadPlayerData_NoFile
    mov edx, OFFSET fileBuffer
    mov ecx, 256
    call ReadFromFile
    jc LoadPlayerData_CloseFile 
    call ParsePlayerData
LoadPlayerData_CloseFile:
    mov eax, fileHandle
    call CloseFile
    jmp LoadPlayerData_Done
LoadPlayerData_NoFile:
    mov highScore, 0
    mov byte ptr lastWorld, '1'
    mov byte ptr lastWorld+1, '-'
    mov byte ptr lastWorld+2, '1'
    mov byte ptr lastWorld+3, 0
LoadPlayerData_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadPlayerData ENDP

ParsePlayerData PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov esi, OFFSET fileBuffer
    add esi, 8
    mov edi, OFFSET playerName
    mov ecx, 0
ParsePlayerData_Name:
    mov al, [esi]
    cmp al, 10 
    je ParsePlayerData_NameDone
    cmp al, 13 
    je ParsePlayerData_NameDone
    cmp al, 0  
    je ParsePlayerData_NameDone
    cmp ecx, 10
    jge ParsePlayerData_NameDone
    mov [edi], al
    inc esi
    inc edi
    inc ecx
    jmp ParsePlayerData_Name
ParsePlayerData_NameDone:
    mov byte ptr [edi], 0 
    mov esi, OFFSET fileBuffer
ParsePlayerData_FindScore:
    mov al, [esi]
    cmp al, 0
    je ParsePlayerData_Done
    cmp al, 'H'
    jne ParsePlayerData_FindScore_Next
    jmp ParsePlayerData_ParseScore
ParsePlayerData_FindScore_Next:
    inc esi
    jmp ParsePlayerData_FindScore
ParsePlayerData_ParseScore:
    add esi, 11 
    call ParseNumber
    mov highScore, eax
ParsePlayerData_FindLevel:
    mov al, [esi]
    cmp al, 0
    je ParsePlayerData_Done
    cmp al, 'L'
    jne ParsePlayerData_FindLevel_Next
    jmp ParsePlayerData_ParseLevel
ParsePlayerData_FindLevel_Next:
    inc esi
    jmp ParsePlayerData_FindLevel
ParsePlayerData_ParseLevel:
    add esi, 11 
    mov edi, OFFSET lastWorld
    mov ecx, 0
ParsePlayerData_Level:
    mov al, [esi]
    cmp al, 10
    je ParsePlayerData_LevelDone
    cmp al, 13
    je ParsePlayerData_LevelDone
    cmp al, 0
    je ParsePlayerData_LevelDone
    cmp ecx, 4
    jge ParsePlayerData_LevelDone
    mov [edi], al
    inc esi
    inc edi
    inc ecx
    jmp ParsePlayerData_Level
ParsePlayerData_LevelDone:
    mov byte ptr [edi], 0
ParsePlayerData_Done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ParsePlayerData ENDP

SavePlayerData PROC
    push eax
    push ebx
    push ecx
    push edx
    mov edx, OFFSET fileName
    call CreateOutputFile
    mov fileHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je SavePlayerData_Error
    call BuildSaveData
    mov eax, fileHandle
    mov edx, OFFSET fileBuffer
    mov ecx, ebx 
    call WriteToFile
    mov eax, fileHandle
    call CloseFile
SavePlayerData_Error:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
SavePlayerData ENDP

BuildSaveData PROC
    push eax
    push ecx
    push edx
    push esi
    push edi
    mov edi, OFFSET fileBuffer
    mov ebx, 0 
    mov byte ptr [edi], 'P'
    inc edi
    inc ebx
    mov byte ptr [edi], 'l'
    inc edi
    inc ebx
    mov byte ptr [edi], 'a'
    inc edi
    inc ebx
    mov byte ptr [edi], 'y'
    inc edi
    inc ebx
    mov byte ptr [edi], 'e'
    inc edi
    inc ebx
    mov byte ptr [edi], 'r'
    inc edi
    inc ebx
    mov byte ptr [edi], ':'
    inc edi
    inc ebx
    mov byte ptr [edi], ' '
    inc edi
    inc ebx
    mov esi, OFFSET playerName
    call CopyString
    mov byte ptr [edi], 13
    inc edi
    inc ebx
    mov byte ptr [edi], 10
    inc edi
    inc ebx
    mov byte ptr [edi], 'H'
    inc edi
    inc ebx
    mov byte ptr [edi], 'i'
    inc edi
    inc ebx
    mov byte ptr [edi], 'g'
    inc edi
    inc ebx
    mov byte ptr [edi], 'h'
    inc edi
    inc ebx
    mov byte ptr [edi], 'S'
    inc edi
    inc ebx
    mov byte ptr [edi], 'c'
    inc edi
    inc ebx
    mov byte ptr [edi], 'o'
    inc edi
    inc ebx
    mov byte ptr [edi], 'r'
    inc edi
    inc ebx
    mov byte ptr [edi], 'e'
    inc edi
    inc ebx
    mov byte ptr [edi], ':'
    inc edi
    inc ebx
    mov byte ptr [edi], ' '
    inc edi
    inc ebx
    mov eax, highScore
    call NumberToString
    mov byte ptr [edi], 13
    inc edi
    inc ebx
    mov byte ptr [edi], 10
    inc edi
    inc ebx
    mov byte ptr [edi], 'L'
    inc edi
    inc ebx
    mov byte ptr [edi], 'a'
    inc edi
    inc ebx
    mov byte ptr [edi], 's'
    inc edi
    inc ebx
    mov byte ptr [edi], 't'
    inc edi
    inc ebx
    mov byte ptr [edi], 'L'
    inc edi
    inc ebx
    mov byte ptr [edi], 'e'
    inc edi
    inc ebx
    mov byte ptr [edi], 'v'
    inc edi
    inc ebx
    mov byte ptr [edi], 'e'
    inc edi
    inc ebx
    mov byte ptr [edi], 'l'
    inc edi
    inc ebx
    mov byte ptr [edi], ':'
    inc edi
    inc ebx
    mov byte ptr [edi], ' '
    inc edi
    inc ebx
    mov esi, OFFSET lastWorld
    call CopyString
    mov byte ptr [edi], 13
    inc edi
    inc ebx
    mov byte ptr [edi], 10
    inc edi
    inc ebx
    mov byte ptr [edi], 0
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
BuildSaveData ENDP

CopyString PROC
    push eax
    CopyString_Loop:
    mov al, [esi]
    cmp al, 0
    je CopyString_Done
    mov [edi], al
    inc esi
    inc edi
    inc ebx
    jmp CopyString_Loop
CopyString_Done:
    pop eax
    ret
CopyString ENDP

NumberToString PROC
    push eax
    push ecx
    push edx
    push esi
    mov ecx, 0 
    mov esi, eax 
    cmp eax, 0
    jne NumberToString_CountDigits
    mov byte ptr [edi], '0'
    inc edi
    inc ebx
    jmp NumberToString_Done
NumberToString_CountDigits:
    cmp eax, 0
    je NumberToString_WriteDigits
    push edx
    mov edx, 0
    mov esi, 10
    div esi 
    push edx 
    inc ecx
    jmp NumberToString_CountDigits
NumberToString_WriteDigits:
    cmp ecx, 0
    je NumberToString_Done
    pop eax 
    add al, '0'
    mov [edi], al
    inc edi
    inc ebx
    dec ecx
    jmp NumberToString_WriteDigits
NumberToString_Done:
    pop esi
    pop edx
    pop ecx
    pop eax
    ret
NumberToString ENDP

UpdateHighScore PROC
    push eax
    mov eax, score
    cmp eax, highScore
    jle UpdateHighScore_Done
    mov highScore, eax
UpdateHighScore_Done:
    pop eax
    ret
UpdateHighScore ENDP

DrawMario PROC
    push eax
    push ebx
    push ecx
    push edx
    mov eax, mario_yPos
    mov dh, al
    mov eax, mario_xPos
    mov dl, al
    mov al, mario_state
    cmp al, 0
    je DrawMario_Small
    cmp al, 1
    je DrawMario_Super
    jmp DrawMario_Small 
 DrawMario_Small:
    call Gotoxy
    mov eax, white + (black * 16)
    call SetTextColor
    mov al, 'M'
    call WriteChar
    jmp DrawMario_Done
DrawMario_Super:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov eax, mario_yPos
    dec eax 
    cmp eax, 3 
    jl DrawMario_Super_Bottom
    mov dh, al
    mov eax, mario_xPos
    mov dl, al
    call Gotoxy
    mov al, 'M'
    call WriteChar
DrawMario_Super_Bottom:
    mov eax, mario_yPos
    mov dh, al
    mov eax, mario_xPos
    mov dl, al
    call Gotoxy
    mov al, 'M'
    call WriteChar
    jmp DrawMario_Done
DrawMario_Done:
    mov eax, white + (black * 16)
    call SetTextColor
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawMario ENDP

DrawScreen PROC
    push eax
    push ebx
    push ecx
    push edx
    cmp isFirstFrame, 1
    je DrawScreen_InitialDraw
    call ClearOldSprites
    call UpdateHUDNumbers
    jmp DrawScreen_DrawMoving
DrawScreen_InitialDraw:
    call Clrscr
    call DrawHUD
    mov al, currentLevel
    cmp al, 2
    je DrawScreen_DrawCastle
    call DrawGround
    call DrawPipes
    call DrawBlocks
    call DrawPlatform
    call DrawFlagpole
    call DrawBonusStars        ; Level 1 Stars
    jmp DrawScreen_InitDone
DrawScreen_DrawCastle:
    call DrawCastleLevel
DrawScreen_InitDone:
    mov isFirstFrame, 0       
DrawScreen_DrawMoving:
    call DrawEnemies
    call DrawBowser
    call DrawPowerUp
    call DrawBonusStars        ; Keep Level 1 Stars blinking if not collected
    call DrawMario
    call DrawRainSystem        
    call UpdateOldPositions
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawScreen ENDP

DrawHUD PROC
    push eax
    push edx
    mov dh, 0
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET hudMario
    call WriteString
    mov dh, 1
    mov dl, 2
    call Gotoxy
    mov eax, score
    call WriteScorePadded
    mov dh, 0
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET hudCoins
    call WriteString
    mov dh, 1
    mov dl, 21
    call Gotoxy
    movzx eax, coins
    call WriteCoinsPadded
    mov dh, 0
    mov dl, 35
    call Gotoxy
    mov al, currentLevel
    cmp al, 2
    je DrawHUD_Castle
    mov edx, OFFSET hudWorld
    jmp DrawHUD_WriteWorld
DrawHUD_Castle:
    mov edx, OFFSET hudWorldCastle
DrawHUD_WriteWorld:
    call WriteString
    mov dh, 0
    mov dl, 55
    call Gotoxy
    cmp isTurbo, 0
    je DrawHUD_NormalTime
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    jmp DrawHUD_WriteTime
DrawHUD_NormalTime:
    mov eax, white + (black * 16)
    call SetTextColor
DrawHUD_WriteTime:
    mov edx, OFFSET hudTime
    call WriteString
    mov dh, 1
    mov dl, 56
    call Gotoxy
    mov eax, gameTime
    call WriteDec
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 0
    mov dl, 70
    call Gotoxy
    mov edx, OFFSET hudLives
    call WriteString
    movzx eax, lives
    call WriteDec
    mov dh, 2
    mov dl, 0
    call Gotoxy
    mov ecx, 80
    mov al, '-'
DrawSeparator_Loop:
    call WriteChar
    loop DrawSeparator_Loop
    pop edx
    pop eax
    ret
DrawHUD ENDP

ParseNumber PROC
    push ebx
    push ecx
    push edx
    mov eax, 0
    mov ebx, 10
ParseNumber_Loop:
    movzx ecx, byte ptr [esi]
    cmp cl, '0'
    jb ParseNumber_Done
    cmp cl, '9'
    ja ParseNumber_Done
    sub cl, '0'
    mul ebx
    add eax, ecx
    inc esi
    jmp ParseNumber_Loop
ParseNumber_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ParseNumber ENDP

UpdatePowerUps PROC
    push eax
    push ebx
    push ecx
    push edx
    cmp powerUp_active, 0
    je UpdatePowerUps_Done
    mov eax, powerUp_xPos
    add eax, POWERUP_SPEED
    mov powerUp_xPos, eax
    cmp eax, 78
    jg UpdatePowerUps_Deactivate
    mov eax, powerUp_yPos
    cmp eax, GROUND_LEVEL
    jge UpdatePowerUps_OnGround
    inc eax
    mov powerUp_yPos, eax
    jmp UpdatePowerUps_Done
UpdatePowerUps_OnGround:
    mov eax, GROUND_LEVEL
    mov powerUp_yPos, eax
    jmp UpdatePowerUps_Done
UpdatePowerUps_Deactivate:
    mov powerUp_active, 0
UpdatePowerUps_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdatePowerUps ENDP

HandleCollisions PROC
    push eax
    push ebx
    push ecx
    push edx
    mov eax, mario_yPos
    cmp eax, GROUND_LEVEL
    jl HandleCollisions_InAir
HandleCollisions_OnGround:
    mov eax, GROUND_LEVEL
    mov mario_yPos, eax
    mov mario_yVel, 0
    mov isJumping, 0
    call CheckPipeCollisions
    jmp HandleCollisions_Done
HandleCollisions_InAir:
    mov isJumping, 1
    call CheckHeadBonk
    call CheckPlatformLanding
HandleCollisions_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
HandleCollisions ENDP

CheckEnemyCollisions PROC
    push eax
    push ebx
    push ecx
    push edx
    cmp goomba1_active, 0
    je CheckEnemyCollisions_Goomba2
    mov eax, mario_xPos
    inc eax
    cmp eax, goomba1_xPos
    jle CheckEnemyCollisions_Goomba2
    mov ebx, goomba1_xPos
    add ebx, 2
    mov ecx, mario_xPos
    cmp ecx, ebx
    jge CheckEnemyCollisions_Goomba2
    mov eax, mario_yVel
    cmp eax, 0
    jle CheckEnemyCollisions_G1_SideHit 
    mov eax, mario_yPos     
    mov ebx, goomba1_yPos   
    sub ebx, 1              
    cmp eax, ebx
    jg CheckEnemyCollisions_G1_SideHit   
    mov goomba1_active, 0
    mov eax, score
    add eax, STOMP_SCORE
    mov score, eax
    mov eax, STOMP_BOUNCE
    mov mario_yVel, eax
    push eax
    push ecx
    push edx
    INVOKE Beep, 300, 100
    pop edx
    pop ecx
    pop eax
    jmp CheckEnemyCollisions_Goomba2
CheckEnemyCollisions_G1_SideHit:
    mov eax, -2
    mov mario_yVel, eax
    dec lives
    cmp lives, 0
    je CheckEnemyCollisions_GameOver
    mov mario_xPos, 20
    mov mario_yPos, 20
    mov mario_xVel, 0
    mov mario_yVel, 0
    jmp CheckEnemyCollisions_Done
CheckEnemyCollisions_Goomba2:
    cmp goomba2_active, 0
    je CheckEnemyCollisions_Koopa
    mov eax, mario_xPos
    inc eax
    cmp eax, goomba2_xPos
    jle CheckEnemyCollisions_Koopa
    mov ebx, goomba2_xPos
    add ebx, 2
    mov ecx, mario_xPos
    cmp ecx, ebx
    jge CheckEnemyCollisions_Koopa
    mov eax, mario_yVel
    cmp eax, 0
    jle CheckEnemyCollisions_G2_SideHit
    mov eax, mario_yPos
    mov ebx, goomba2_yPos
    sub ebx, 1
    cmp eax, ebx
    jg CheckEnemyCollisions_G2_SideHit
    mov goomba2_active, 0
    mov eax, score
    add eax, STOMP_SCORE
    mov score, eax
    mov eax, STOMP_BOUNCE
    mov mario_yVel, eax
    push eax
    push ecx
    push edx
    INVOKE Beep, 300, 100
    pop edx
    pop ecx
    pop eax
    jmp CheckEnemyCollisions_Koopa
CheckEnemyCollisions_G2_SideHit:
    mov eax, -2
    mov mario_yVel, eax
    dec lives
    cmp lives, 0
    je CheckEnemyCollisions_GameOver
    mov mario_xPos, 20
    mov mario_yPos, 20
    mov mario_xVel, 0
    mov mario_yVel, 0
    jmp CheckEnemyCollisions_Done
CheckEnemyCollisions_Koopa:
    cmp koopa_active, 0
    je CheckEnemyCollisions_Done
    mov eax, mario_xPos
    inc eax
    cmp eax, koopa_xPos
    jle CheckEnemyCollisions_Done
    mov ebx, koopa_xPos
    add ebx, 2
    mov ecx, mario_xPos
    cmp ecx, ebx
    jge CheckEnemyCollisions_Done
    mov eax, mario_yVel
    cmp eax, 0
    jle CheckEnemyCollisions_Koopa_SideHit
    mov eax, mario_yPos
    mov ebx, koopa_yPos
    sub ebx, 1
    cmp eax, ebx
    jg CheckEnemyCollisions_Koopa_SideHit
    cmp koopa_state, 0
    jne CheckEnemyCollisions_Done
    mov koopa_state, 1  
    mov eax, STOMP_BOUNCE
    mov mario_yVel, eax
    push eax
    push ecx
    push edx
    INVOKE Beep, 300, 100
    pop edx
    pop ecx
    pop eax
    jmp CheckEnemyCollisions_Done
CheckEnemyCollisions_Koopa_SideHit:
    cmp koopa_state, 0
    jne CheckEnemyCollisions_Done
    mov eax, -2
    mov mario_yVel, eax
    dec lives
    cmp lives, 0
    je CheckEnemyCollisions_GameOver
    mov mario_xPos, 20
    mov mario_yPos, 20
    mov mario_xVel, 0
    mov mario_yVel, 0
    jmp CheckEnemyCollisions_Done
CheckEnemyCollisions_GameOver:
    mov gameState, 0
CheckEnemyCollisions_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckEnemyCollisions ENDP

CheckLevelCompletion PROC
    push eax
    push ebx
    push ecx
    push edx
    cmp levelComplete, 1
    je CheckLevelCompletion_Done
    mov al, currentLevel
    cmp al, 1
    jne CheckLevelCompletion_CheckFlag 
    mov eax, mario_xPos
    cmp eax, 78
    jl CheckLevelCompletion_CheckFlag  
    mov al, currentLevelScreen
    cmp al, 0
    jne CheckLevelCompletion_CheckFlag 
    mov mario_xPos, 2            
    mov currentLevelScreen, 1    
    mov isFirstFrame, 1          
    mov koopa_active, 1
    mov koopa_xPos, 45
    mov koopa_state, 0
    jmp CheckLevelCompletion_Done
CheckLevelCompletion_CheckFlag:
    mov al, currentLevel
    cmp al, 1
    jne CheckLevelCompletion_DoFlagCheck 
    mov al, currentLevelScreen
    cmp al, 1
    jne CheckLevelCompletion_Done        
CheckLevelCompletion_DoFlagCheck:
    mov eax, mario_xPos
    cmp eax, FLAGPOLE_X
    jl CheckLevelCompletion_Done
    mov levelComplete, 1
    mov flagDescending, 1
    mov eax, gameTime
    mov ebx, TIME_BONUS_MULTIPLIER
    mul ebx
    add score, eax
    mov mario_xVel, 0
    mov mario_yVel, 0
CheckLevelCompletion_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckLevelCompletion ENDP

DrawPipes PROC
    push eax
    push ebx
    push ecx
    push edx
    mov al, currentLevel
    cmp al, 1
    jne DrawPipes_Screen0  
    mov al, currentLevelScreen
    cmp al, 1
    je DrawPipes_Screen1
DrawPipes_Screen0:
    mov ecx, PIPE1_HEIGHT
    mov ebx, GROUND_LEVEL
    sub ebx, PIPE1_HEIGHT
DrawPipe1_Loop:
    mov dh, bl
    mov eax, PIPE1_X
    mov dl, al
    call Gotoxy
    push ecx
    mov ecx, PIPE1_WIDTH
DrawPipe1_Width:
    mov al, '|'
    call WriteChar
    loop DrawPipe1_Width
    pop ecx
    inc bl
    loop DrawPipe1_Loop
    mov ebx, GROUND_LEVEL
    sub ebx, PIPE1_HEIGHT
    dec ebx
    mov dh, bl
    mov eax, PIPE1_X
    mov dl, al
    call Gotoxy
    mov ecx, PIPE1_WIDTH
DrawPipe1_Top:
    mov al, '-'
    call WriteChar
    loop DrawPipe1_Top
    mov ecx, PIPE2_HEIGHT
    mov ebx, GROUND_LEVEL
    sub ebx, PIPE2_HEIGHT
DrawPipe2_Loop:
    mov dh, bl
    mov eax, PIPE2_X
    mov dl, al
    call Gotoxy
    push ecx
    mov ecx, PIPE2_WIDTH
DrawPipe2_Width:
    mov al, '|'
    call WriteChar
    loop DrawPipe2_Width
    pop ecx
    inc bl
    loop DrawPipe2_Loop
    mov ebx, GROUND_LEVEL
    sub ebx, PIPE2_HEIGHT
    dec ebx
    mov dh, bl
    mov eax, PIPE2_X
    mov dl, al
    call Gotoxy
    mov ecx, PIPE2_WIDTH
DrawPipe2_Top:
    mov al, '-'
    call WriteChar
    loop DrawPipe2_Top
    jmp DrawPipes_Done
DrawPipes_Screen1:
    mov ecx, 6  
    mov ebx, GROUND_LEVEL
    sub ebx, 6
DrawPipe3_Loop:
    mov dh, bl
    mov eax, 25 
    mov dl, al
    call Gotoxy
    push ecx
    mov ecx, 3   
DrawPipe3_Width:
    mov al, '|'
    call WriteChar
    loop DrawPipe3_Width
    pop ecx
    inc bl
    loop DrawPipe3_Loop
    mov ecx, 3  
    mov ebx, GROUND_LEVEL
    sub ebx, 3
DrawPipe4_Loop:
    mov dh, bl
    mov eax, 45 
    mov dl, al
    call Gotoxy
    push ecx
    mov ecx, 3   
DrawPipe4_Width:
    mov al, '|'
    call WriteChar
    loop DrawPipe4_Width
    pop ecx
    inc bl
    loop DrawPipe4_Loop
DrawPipes_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawPipes ENDP

DrawBlocks PROC
    push eax
    push ebx
    push ecx
    push edx
    mov al, currentLevel
    cmp al, 1
    jne DrawBlocks_Screen0  
    mov al, currentLevelScreen
    cmp al, 1
    je DrawBlocks_Screen1
DrawBlocks_Screen0:
    mov eax, QBLOCK1_Y
    mov dh, al
    mov eax, QBLOCK1_X
    mov dl, al
    call Gotoxy
    cmp qblock1_hit, 0
    je DrawBlocks_Q1_Active
    mov al, '='
    jmp DrawBlocks_Q1_Draw
DrawBlocks_Q1_Active:
    mov al, '?'
DrawBlocks_Q1_Draw:
    call WriteChar
    mov eax, QBLOCK2_Y
    mov dh, al
    mov eax, QBLOCK2_X
    mov dl, al
    call Gotoxy
    cmp qblock2_hit, 0
    je DrawBlocks_Q2_Active
    mov al, '='
    jmp DrawBlocks_Q2_Draw
DrawBlocks_Q2_Active:
    mov al, '?'
DrawBlocks_Q2_Draw:
    call WriteChar
    mov eax, QBLOCK3_Y
    mov dh, al
    mov eax, QBLOCK3_X
    mov dl, al
    call Gotoxy
    cmp qblock3_hit, 0
    je DrawBlocks_Q3_Active
    mov al, '='
    jmp DrawBlocks_Q3_Draw
DrawBlocks_Q3_Active:
    mov al, '?'
DrawBlocks_Q3_Draw:
    call WriteChar
    mov eax, BRICK1_Y
    mov dh, al
    mov eax, BRICK1_X
    mov dl, al
    call Gotoxy
    mov al, '#'
    call WriteChar
    mov eax, BRICK2_Y
    mov dh, al
    mov eax, BRICK2_X
    mov dl, al
    call Gotoxy
    mov al, '#'
    call WriteChar
    mov eax, BRICK3_Y
    mov dh, al
    mov eax, BRICK3_X
    mov dl, al
    call Gotoxy
    mov al, '#'
    call WriteChar
    jmp DrawBlocks_Done
DrawBlocks_Screen1:
    mov dh, 16
    mov dl, 15
    call Gotoxy
    mov al, '?'
    call WriteChar
    mov dh, 13
    mov dl, 35
    call Gotoxy
    mov al, '?'
    call WriteChar
    mov dh, 16
    mov dl, 50
    call Gotoxy
    mov al, '#'
    call WriteChar
    mov dh, 16
    mov dl, 51
    call Gotoxy
    mov al, '#'
    call WriteChar
DrawBlocks_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawBlocks ENDP

DrawPlatform PROC
    push eax
    push ebx
    push ecx
    push edx
    mov al, currentLevel
    cmp al, 1
    jne DrawPlatform_Screen0  
    mov al, currentLevelScreen
    cmp al, 1
    je DrawPlatform_Screen1
DrawPlatform_Screen0:
    mov eax, PLATFORM_Y
    mov dh, al
    mov eax, PLATFORM_X
    mov dl, al
    call Gotoxy
    mov ecx, PLATFORM_WIDTH
    mov al, '='
DrawPlatform_Loop:
    call WriteChar
    loop DrawPlatform_Loop
    jmp DrawPlatform_Done
DrawPlatform_Screen1:
    mov dh, 19
    mov dl, 38
    call Gotoxy
    mov ecx, 6
    mov al, '='
DrawPlatform2_Loop:
    call WriteChar
    loop DrawPlatform2_Loop
DrawPlatform_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawPlatform ENDP

CheckHeadBonk PROC
    push eax
    push ebx
    push ecx
    push edx
    mov eax, mario_yVel
    cmp eax, 0
    jge CheckHeadBonk_Done
    mov ebx, mario_yPos
    mov ecx, mario_xPos
CheckHeadBonk_Q1:
    mov edx, QBLOCK1_Y
    cmp ebx, edx
    jg CheckHeadBonk_Q2
    mov eax, edx
    sub eax, MAX_Y_SPEED
    cmp ebx, eax
    jl CheckHeadBonk_Q2
    cmp ecx, QBLOCK1_X
    jne CheckHeadBonk_Q2
    mov mario_yVel, 0
    mov eax, GRAVITY_ACCEL
    add mario_yVel, eax
    cmp qblock1_hit, 0
    jne CheckHeadBonk_Done
    mov qblock1_hit, 1
    call SpawnPowerUp
    jmp CheckHeadBonk_Done
CheckHeadBonk_Q2:
    mov edx, QBLOCK2_Y
    cmp ebx, edx
    jg CheckHeadBonk_Q3
    mov eax, edx
    sub eax, MAX_Y_SPEED
    cmp ebx, eax
    jl CheckHeadBonk_Q3
    cmp ecx, QBLOCK2_X
    jne CheckHeadBonk_Q3
    mov mario_yVel, 0
    mov eax, GRAVITY_ACCEL
    add mario_yVel, eax
    cmp qblock2_hit, 0
    jne CheckHeadBonk_Done
    mov qblock2_hit, 1
    call SpawnPowerUp
    jmp CheckHeadBonk_Done
CheckHeadBonk_Q3:
    mov edx, QBLOCK3_Y
    cmp ebx, edx
    jg CheckHeadBonk_Done
    mov eax, edx
    sub eax, MAX_Y_SPEED
    cmp ebx, eax
    jl CheckHeadBonk_Done
    cmp ecx, QBLOCK3_X
    jne CheckHeadBonk_Done
    mov mario_yVel, 0
    mov eax, GRAVITY_ACCEL
    add mario_yVel, eax
    cmp qblock3_hit, 0
    jne CheckHeadBonk_Done
    mov qblock3_hit, 1
    call SpawnPowerUp
CheckHeadBonk_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckHeadBonk ENDP

DrawGround PROC
    push eax
    push ecx
    push edx
    mov eax, GROUND_LEVEL
    add eax, 1
    mov dh, al
    mov dl, 0
    call Gotoxy
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov ecx, 80
    mov al, '='
DrawGround_Loop:
    call WriteChar
    loop DrawGround_Loop
    pop edx
    pop ecx
    pop eax
    ret
DrawGround ENDP

DrawFlagpole PROC
    push eax
    push ebx
    push ecx
    push edx
    mov al, currentLevel
    cmp al, 1
    jne DrawFlagpole_Draw
    mov al, currentLevelScreen
    cmp al, 0
    je DrawFlagpole_Done
DrawFlagpole_Draw:
    mov ecx, FLAGPOLE_HEIGHT
    mov ebx, 5
DrawFlagpole_Pole:
    mov dh, bl
    mov eax, FLAGPOLE_X
    mov dl, al
    call Gotoxy
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov al, '|'
    call WriteChar
    inc bl
    loop DrawFlagpole_Pole
    mov eax, flagY
    mov dh, al
    mov eax, FLAGPOLE_X
    inc eax
    mov dl, al
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov al, '>'
    call WriteChar
    mov eax, white + (black * 16)
    call SetTextColor
DrawFlagpole_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawFlagpole ENDP

UpdateFlagAnimation PROC
    push eax
    cmp flagDescending, 0
    je UpdateFlagAnimation_Done
    mov eax, flagY
    inc eax
    mov flagY, eax
    cmp eax, 20
    jl UpdateFlagAnimation_Done
    mov flagDescending, 0
    mov eax, 0
    mov mario_xVel, eax
    mov mario_yVel, eax
    mov eax, score
    add eax, 1000
    mov score, eax
UpdateFlagAnimation_Done:
    pop eax
    ret
UpdateFlagAnimation ENDP

DrawBonusStars PROC
    push eax
    push edx
    mov al, currentLevel
    cmp al, 1
    jne DrawBonusStars_Done
    mov al, currentLevelScreen
    cmp al, 0
    jne DrawBonusStars_Done
    mov eax, yellow + (black * 16)
    call SetTextColor
    cmp star1_active, 1
    jne DrawBonusStars_2
    mov dh, 15 
    mov dl, 31 
    call Gotoxy
    mov al, '*'
    call WriteChar
DrawBonusStars_2:
    cmp star2_active, 1
    jne DrawBonusStars_3
    mov dh, 14 
    mov dl, 52 
    call Gotoxy
    mov al, '*'
    call WriteChar
DrawBonusStars_3:
    cmp star3_active, 1
    jne DrawBonusStars_Done
    mov dh, 14 
    mov dl, 61 
    call Gotoxy
    mov al, '*'
    call WriteChar
DrawBonusStars_Done:
    mov eax, white + (black * 16)
    call SetTextColor
    pop edx
    pop eax
    ret
DrawBonusStars ENDP

CheckBonusStarCollection PROC
    push eax
    push ebx
    push ecx
    push edx
    mov al, currentLevel
    cmp al, 1
    jne CheckBonusStarCollection_Done
    mov al, currentLevelScreen
    cmp al, 0
    jne CheckBonusStarCollection_Done
    cmp star1_active, 1
    jne CheckBonusStarCollection_S2
    mov eax, mario_xPos
    cmp eax, 30 
    jl CheckBonusStarCollection_S2
    cmp eax, 32 
    jg CheckBonusStarCollection_S2
    mov eax, mario_yPos
    cmp eax, 13 
    jl CheckBonusStarCollection_S2
    cmp eax, 17 
    jg CheckBonusStarCollection_S2
    mov star1_active, 0
    add score, 200
    
    ; *** ADDED: INCREMENT COINS ***
    mov al, coins
    inc al
    mov coins, al
    
    INVOKE Beep, 1200, 100
CheckBonusStarCollection_S2:
    cmp star2_active, 1
    jne CheckBonusStarCollection_S3
    mov eax, mario_xPos
    cmp eax, 51
    jl CheckBonusStarCollection_S3
    cmp eax, 53
    jg CheckBonusStarCollection_S3
    mov eax, mario_yPos
    cmp eax, 12
    jl CheckBonusStarCollection_S3
    cmp eax, 16
    jg CheckBonusStarCollection_S3
    mov star2_active, 0
    add score, 200

    ; *** ADDED: INCREMENT COINS ***
    mov al, coins
    inc al
    mov coins, al
    
    INVOKE Beep, 1200, 100
CheckBonusStarCollection_S3:
    cmp star3_active, 1
    jne CheckBonusStarCollection_Done
    mov eax, mario_xPos
    cmp eax, 60
    jl CheckBonusStarCollection_Done
    cmp eax, 62
    jg CheckBonusStarCollection_Done
    mov eax, mario_yPos
    cmp eax, 12
    jl CheckBonusStarCollection_Done
    cmp eax, 16
    jg CheckBonusStarCollection_Done
    mov star3_active, 0
    add score, 200

    ; *** ADDED: INCREMENT COINS ***
    mov al, coins
    inc al
    mov coins, al
    
    INVOKE Beep, 1200, 100
CheckBonusStarCollection_Done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckBonusStarCollection ENDP

END main