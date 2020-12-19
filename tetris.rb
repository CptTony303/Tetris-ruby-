require 'ruby2d'
$window = self
$highscore
VOLUME = 20
START_SPEED = 0.8
SPEED_FACT = 1/1.26
FIELD_WIDTH = 10
FIELD_HEIGHT = 20
BLOCK_SIZE = 30
HUD_SIZE = 250
HUD_FONT_COLOR = 'red'
START_POS = [5,-2]
NEXT_POS = [FIELD_WIDTH+((HUD_SIZE/BLOCK_SIZE)/2).round, 3]
HOLD_POS = [FIELD_WIDTH+((HUD_SIZE/BLOCK_SIZE)/2).round, 8]
set title: "Tetris"
set width: FIELD_WIDTH * BLOCK_SIZE + HUD_SIZE
set height: FIELD_HEIGHT * BLOCK_SIZE
set background: 'black'
set fps_cap: 60
set fps: 60
puts "Stats for this tetris game:\n\n"
for i in 0..10
    puts "Need #{20*(2**(i))} Points for Level #{i+1}"
    puts "Speed of level #{i+1}: #{START_SPEED * SPEED_FACT**(i-1)}"
 end

class Block
    @pos
    @next_pos
    @col

    def initialize(x, y, col)
        @pos = [x,y]
        @next_pos = @pos
        @col = col
        @active = true
    end

    def move_line
        @next_pos[1]=@pos[1]+1
    end
    def y
        @pos[1]
    end
    def x
        @pos[0]
    end

    def cancle_move
        @next_pos = @pos
    end

    def deactivate
        $game.add_block(self)
    end

    def draw
        Square.new(x: @pos[0] * BLOCK_SIZE, y: @pos[1] * BLOCK_SIZE, size: BLOCK_SIZE, color: @col)
    end
    def position_free?(pos)
        if @pos[0] == pos[0] && @pos[1] == pos[1]
            false
        else
            true
        end
    end
    def set_next_pos(pos)
        @next_pos = pos
    end
    def set_new_pos
        @pos = @next_pos
    end
    def check_next_pos
        $game.position_free?(@next_pos)
    end
    def move(move_id = 1)
        shift = [0,0]
        case move_id
        when 0
            shift = [-1,0]
        when 1
            shift = [0,1]
        when 2
            shift = [1,0]
        end
        @next_pos = [@pos[0]+shift[0],@pos[1]+shift[1]]
    end
end

class Tetromino
    @x
    @y
    @col
    @blocks
    GRID = { 0 => [-2,-2],
            1 => [-1,-2],
            2 => [0,-2],
            3 => [1,-2],
            4 => [-2,-1],
            5 => [-1,-1],
            6 => [0,-1],
            7 => [1,-1],
            8 => [-2,0],
            9 => [-1,0],
            10 => [0,0],
            11 => [1,0],
            12 => [-2,1],
            13 => [-1,1],
            14 => [0,1],
            15 => [1,1] }

    ROTATION = { 0 => 3,
        1 => 7,
        2 => 11,
        3 => 15,
        4 => 2,
        5 => 6,
        6 => 10,
        7 => 14,
        8 => 1,
        9 => 5,
        10 => 9,
        11 => 13,
        12 => 0,
        13 => 4,
        14 => 8,
        15 => 12 }

    def initialize(pos,col)
         @x = pos[0]
         @y = pos[1]
         @col = col
         @blocks = []
         fillBlocks(set_blcks)
    end

    def fillBlocks(blcks)
        @blocks.clear
        blcks.each do |b|
            @blocks.push([new_block(b), b])
        end
    end

    def draw
        @blocks.each do|block|
            block[0].draw
        end
    end

    def set_pos (pos)
        @x = pos[0]
        @y = pos[1]
        fillBlocks(set_blcks)
    end

    def turn
        turn = true
        @blocks.each do |b|
            shift = GRID[ROTATION[b[1]]]
            b[0].set_next_pos([@x+shift[0], @y+shift[1]])
            if !b[0].check_next_pos
                turn = false
            end
        end
        if turn
            @blocks.each do |b|
                b[0].set_new_pos
                b[1] = ROTATION[b[1]]
            end
        end
    end

    def move(move_id = 1)
        shift = [0,0]
        case move_id
        when 0
            shift = [-1,0]
        when 1
            shift = [0,1]
        when 2
            shift = [1,0]
        end
        move = true
        active = true
        @blocks.each do |block|
            block[0].move(move_id)
            if !block[0].check_next_pos
                move = false
            end
        end
        
            @blocks.each do |block|
                if move
                block[0].set_new_pos
                else
                    block[0].cancle_move
                    if move_id == 1
                        active = false
                    end
                end
            end
            if move
                @x += shift[0]
                @y += shift[1]
            end
            if !active
                deactivate
            end
    end
    def new_block(index)
        shift = GRID[index]
        Block.new(@x+shift[0], @y+shift[1], @col)
    end
    def set_blcks
        [0,3,12,15]
    end
    def deactivate
        game_over = false
        @blocks.each do |block|
            block[0].deactivate
            if block[0].y < 0
                game_over = true
            end
        end
        if game_over
            $game.game_over
        else
        @blocks.each do |block|
            $game.check_line(block[0].y)
        end
        $game.destroy_lines
        $game.new_tetromino
        end
    end
