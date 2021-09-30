---- #########################################################################
---- #                                                                       #
---- # Copyright (C) David Specht                                            #
-----#                                                                       #
---- # License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               #
---- #                                                                       #
---- # This program is free software; you can redistribute it and/or modify  #
---- # it under the terms of the GNU General Public License version 2 as     #
---- # published by the Free Software Foundation.                            #
---- #                                                                       #
---- # This program is distributed in the hope that it will be useful        #
---- # but WITHOUT ANY WARRANTY; without even the implied warranty of        #
---- # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
---- # GNU General Public License for more details.                          #
---- #                                                                       #
---- #########################################################################
local xVel = 0
local yVel = 0

local xPos = 0
local yPos = 0

local ballSize = LCD_W / 50

local scoreA = 0
local scoreB = 0

local aPadPos = 0
local bPadPos = 0

-- sets ball to center of the screen and gives it a random direction and vertical velocity
local function startBall()
    xPos = LCD_W/2 - ballSize/2
    yPos = LCD_H/2 - ballSize/2
    yVel = math.random(0, 6) - 3
    xVel = (math.random() > 0.5) and 2 or -2
end

local function init()
    startBall()
end

local function run()

    lcd.clear()

    -- calculate vertical position of paddles by converting the stick output range from -1024 - +1024 => 0 - lcd height minus paddle height
    aPadPos = (getValue("thr") - 1024) / 2048 * -(LCD_H - ballSize*4)
    bPadPos = (getValue("ele") - 1024) / 2048 * -(LCD_H - ballSize*4)

    -- checks collision with paddle by checking if the lower side of the ball is under the upper side of the paddle and the upper side of the ball over the lower side of the paddle
    if xPos < ballSize and (yPos + ballSize) >= aPadPos and yPos <= (aPadPos + ballSize * 4) then
        xVel = -xVel
        xPos = ballSize + 1
        yVel = math.random(0, 6) - 3
    elseif xPos > (LCD_W - ballSize*2) and (yPos + ballSize) >= bPadPos and yPos <= (bPadPos + ballSize * 4) then
        xVel = -xVel
        xPos = LCD_W - ballSize*2 - 1
        yVel = math.random(0, 6) - 3
    end

    -- checks for collision with left or right wall, adds to the score and resets the ball
    if xPos >= LCD_W - ballSize then
        scoreA = scoreA + 1
        startBall()
    elseif xPos <= 0 then
        scoreB = scoreB + 1
        startBall()
    -- flips the vertical velocity if the ball hits the wall
    elseif yPos >= LCD_H - ballSize or yPos <= 0 then
        yVel = -yVel
    end

    -- move ball by adding the velocity to the position
    xPos = xPos + xVel
    yPos = yPos + yVel

    -- draw ball
    lcd.drawFilledRectangle(xPos,yPos,ballSize,ballSize)

    -- draw left and right paddle
    lcd.drawFilledRectangle(0, aPadPos, ballSize, ballSize*4)
    lcd.drawFilledRectangle(LCD_W - ballSize, bPadPos, ballSize, ballSize*4)

    -- draw center line and score
    lcd.drawLine(LCD_W/2, 0, LCD_W/2, LCD_H, DOTTED, 0)
    lcd.drawNumber(LCD_W * 0.25, ballSize, scoreA, 0)
    lcd.drawNumber(LCD_W * 0.75, ballSize, scoreB, 0)

    lcd.refresh()

    return 0

end

return {init=init, run=run}
