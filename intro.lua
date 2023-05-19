Intro = {}
local next_button
local images = {}

-- image names
local WHITE_HOUSE = 1
local OVAL_OFFICE = 2
local ANDY_JASSY = 3
local MIKE_PURDY = 4

local SEGMENTS = {
  -- [1] active images, [2] freeform text, [3] time till next button, [5] % height
  { { WHITE_HOUSE }, '', 1, 0 },
  { { WHITE_HOUSE }, 'White House\nJuly 5, 2044', .5, .4 },
  { { OVAL_OFFICE }, '', 1, 0} ,
  { { OVAL_OFFICE }, '               The Oval Office', .5, .3} ,
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nWhere's the President?" , 2, .4 },
  { { OVAL_OFFICE, MIKE_PURDY }, "???? ?????:\nHe has to RTO 3x a week,\nso he's not here." , 3, .6 },
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nBut this is his office.\nShouldn't he be here?" , 3, .6 },
  { { OVAL_OFFICE, MIKE_PURDY }, "Me:\nAnd what are you doing here?" , 2, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThe board decided that I have\nthe most customer obsession.", 3, .5 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThis means I can help\nfill this role for now.", 3, .5 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nListen..." , 1,  .5 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nI need your help rescuing\nthe President." , 3, .5 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nI don't think I can.\n#gamedev-interest is hosting\na game jam.", 3, .7 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nNow?\nI thought they only hosted\njams in the Winter?", 3, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nThat's a common misconception.", 1.5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nWhat's the theme?", 1.5, .4 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nChain Reaction.", 1.5, .4 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nWell... What I need you to do\nis solve puzzles based on\ninteractions between objects.", 3, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nHow will that help rescue\nthe President?", 1.5, .55 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nRemember...\nLeaders are right, a lot.\nYou'll have to trust me.", 3, .7 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nHmm.... Solving puzzles based on\nobjects interacting with eachother\ndoes sound like a good\nimplementation of the theme...", 3, .9 },
  { { OVAL_OFFICE, ANDY_JASSY, MIKE_PURDY }, "Me:\nBut I won't have time\nto work on my game.", 3, .5 },
  { { OVAL_OFFICE, MIKE_PURDY, ANDY_JASSY }, "Andy Jassy:\nThis, like RTO, is not an option.\nYou must do it.", 3, .7 },
  { { OVAL_OFFICE }, "", 1, 0 },
}
local current_segment = 1
local current_timeleft

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
      if (current_segment == #SEGMENTS) then
        GameState.set_simulation()
        return
      end
      current_segment = current_segment + 1
      current_timeleft = SEGMENTS[current_segment][3]
      self.disabled = true
    end
  }
  current_timeleft = SEGMENTS[current_segment][3]
end

Intro.update = function(dt)
  current_timeleft = current_timeleft - dt
  if current_timeleft < 0 then
    next_button.disabled = false
  end
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
