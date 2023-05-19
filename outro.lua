Outro = {}
local next_button
local images = {}

-- image names
local WHITE_HOUSE = 1
local OVAL_OFFICE = 2
local ANDY_JASSY = 3
local MIKE_PURDY = 4
local JEFF_BEZOS = 5

local SEGMENTS = {
  -- [1] active images, [2] freeform text, [3] time till next button, [4] % height, [5] auto-press
  { { OVAL_OFFICE }, '', .25, 0, true } ,
  { { OVAL_OFFICE }, '               The Oval Office', .5, .3} ,
  { { OVAL_OFFICE, ANDY_JASSY }, "Andy Jassy:\nYou did it.\n" , .75, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Me:\nPlease include this as\nan example of Deliver Results\non my next Forte." , 3, .65 },
  { { OVAL_OFFICE, MIKE_PURDY }, "???? ????:\nOh, he will." , .6, .55, true },
  { { OVAL_OFFICE, MIKE_PURDY }, "???? ????:\nOh, he will.\nI'll make sure of it." , 1, .55 },
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nYou're the President of\nthe United States?!" , .25, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nThat's right" , .4, .4, true },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nThat's right, I am." , .5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nWhen you innovate for customers\nfor as long as I have" , .5, .65 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nyou end up looking for\nmore challenging pursuits." , .5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nPlus, I heard there was\na PhoneTool icon for\nbecoming President." , .5, .65 },
  { { OVAL_OFFICE, JEFF_BEZOS, MIKE_PURDY }, "Me:\nYet not one for\n#gamedev-interest game jams." , .5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nTo show my gratitude for you\nrescuing me" , .7, .65, true},
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nTo show my gratitude for you\nrescuing me, please take\nthis letter." , .4, .65 },
  { { OVAL_OFFICE, JEFF_BEZOS, MIKE_PURDY }, "Me:\nIs this my RTO exemption?" , .7, .55, true},
  { { OVAL_OFFICE, JEFF_BEZOS, MIKE_PURDY }, "Me:\nIs this my RTO exemption?\nThanks!" , .45, .55 },
  { { OVAL_OFFICE, JEFF_BEZOS, MIKE_PURDY }, "Me:\nWait a minute...", .65, .55, true },
  { { OVAL_OFFICE, JEFF_BEZOS, MIKE_PURDY }, "Me:\nWait a minute...\nThis is just the\n'1997 Shareholder Letter'." , .5, .65 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nWhat's written there is as true\ntoday as it was in 1997...", 1.5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nI must go,\nthank you for rescuing me.", 1.5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nYou know the true meaning", .7, .55, true},
  { { OVAL_OFFICE, MIKE_PURDY, JEFF_BEZOS }, "Jeff Bezos:\nYou know the true meaning\nof Customer Obsession.", 1.5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY }, "", .7, 0, true},
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nUgh...", .7, .65, true},
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nUgh...\nI didn't get to ask about my\nRTO exemption.", 3, .65 },
  { { OVAL_OFFICE }, "", 1, 0, true},
  { { WHITE_HOUSE }, "Thanks for playing :)", .6, 1, true},
  { { WHITE_HOUSE }, "Thanks for playing :)\n\nMade by Mike Purdy", .6, 1, true},
  { { WHITE_HOUSE }, "Thanks for playing :)\n\nMade by Mike Purdy\n\nHit NEXT to play again.", 1, 1 },
}
local current_segment = 1
local current_timeleft

Outro.load = function()
  images[WHITE_HOUSE] = love.graphics.newImage('data/assets/white-house.png')
  images[OVAL_OFFICE] = love.graphics.newImage('data/assets/oval-office.png')
  images[ANDY_JASSY] = love.graphics.newImage('data/assets/andy-jassy.png')
  images[MIKE_PURDY] = love.graphics.newImage('data/assets/mike-purdy.png')
  images[JEFF_BEZOS] = love.graphics.newImage('data/assets/jeff-bezos.png')
  next_button = {
    x = 224 , y = 240, width = 32, height = 16,
    sprite = Sprite.newQuad(13, 0, 32, 16),
    disabled_sprite = Sprite.newQuad(15, 0, 32, 16),
    disabled = true,
    click = function(self)
      if self.disabled then return end
      if (current_segment == #SEGMENTS) then
        GameState.set_title()
        return
      end
      current_segment = current_segment + 1
      self.disabled = true
      TimedFunction.new(function()
        self.disabled = false
        local autoclick = SEGMENTS[current_segment][5]
        if autoclick then
          next_button:click()
          return
        end
      end, SEGMENTS[current_segment][3])
    end
  }
  TimedFunction.new(function()
    next_button.disabled = false
    next_button:click()
  end, 1)
end

Outro.draw = function()
  local segment = SEGMENTS[current_segment]
  love.graphics.scale(1/SCALE)
  local imgs = segment[1]
  for_each(imgs, function(img)
    love.graphics.draw(images[img], 0, 0)
  end)
  local text = segment[2]
  love.graphics.scale(SCALE)
  love.graphics.setColor(PicoColors.DARK_BLUE, .5)
  love.graphics.rectangle('fill', 15, 15, 220, 100 * segment[4])
  love.graphics.setColor(PicoColors.WHITE)
  love.graphics.print(text, 20, 20)
  love.graphics.setColor(1, 1, 1)
  if next_button.disabled then
    love.graphics.draw(Sprite.texture, next_button.disabled_sprite, next_button.x, next_button.y)
  else
    love.graphics.draw(Sprite.texture, next_button.sprite, next_button.x, next_button.y)
  end
end

Outro.handlePress = function(x, y, button, istouch, presses)
  if overlaps_mouse(x, y, next_button) then
    next_button:click()
  end
end
