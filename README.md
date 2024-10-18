# README

Rack app の software を非スレッドセーフなコードで検証

## puma

クラスターモード(マルチプロセス+マルチスレッド)でリクエストを処理する。
MRI(CRuby)だとGVLがあるのでRuby VMが完全に並列で動作すると不都合がある。
JRuby/Rubiniusで動作させれば、完全に並列で動作することができる。
最近のJRuby+Railsは完全に並列で動作する。

では、MRIで利用するメリットは無いのでは？と思うかもしれないが、DBやキャッ
シュストア、ファイルへのI/Oなど、RubyがOSからのwaitしている部分に別ス
レッドが別リクエストを処理することができるので、全体としては高速化され
る。一方で、スレッドが多すぎるとGVLでロックの取り合いになり、全体の処
理性能が落ちてしまうので、注意すること。

また、Railsでは各スレッドはスレッドの数だけDBに接続していくものと考え
た方が良いので、Pumaからはプロセス数xスレッド数のDBコネクションが必要
になるため、コネクションの枯渇や使いすぎには注意すること。

### 3thread

```puma
❯ rails s

❯ ruby check_counter.rb
Final count: 98
Expected count: 100
Actual unique counts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
```

### 2worker 3thread

```
❯ rails s
=> Booting Puma
=> Rails 7.2.1.1 application starting in development
=> Run `bin/rails server --help` for more startup options
[567] Puma starting in cluster mode...
[567] * Puma version: 6.4.3 (ruby 3.3.5-p100) ("The Eagle of Durango")
[567] *  Min threads: 3
[567] *  Max threads: 3
[567] *  Environment: development
[567] *   Master PID: 567
[567] *      Workers: 2
[567] *     Restarts: (✔) hot (✔) phased
[567] * Listening on http://127.0.0.1:3000
[567] * Listening on http://[::1]:3000
[567] Use Ctrl-C to stop
[567] - Worker 0 (PID: 717) booted in 0.0s, phase: 0
[567] - Worker 1 (PID: 721) booted in 0.0s, phase: 0

❯ ruby check_counter.rb
Final count: 51
Expected count: 100
Actual unique counts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
```

## unicorn 6.1.0

```
❯ bundle exec unicorn -c config/unicorn.rb

❯ time ruby check_counter.rb
Final count: 100
Expected count: 100
Actual unique counts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
ruby check_counter.rb  0.16s user 0.04s system 0% cpu 48.924 total
```

### worker_processes=2

```unicorn
# worker_processes=2
❯ bundle exec unicorn -c config/unicorn.rb

❯ time ruby check_counter.rb
Final count: 51
Expected count: 100
Actual unique counts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
ruby check_counter.rb  0.20s user 0.04s system 0% cpu 26.055 total
```

## pitchfork

```
❯ bundle exec pitchfork -p 3000
I, [2024-10-18T16:19:19.219078 #20426]  INFO -- [Pitchfork]: listening on addr=0.0.0.0:3000 fd=10
I, [2024-10-18T16:19:19.219162 #20426]  INFO -- [Pitchfork]: mold gen=0 pid=20426 spawned
I, [2024-10-18T16:19:19.219560 #20283]  INFO -- [Pitchfork]: mold pid=20426 gen=0 ready
I, [2024-10-18T16:19:19.219657 #20283]  INFO -- [Pitchfork]: Monitor pid=20283 ready
I, [2024-10-18T16:19:19.219705 #20283]  INFO -- [Pitchfork]: master process ready
I, [2024-10-18T16:19:19.219929 #20426]  INFO -- [Pitchfork]: worker=0 gen=0 spawning...
I, [2024-10-18T16:19:19.224404 #20434]  INFO -- [Pitchfork]: worker=0 gen=0 pid=20434 spawned
I, [2024-10-18T16:19:19.224460 #20283]  INFO -- [Pitchfork]: worker=0 pid=20434 gen=0 registered
I, [2024-10-18T16:19:19.224585 #20434]  INFO -- [Pitchfork]: worker=0 gen=0 ready

❯ ruby check_counter.rb
Final count: 100
Expected count: 100
Actual unique counts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
```

### worker_processes=2

```
❯ bundle exec pitchfork -c config/pitchfork.rb
I, [2024-10-18T16:28:44.634781 #13411]  INFO -- [Pitchfork]: listening on addr=0.0.0.0:3000 fd=10
I, [2024-10-18T16:28:44.634870 #13411]  INFO -- [Pitchfork]: mold gen=0 pid=13411 spawned
I, [2024-10-18T16:28:44.635262 #13268]  INFO -- [Pitchfork]: mold pid=13411 gen=0 ready
I, [2024-10-18T16:28:44.635355 #13268]  INFO -- [Pitchfork]: Monitor pid=13268 ready
I, [2024-10-18T16:28:44.635384 #13268]  INFO -- [Pitchfork]: master process ready
I, [2024-10-18T16:28:44.635613 #13411]  INFO -- [Pitchfork]: worker=0 gen=0 spawning...
I, [2024-10-18T16:28:44.639949 #13419]  INFO -- [Pitchfork]: worker=0 gen=0 pid=13419 spawned
I, [2024-10-18T16:28:44.640082 #13268]  INFO -- [Pitchfork]: worker=0 pid=13419 gen=0 registered
I, [2024-10-18T16:28:44.640122 #13419]  INFO -- [Pitchfork]: worker=0 gen=0 ready
I, [2024-10-18T16:28:44.657393 #13411]  INFO -- [Pitchfork]: worker=1 gen=0 spawning...
I, [2024-10-18T16:28:44.662542 #13268]  INFO -- [Pitchfork]: worker=1 pid=13425 gen=0 registered
I, [2024-10-18T16:28:44.662504 #13425]  INFO -- [Pitchfork]: worker=1 gen=0 pid=13425 spawned
I, [2024-10-18T16:28:44.662731 #13425]  INFO -- [Pitchfork]: worker=1 gen=0 ready

❯ ruby check_counter.rb
Final count: 49
Expected count: 100
Actual unique counts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
```

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
