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
  module Elements
    class Hero < Base
      include StateMachine
      
      attr_reader :arrows
      
      def initialize *args
        super *args
        
        @arrows = []
        
        app.click do
          @current_state = :armed if @current_state == :stand
        end
        
        app.release do
          if @current_state == :armed
            shot_arrow
            
            @waiting_from = Time.now
            @current_state = :waiting
          end
        end
      end
      
      add_state :stand do
        draw_image "hero_stand.png"
      end
      
      add_state :armed do
        @y += 1
        
        draw_image "hero_armed.png"
      end
      
      add_state :waiting do
        draw_image "hero_without_arrow.png"
        
        @current_state = :stand if (Time.now - @waiting_from) > 0.2
      end
      
      def shot_arrow
        arrow = Arrow.new app
        arrow.x = @x + 60
        arrow.y = @y + 39
        
        @arrows << arrow
      end
      
      alias :old_draw :draw
      
      def draw
        @y = app.mouse[2] - 42
        
        old_draw
        
        @arrows.reject! { |arrow| arrow.dead? }
        @arrows.each { |arrow| arrow.draw }
      end
    end
  end
end