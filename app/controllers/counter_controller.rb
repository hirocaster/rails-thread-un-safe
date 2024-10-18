class CounterController < ApplicationController
  @@count = 0

  def increment
    sleep(rand) # ランダムな遅延を追加して競合の可能性を高める
    @@count += 1
    render json: { count: @@count }
  end

  def get_count
    render json: { count: @@count }
  end
end
