-- !hi, this code is a mess!
-- !if i have time i'll go back and clean it up a bit, but right now i'm more worried about pumping out stuff than doing it the "right" way
-- !for now please bear with me :> i'll promise i'll be a good boy and write clean code with dictionaries (and god forbid booleans!) once i get a grip on this whole gamedev thing

function love.load()

    -- dependencies

    -- anim8 takes care of animation
    anim8 = require("libraries/anim8")

    -- canvas dimensions (you can edit this! you just have to edit it on the conf.lua file as well)
    canvasX = 800
    canvasY = 400

    --simple boilerplate
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 3000, true)
    love.graphics.setDefaultFilter("nearest", "nearest")


    -- background color
    color1 = {196 / 255, 233 / 255, 255 / 255}
    color2 = {150 / 255, 213 / 255, 255 / 255}
    color3 = {115 / 255, 199 / 255, 255 / 255}

    colorchange = 0

    -- EDITABLE VARIABLES --
    spritesize = 4
    speed = 2

    -- objects
    objects = {}

    -- setting some tables for animations
    objects.player = {}
    objects.player.animations = {}
    objects.player.sprites = {}
    objects.player.grids = {}

    -- tell me of a better way to do this without getting super technical with tables and loops, i dare you
    objects.player.sprites.idle       = love.graphics.newImage("sprites/idle.png")
    objects.player.grids.idle         = anim8.newGrid(28, 36, objects.player.sprites.idle:getWidth(), objects.player.sprites.idle:getHeight())
    objects.player.animations.idle    = anim8.newAnimation(objects.player.grids.idle('1-8', 1), 0.2)

    objects.player.sprites.walk       = love.graphics.newImage("sprites/walk.png")
    objects.player.grids.walk         = anim8.newGrid(28, 36, objects.player.sprites.walk:getWidth(), objects.player.sprites.walk:getHeight())
    objects.player.animations.walk    = anim8.newAnimation(objects.player.grids.walk('1-8', 1), 0.1)

    objects.player.sprites.held3      = love.graphics.newImage("sprites/held3.png")
    objects.player.grids.held3        = anim8.newGrid(28, 36, objects.player.sprites.held3:getWidth(), objects.player.sprites.walk:getHeight())
    objects.player.animations.held3   = anim8.newAnimation(objects.player.grids.held3('1-4', 1), 0.1)

    objects.player.sprites.falling    = love.graphics.newImage("sprites/falling.png")
    objects.player.grids.falling      = anim8.newGrid(28, 36, objects.player.sprites.falling:getWidth(), objects.player.sprites.walk:getHeight())
    objects.player.animations.falling = anim8.newAnimation(objects.player.grids.falling('1-4', 1), 0.1)

    objects.player.sprites.fall       = love.graphics.newImage("sprites/fall.png")
    objects.player.grids.fall         = anim8.newGrid(32, 32, objects.player.sprites.fall:getWidth(), objects.player.sprites.walk:getHeight())
    objects.player.animations.fall    = anim8.newAnimation(objects.player.grids.fall('1-3', 1), 0.1, 'pauseAtEnd')

    objects.player.sprites.held1      = love.graphics.newImage("sprites/held1.png")
    objects.player.grids.held1        = anim8.newGrid(28, 36, objects.player.sprites.held1:getWidth(), objects.player.sprites.walk:getHeight())
    objects.player.animations.held1   = anim8.newAnimation(objects.player.grids.held1('1-1', 1), 0.1)

    objects.player.sprites.held2      = love.graphics.newImage("sprites/held2.png")
    objects.player.grids.held2        = anim8.newGrid(28, 36, objects.player.sprites.held2:getWidth(), objects.player.sprites.walk:getHeight())
    objects.player.animations.held2   = anim8.newAnimation(objects.player.grids.held2('1-1', 1), 0.1)

    -- "current" aka currently active frame that's in use both in dimensions for rigid bodies and in rendering
    objects.player.sprites.current = objects.player.sprites.idle
    objects.player.grids.current = objects.player.grids.walk
    objects.player.animations.current = objects.player.animations.idle

    -- stay mad
    animations = {
        objects.player.animations.idle,
        objects.player.animations.walk,
        objects.player.animations.held3,
        objects.player.animations.falling,
        objects.player.animations.fall,
        objects.player.animations.held1,
        objects.player.animations.held2,
    }

    -- AI related functions and variables

    floored = 0
    
    walled = 0

    walking = 0

    flipped = 0

    fallingorfell = 0

    -- this makes sure that i always know what direction she's facing, no more headaches
    function flip()
        for i in pairs(animations) do
            animations[i]:flipH()
        end
        if flipped == 0 then flipped = 1 else flipped = 0 end
    end

    function walk()
        objects.player.animations.current = objects.player.animations.walk
        objects.player.sprites.current = objects.player.sprites.walk
        objects.player.grids.current = objects.player.grids.walk
        waking = 1
    end

    function idle()
        objects.player.sprites.current = objects.player.sprites.idle
        objects.player.grids.current = objects.player.grids.idle
        objects.player.animations.current = objects.player.animations.idle
        walking = 0
    end

    function held3()
        objects.player.sprites.current = objects.player.sprites.held3
        objects.player.grids.current = objects.player.grids.held3
        objects.player.animations.current = objects.player.animations.held3
    end

    function falling()
        objects.player.sprites.current = objects.player.sprites.falling
        objects.player.grids.current = objects.player.grids.falling
        objects.player.animations.current = objects.player.animations.falling
        fallingorfell = 1
    end

    function fall()
        objects.player.sprites.current = objects.player.sprites.fall
        objects.player.grids.current = objects.player.grids.fall
        objects.player.animations.current = objects.player.animations.fall
    end

    function held1()
        objects.player.sprites.current = objects.player.sprites.held1
        objects.player.grids.current = objects.player.grids.held1
        objects.player.animations.current = objects.player.animations.held1
    end

    function held2()
        objects.player.sprites.current = objects.player.sprites.held2
        objects.player.grids.current = objects.player.grids.held2
        objects.player.animations.current = objects.player.animations.held2
    end

    -- player dimensions, width and height
    playerW, playerH = objects.player.animations.current:getDimensions()
    -- multiplying it by the size of the sprite chosen
    playerW = playerW * spritesize
    playerH = playerH * spritesize

    -- setting player's rigid body declarations
    objects.player.body = love.physics.newBody(world, canvasX / 2, canvasY - playerH / 2, "dynamic")
    objects.player.shape = love.physics.newRectangleShape(playerW, playerH)
    objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 0)

    -- mouse position (i need this later)
    MXP, MYP = love.mouse.getPosition(x, y)

