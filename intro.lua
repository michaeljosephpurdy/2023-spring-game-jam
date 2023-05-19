Intro = {}
local next_button
local images = {}

-- image names
local WHITE_HOUSE = 1
local OVAL_OFFICE = 2
local ANDY_JASSY = 3
local MIKE_PURDY = 4

local SEGMENTS = {
  -- [1] active images, [2] freeform text, [3] time till next button, [4] % height, [5] auto-press
  { { WHITE_HOUSE }, '', .4, 0, true },
  { { WHITE_HOUSE }, '               The White House', .25, .3 },
  { { OVAL_OFFICE }, '', .25, 0, true} ,
  { { OVAL_OFFICE }, '               The Oval Office', .25, .3} ,
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nWhere's the President?", .5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY }, "???? ?????:\nHe should be here.\nEveryone must RTO for 3x a week..." , 1.5, .6 },
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nWhat are you doing here?" , .5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThe board decided that I have\nthe most Customer Obsession.", 1.5, .5 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nBecause of this, I am able to\nfill this role while the search\nfor the President continues.", 2, .7 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nListen..." , .5,  .4, true },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nListen...\nI need your help rescuing\nthe President." , 1.25, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nI don't think I can.", .5, .7, true },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nI don't think I can.\n#gamedev-interest is hosting\na game jam.", 1.25, .7 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nNow?", .5, .7, true},
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nNow?\nI thought they only hosted\njams in the Winter?", 1.25, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nThat's a common misconception.", .5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nWhat's the theme?", .5, .4 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nChain Reaction.", .5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nWell...", .5, .7, true},
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nWell... What I need you to do,", .5, .7, true},
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nWell... What I need you to do,\nis solve puzzles based on\ninteractions between objects.", 1, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nHow will that help rescue\nthe President?", .75, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nRemember...", .6, .7, true},
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nRemember...\nLeaders Are Right, A Lot.", .6, .7, true },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nRemember...\nLeaders Are Right, A Lot.\nYou'll have to trust me.", 1.5, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nHmm...", .6, .4, true},
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nHmm... Solving puzzles based on\nobjects interacting with eachother.", 1.5, .55 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nThat sounds like a great idea\nfor the game jam!", 1, .55 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nAnd it would fulfill the optional\nrestriction of 'one button'", 1.5, .7, true},
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nAnd it would fulfill the optional\nrestriction of 'one button',\nsince you only use the left\nmouse button to play.", .5, .8 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nBut I won't have time to work\non my game...", 1, .5 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThis,", .5, .55, true},
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThis, like RTO,", .5, .55, true},
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThis, like RTO, is not an option.", .5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThis, like RTO, is not an option.\nYou must do it.", .25, .55 },
  { { OVAL_OFFICE, MIKE_PURDY }, "", .65, 0, true },
  { { OVAL_OFFICE, }, "", .3, 0 },
}
local current_segment = 1

Intro.load = function()
  images[WHITE_HOUSE] = love.graphics.newImage('data/assets/white-house.png')
  images[OVAL_OFFICE] = love.graphics.newImage('data/assets/oval-office.png')
  images[ANDY_JASSY] = love.graphics.newImage('data/assets/andy-jassy.png')
  images[MIKE_PURDY] = love.graphics.newImage('data/assets/mike-purdy.png')
  next_button = {
    x = 224 , y = 240, width = 32, height = 16,
    sprite = Sprite.newQuad(13, 0, 32, 16),
    disabled_sprite = Sprite.newQuad(15, 0, 32, 16),
    disabled = true,
    click = function(self)
      if self.disabled then return end
      if (current_segment == #SEGMENTS) then
        GameState.set_simulation()
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
  end, 1)
end

Intro.draw = function()
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

Intro.handlePress = function(x, y, button, istouch, presses)
  if overlaps_mouse(x, y, next_button) then
    next_button:click()
  end
end
