-- [[

-- SUPER CÖMMUNIST
-- A game by Altom for the March 2012 Experimental Gameplay Project (Theme: ECONOMY)

-- Begun : Sunday March 4th (supposed worktime: 7 days, delay: still counting)

-- RANDOM IDEAS:
-- - "Godly events" : Economy crash, Oil pit, Technology : try to balance the economy online
-- - Shop items:
--   o heart containers
--   o VIVA LA REVOLUTION (poor attack rich for x minutes)
--   o ...
-- - Refactor : make methods in player, ui, world, etc? use the standard "inst.foo(inst, param)" to be called with "inst:foo(param)"
--

-- this is to enable live console output in Sublime Text
io.stdout\setvbuf'no'


-- External libraries
export anim8 = require "lib/anim8"

-- custom libraries
require "bafaltom2D"
require "variables"
require "menu"
require "dude"
require "coin"
require "fireball"
require "world"
require "ui"
require "shop"
require "item"
require "player"

export world, player, dudeList, coinList, ui, shop, fireballList

love.load = ->
    seed = os.time! if not DEBUG else "I think it's better to have deterministic tests"
    math.randomseed seed
    math.random!
    math.random!
    math.random!
    love.mouse.setVisible false

    world = World!
    player = Player!
    dudeList = DudeList!
    coinList = CoinList!
    fireballList = FireBallList!
    ui = UI!
    shop = Shop!

    export displayMenu = true

love.draw = ->
    if displayMenu
        menu\draw!
    else
        world\draw!
        ui\draw!
        shop\draw!

love.update =  (dt) ->
    unless PAUSE or displayMenu
        world\update dt

        -- WIN
        if dudeList\areAllMiddle!
            menu\setState "won"
            displayMenu = true

        -- LOOSE
        if player.life <= 0
            menu\setState "lost"
            PAUSE = true
            displayMenu = true

love.keypressed = (k) ->
    if displayMenu
        menu\keypressed k
    else
        -- player actions are in player\keypressed (called by world\keypressed)
        switch k
            when "o"
                DEBUG = not DEBUG
            when "p"
                PAUSE = not PAUSE
            when "escape"
                menu\setState "pause"
                PAUSE = true
                displayMenu = true
            else
                world\keypressed k
                ui\keypressed k