end

function love.update(dt)
    -- world update per frame
    world:update(dt)

    -- changing background color gradually
    for i = 1, 3, 1 do
        if colorchange < 200 then
            color1[i] = color1[i] + 0.001
            color2[i] = color2[i] + 0.001
            color3[i] = color3[i] + 0.001
            colorchange = colorchange + 1
    else
        color1[i] = color1[i] - 0.001
        color2[i] = color2[i] - 0.001
        color3[i] = color3[i] - 0.001
        colorchange = colorchange + 1
        if colorchange == 400 then colorchange = 0 end
    end
    end

    -- update animation
    objects.player.animations.current:update(dt)

    -- current player frame's dimensions
    PFX, PFY = objects.player.animations.current:getDimensions()
    -- player X/Y velocity
    PXV, PYV = objects.player.body:getLinearVelocity()
    -- player X/Y position
    PXP, PYP = objects.player.body:getPosition()
    -- difference in mouse X/Y position since last frame
    DMXP, DMYP = MXP - love.mouse.getX(), MYP - love.mouse.getY()
    -- mouse position
    MXP, MYP = love.mouse.getPosition(x, y)

    -- dynamically change the dimensions for literally everything every single frame
    playerW, playerH = objects.player.animations.current:getDimensions()
    playerW = playerW * spritesize
    playerH = playerH * spritesize
    objects.player.shape = love.physics.newRectangleShape(playerW, playerH)

    -- if the character is standing still, make idle animation
    if PXP == objects.player.body:getX() and floored == 1 and fallingorfell == 0 then
        idle()
        walking = 0
    end
    
    -- falling animation after being dropped from a height
    if held == 0 and PYP + playerW / 2 < canvasY - 50 then falling() end

    -- hitting the ground
    if objects.player.animations.current == objects.player.animations.falling and PYP + playerH / 2 > canvasY then
        -- if she falls too hard, only show the last frame.
        if PYV > 1000 then 
            objects.player.animations.fall:pauseAtEnd()
        else 
            objects.player.animations.fall:pauseAtStart()
            objects.player.animations.fall:resume() 
        end
        -- flip falling animation depending on the character's X velocity
        if PXV < 1 then
            if flipped == 1 then flip() end
        else
            if flipped == 0 then flip() end
        end
        fall() 
    end

    -- setting up screen physical borders that change dynamically with the canvas size

    -- right wall
    if PXP - playerW / 2 < 0 then
        PXV = 0
        PXP = 0 + playerW / 2
    end

    -- left wall
    if PXP + playerW / 2 > canvasX then
        PXV = 0
        PXP = canvasX - playerW / 2
    end

    -- bottom wall
    if PYP + playerH / 2 > canvasY then
        PYV = 0
        PYP = canvasY - playerH / 2
        floored = 1
    else
        floored = 0
    end

    -- simulating friction (because i just REALLY wanted to program wall borders myself instead of just adding 4 squares to each side and having the physics engine take care of it)

    -- side walls
    if PXP - playerW / 2 == 0 or PXP + playerW / 2 == canvasX and walled == 1 and held == 0 then
        if PYV < 0 then PYV = PYV + 50 end
    end

    -- floor
    if floored == 1 then PXV = PXV / 1.1
        if PXV < 0.5 and PXV > -0.5 then PXV = 0 end
    end

    if held == 1 then
        if PYP + playerW / 2 > canvasY - 30 then held1()
        else
            if PYP + playerW / 2 < canvasY - 30 and PYP + playerW / 2 > canvasY - 60 then held2() end
            if PYP + playerW / 2 < canvasY - 60 then held3() end
        end
        fallingorfell = 0
    end

    -- mouse controls

    -- holding with left click (i know this is a clumsy way of doing it but fuck man i'm tired it's 6 am)
    if love.mouse.isDown(1) and (MXP > PXP - playerW / 2 and MXP < PXP + playerW / 2 and MYP > PYP - playerH / 2 and MYP < PYP + playerH / 2 or held == 1) then

        -- !due to a bug with gravity that caused the object to slide out of the mouse
        -- !i found no other efficient way other than to sneakily disable gravity while the object is picked up :3 forgive me for being lazy
        world:setGravity(0, 0)

        -- i calculate the difference and subtract it from the position so the body won't immediately stick to the middle of the mouse
        PXP, PYP = PXP - DMXP, PYP - DMYP

        PXV, PYV = 0, 0

        held = 1
        throwing = 1
    else
        -- using i is the quickest way i could think of a way to know when we used to hold something but now don't. so the throw only happens once.
        if throwing == 1 then
            -- here i also use the difference to set the velocity, i felt pretty smart when i figured this out
            -- i also had to add the -1 at the end to stop the character from being frozen mid-air if you dropped her without any velocity
            PXV, PYV = DMXP * 30 * -1, DMYP * 30 * -1 - 1

            held = 0
            throwing = 0

            -- setting gravity back
            world:setGravity(0, 3000)
        end
    end

    -- keyboard controls

    -- resetting the position and velocity with R by default
    if love.keyboard.isDown("r") then
        PXP, PYP = canvasX / 2, canvasY / 2
        PXV, PYV = 0, 0
        fallingorfell = 0
    end

    -- A and D moves the character left and right and changes their facing direction
    if love.keyboard.isDown("a") and floored == 1 then
        PXP = PXP - speed
        walk()
        if flipped == 1 then flip() end
        fallingorfell = 0
    end

    if love.keyboard.isDown("d") and floored == 1 then
        PXP = PXP + speed
        walk()
        if flipped == 0 then flip() end
        fallingorfell = 0
    end

    -- setting up pirl's AI

    -- randomly change where she's looking
    -- if objects.player.animations.current == objects.player.animations.idle and love.math.random(1, 200) == 1 then
    --     flip()
    --     flipped = 0
    -- end

    -- randomly decide to start walking

    -- finally adding everything up
    objects.player.body:setPosition(PXP, PYP)
    objects.player.body:setLinearVelocity(PXV, PYV)
end

function love.draw()
    -- the player

    -- this is used to debug the outer rigid body frame of the sprite
    -- love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))

    -- background
    love.graphics.setColor(color1[1], color1[2], color1[3])
    love.graphics.rectangle("fill", 0, 0, canvasX / 3, canvasY)
    love.graphics.setColor(color2)
    love.graphics.rectangle("fill", canvasX / 3, 0, canvasX / 3, canvasY)
    love.graphics.setColor(color3)
    love.graphics.rectangle("fill", canvasX / 1.5, 0, canvasX / 3, canvasY)
    love.graphics.setColor(255,255,255)

    -- sprite is rendered with the top-left in the center of the rigid body rectangle, that's why we offset it with the player width and height, then multiply by the halved sprite size base multiplication to make up for the difference
    objects.player.animations.current:draw(objects.player.sprites.current, PXP - PFX * spritesize / 2,
        PYP - PFY * spritesize / 2, nil, spritesize, spritesize)

    -- debugging stuff
    print(MXP, MYP)

    print(PXP, PYP)

    print(PXV, PYV)
end