end

class I < Tetromino
    def initialize (pos)
        super(pos, 'aqua')
    end
    def set_blcks
        [1,5,9,13]
    end
end
class J < Tetromino
    def initialize (pos)
        super(pos, 'navy')
    end
    def set_blcks
        [2,6,10,9]
    end
end
class L < Tetromino
    def initialize (pos)
        super(pos, 'orange')
    end
    def set_blcks
        [1,5,9,10]
    end
end
class O < Tetromino
    def initialize (pos)
        super(pos, 'yellow')
    end
    def set_blcks
        [5,6,9,10]
    end
end
class S < Tetromino
    def initialize (pos)
        super(pos, 'lime')
    end
    def set_blcks
        [9,10,6,7]
    end
end
class T < Tetromino
    def initialize (pos)
        super(pos, 'purple')
    end
    def set_blcks
        [9,10,11,6]
    end
end
class Z < Tetromino
    def initialize (pos)
        super(pos, 'fuchsia')
    end
    def set_blcks
        [5,6,10,11]
    end
end

class Game
    @running
    @game_over
    @highscore
    @score
    @blocks
    @active_block
    @hold_block
    @can_hold
    @destroy_lines
    @next_block
    @type_order
    @level
    TETROMINOS = {0 => I,
        1 => J,
        2 => L,
        3 => O,
        4 => S,
        5 => T,
        6 => Z,}
    
    def initialize()
        @timer = 0
        @level = 1
        @type_order = (0...7).to_a
        type = TETROMINOS[@type_order.delete_at(rand(@type_order.length))]
        @can_hold = true
        @hold_block = nil
        @next_block = type.new(NEXT_POS)
        @score = 0
        @highscore = false
        if $highscore == nil
            $highscore = 0
        end
        @running = true
        @game_over = false
        @blocks = []
        @destroy_lines = []
        $song.loop = true
        $song.play
        
    end
    def game_over 
        $song.stop
        @game_over = true
        @running = false
        if @highscore
            $highscore = @score
        end
    end
    def game_over?
        @game_over
    end
    def hold 
        if !@can_hold
            return
        end
        if @hold_block == nil
            @hold_block = @active_block
            @active_block.set_pos(HOLD_POS)
            new_tetromino
            @can_hold=false
        else
            @hold_block,@active_block = @active_block,@hold_block
            @hold_block.set_pos(HOLD_POS)
            @active_block.set_pos(START_POS)
            @can_hold=false
        end
    end
    def new_tetromino
        @can_hold = true
        @next_block.set_pos(START_POS)
        @active_block = @next_block
        if @type_order.length == 0
        @type_order = (0...7).to_a
        end
        type = TETROMINOS[@type_order.delete_at(rand(@type_order.length))]
        @next_block = type.new(NEXT_POS)
    end
    def draw_hud
        controls = [15,
            "Controls",
            "",
            "",
            "",
            "move left:",
            "left arrow",
            "move right:",
            "right arrow",
            "turn:",
            "up arrow",
            "drop:",
            "down arrow",
            "hold:",
            "space",
            "pause/resume:",
            "p",
            "mute:",
            "m"]
        controls_plus = ["",
            "",
            "restart:",
            "r",
            "exit:",
            "esc"]
        if !$game.running?
            controls += controls_plus
        end
        
        Rectangle.new(
            x: FIELD_WIDTH * BLOCK_SIZE, 
            y: 0, 
            width: HUD_SIZE, 
            height: FIELD_HEIGHT * BLOCK_SIZE,
            color: 'silver')
        Square.new(
            x: (NEXT_POS[0]-2)*BLOCK_SIZE, 
            y: (NEXT_POS[1]-2)*BLOCK_SIZE, 
            size: BLOCK_SIZE*4,
            color: 'black')
        Text.new(
                "Next:",
                x: (NEXT_POS[0]-2)*BLOCK_SIZE,
                y: (NEXT_POS[1]-2)*BLOCK_SIZE-15, 
                size: 15,
                color: HUD_FONT_COLOR,
                rotate: 0
              )
        @next_block.draw
        Square.new(
            x: (HOLD_POS[0]-2)*BLOCK_SIZE, 
            y: (HOLD_POS[1]-2)*BLOCK_SIZE, 
            size: BLOCK_SIZE*4, 
            color: 'black')
            Text.new(
                "Hold:",
                x: (HOLD_POS[0]-2)*BLOCK_SIZE,
                y: (HOLD_POS[1]-2)*BLOCK_SIZE-15, 
                size: 15,
                color: HUD_FONT_COLOR,
                rotate: 0
              )
        if @hold_block != nil
            @hold_block.draw
        end
        

        Text.new(
            "Highscore: #{$highscore}",
            x: (FIELD_WIDTH+1)*BLOCK_SIZE, y: 0,
            size: 15,
            color: HUD_FONT_COLOR,
            rotate: 0
          )
        Text.new(
            "Score: #{@score}",
            x: (FIELD_WIDTH+1)*BLOCK_SIZE, y: (FIELD_HEIGHT/2+1)*BLOCK_SIZE,
            size: 18,
            color: HUD_FONT_COLOR,
            rotate: 0
          )
          Text.new(
            "Level: #{@level}",
            x: (FIELD_WIDTH+1)*BLOCK_SIZE, y: (FIELD_HEIGHT/2+1)*BLOCK_SIZE-20,
            size: 15,
            color: HUD_FONT_COLOR,
            rotate: 0
          )
          counter_controls = 0
          controls.each do |c|
            if c == controls[0]
                next
            end
            Text.new(
                c,
                x: (FIELD_WIDTH+1+4*counter_controls.modulo(2))*BLOCK_SIZE, 
                y: (FIELD_HEIGHT/2+3)*BLOCK_SIZE+(counter_controls/2).round*controls[0],
                size: controls[0],
                color: HUD_FONT_COLOR,
                rotate: 0
          )
          counter_controls += 1
          end
          Text.new(
            "Made by Anton Hartmann",
            x: (FIELD_WIDTH+1)*BLOCK_SIZE, 
            y: (FIELD_HEIGHT-1)*BLOCK_SIZE,
            size: 15,
            color: HUD_FONT_COLOR,
            rotate: 0
          )
          
          if @highscore
            Text.new(
                "New Highscore!",
                x: (FIELD_WIDTH+1)*BLOCK_SIZE, y: (FIELD_HEIGHT/2+2)*BLOCK_SIZE,
                size: 15,
                color: HUD_FONT_COLOR,
                rotate: 0
              )
        end
    end
    def draw
        draw_hud
        if @blocks.length > 0
        @blocks.each do |block|
            block.draw
            end
        end
        if @active_block != nil
            @active_block.draw
        end
        if game_over?
            Text.new(
                'Game Over',
                x: (FIELD_WIDTH/2-3)*BLOCK_SIZE, y: (FIELD_HEIGHT/2-1)*BLOCK_SIZE,
                size: 60,
                color: HUD_FONT_COLOR,
                rotate: 0
              )
        end
        if !running? && !game_over?
            Text.new(
                'Pause',
                x: FIELD_WIDTH/2*BLOCK_SIZE, y: FIELD_HEIGHT/2*BLOCK_SIZE,
                size: 50,
                color: HUD_FONT_COLOR,
                rotate: 0
              )
        end
    end
    def update
        if @t == nil
            @t  = Time.now
        end
        if running?
            if Time.now - @t >= START_SPEED * SPEED_FACT**(@level-1)
            @active_block.move
            @t = Time.now
            end
        end
    end
    def running?
        @running
    end
    def input(action)
        case action
        when 'move_left' then @active_block.move(0)
        when 'move_right' then @active_block.move(2)
        when 'drop'
            a = @active_block
            while (a == @active_block && !game_over?)
                @active_block.move
            end
        when 'turn' then @active_block.turn
        when 'pause'
            @running = !@running
            if running?
                $song.resume
                $song.loop
            else
                $song.pause
            end
        when 'exit' then exit!
        when 'restart'
            $song.stop
            $game = Game.new
            $game.new_tetromino()
        when 'mute'
            if $song.volume != 0
                $song.volume = 0
            else
                $song.volume = VOLUME
            end
        when 'hold'
            hold
        else
        end
    end
    def add_block(block)
        @blocks.push(block)
    end
    def check_line(y)
        counter = 0
        @blocks.each do |block|
            if block.y == y
                counter+=1
            end
        end
        if counter == FIELD_WIDTH
            @destroy_lines.push(y)
        end
    end
    def destroy_lines
        @destroy_lines = @destroy_lines.uniq
        if @destroy_lines.length > 0
        case @destroy_lines.length
        when 1 then @score += 40
        when 2 then @score += 100
        when 3 then @score += 300
        when 4 then @score += 1200
        else @score += 1
        end
        if @score>$highscore
            @highscore=true
        end
        to_delete = []
        to_move = []
        @destroy_lines.each do |numb|
        @blocks.each do |block|
            if block.y == numb
                to_delete.push(block)
                
            elsif block.y < numb
                to_move.push(block)
            end
        end
    end
        to_delete = to_delete.uniq
        if to_delete.length>0
        to_delete.each do |block|
            @blocks.delete(block)
        end
        if to_move.length>0
        to_move.each do |block|
            block.move_line
        end
    end
    end
    @blocks.each do |block|
        block.set_new_pos
    end
    @destroy_lines = []
    level_up
    end
    end
    def level_up
        if @level <= Math.log(@score/20, 2)
        @level+=1
        end
    end
    def position_free?(pos)
        if ((0..FIELD_WIDTH-1) === pos[0] && (-4..FIELD_HEIGHT-1) === pos[1])
        @blocks.each do |block|
            if !block.position_free?(pos)
                return false
            end
        end
        true
        else
        false
    end
    end
end



$song = Music.new('tetris.mp3')
$song.volume = VOLUME
$game = Game.new()
$game.new_tetromino

update do
    clear
    $game.update
    $game.draw
end

on :key_down do |event|
    input = nil
    if event.key =='m'
        input = 'mute'
    end
    if event.key == 'p' && !$game.game_over?
        input = 'pause'
    end
    if $game.running?
    if ['down', 'left', 'right','up','space'].include?(event.key)
      
        case event.key
        when 'left' then input = 'move_left'
        when 'right' then input = 'move_right'
        when 'down' then input = 'drop'
        when 'up' then input = 'turn'
        when 'space' then input = 'hold'
        end
    end
    else
        if event.key == 'escape'
            input = 'exit'
        end
        if event.key == 'r'
            input = 'restart'
        end
    end
    $game.input(input)
end
show