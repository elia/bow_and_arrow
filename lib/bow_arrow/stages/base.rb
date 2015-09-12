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

module BowArrow
  module Stages
    class Base
      include Elements
      include StateMachine

      attr_reader :game

      def self.add_states(base)
        base.add_state :briefing do |elapsed|
          show_briefing elapsed
        end

        base.add_state :running do |elapsed|
          run elapsed
        end

        base.add_state :fail do |elapsed|
          show_fail elapsed
        end
      end

      def self.inherited(base)
        add_states base
      end

      def initialize(game)
        @game = game

        @hero = Hero.new app
        @enemies = Collection.new

        @state = false
        @paper = Paper.new app

        @briefing = ""
        @fail = ""

        app.click do
          @current_state = :running
          @hero.active_events
        end

        start_level
      end

      def start_level
        #implement in subclasses
      end

      def app
        @game.app
      end

      def show_message(message, elapsed)
        @paper.text = message
        @paper.draw elapsed
      end

      def show_briefing(elapsed)
        show_message @briefing, elapsed
      end

      def show_fail(elapsed)
        message = @hero.dead? ? @fail : "You ran out of arrows..."
        show_message message, elapsed
      end

      def arrows_left
        @hero.arrows_left
      end

      def run elapsed
        stage_loop elapsed

        @hero.draw elapsed

        @enemies.each do |enemy|
          next if enemy.dead?

          if @hero & enemy
            @hero.hit
          end

          @hero.arrows.each do |arrow|
            if arrow & enemy
              arrow.destroy if enemy.hit
              @game.score << 100 * @game.level
            end
          end
        end

        @enemies.draw elapsed
        @enemies.compact!

        @game.score.draw elapsed

        if win?
          @game.next
        elsif lose?
          @current_state = :fail

          app.click do
            @game.restart
          end
        end
      end

      def stage_loop(elapsed)
        #implement in stage
      end

      def win?
        @enemies.length == 0
      end

      def lose?
        @hero.dead? or @hero.empty_quiver?
      end
    end
  end
end
