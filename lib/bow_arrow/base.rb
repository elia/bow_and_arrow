# Copyright 2009 Wilker Lucio <wilkerlucio@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'base64'

require 'lib/bow_arrow/elements'
require 'lib/bow_arrow/stages'

module BowArrow
  class Base
    include BowArrow::Elements

    attr_reader :app, :score, :level

    SCREEN_WIDTH  = 640
    SCREEN_HEIGHT = 480

    STAGES = [
      Stages::Stage01Training,
      Stages::Stage02MoreTraining,
      Stages::Stage03Butterflies,
      Stages::Stage04Slimes,
      Stages::Stage06Fires,
      Stages::Stage08Winds
    ]

    def initialize(app)
      @app = app
      @score = Score.new @app
      @highscore = 0

      load_highscore

      restart
    end

    def game_loop(elapsed)
      @app.clear do
        app.background app.rgb(0, 128, 0)

        app.para "Highscore: #{@highscore}  Arrows Left: #{@stage.arrows_left}"

        @stage.draw elapsed
      end
    end

    def next
      @cur_stage += 1

      if @cur_stage == STAGES.length
        @level += 1
        @cur_stage = 0
      end

      @stage = STAGES[@cur_stage].new self
    end

    def restart
      save_highscore

      @cur_stage = -1
      @score.score = 0
      @level = 1

      self.next
    end

    def load_highscore
      if File.exist?("highscore")
        @highscore = Base64.decode64(File.read("highscore")).to_i
      end
    end

    def save_highscore
      return if @score.score < @highscore

      File.open("highscore", "wb") do |file|
        file << Base64.encode64(@score.score.to_s)
      end

      @highscore = @score.score
    end
  end
end
