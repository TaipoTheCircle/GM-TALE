if CLIENT then
    print("[UNDERTALE] Загрузка ФИКСИРОВАННОЙ системы боевой музыки...")

    UT_BATTLE_MUSIC = UT_BATTLE_MUSIC or {}

    UT_BATTLE_MUSIC.currentTrack = nil
    UT_BATTLE_MUSIC.isPlaying = false
    UT_BATTLE_MUSIC.soundObject = nil

    -- 🎵 СПИСОК МУЗЫКИ
    UT_BATTLE_MUSIC.tracks = {
        default = {
            "undertale/bring_it_in_guys!.mp3", 
            "undertale/enemy_approaching.mp3",
            "undertale/enemy_retreating.mp3", 
            "undertale/enemy_approaching_classic.mp3"
        },

        -- исключения под конкретных NPC
        npc = {
            ["npc_antlion_s"] = "undertale/combat_strong.mp3",
            ["npc_antlionworker"] = "undertale/combat_creepy.mp3"
        }
    }

    -- 🔊 Остановка музыки
    function UT_BATTLE_MUSIC.Stop()
        print("[UNDERTALE] Остановка музыки...")
        
        if UT_BATTLE_MUSIC.isPlaying then
            -- Останавливаем через таймер (самый надежный способ)
            timer.Remove("UT_MusicTimer")
            
            -- Пробуем остановить если есть soundObject
            if UT_BATTLE_MUSIC.soundObject then
                UT_BATTLE_MUSIC.soundObject:Stop()
                UT_BATTLE_MUSIC.soundObject = nil
            end
            
            UT_BATTLE_MUSIC.isPlaying = false
            UT_BATTLE_MUSIC.currentTrack = nil
            print("[UNDERTALE] Музыка остановлена")
        end
    end

    -- 🎶 ПРОСТОЙ запуск музыки через surface.PlaySound
    function UT_BATTLE_MUSIC.Start(enemy)
        print("[UNDERTALE] Запуск боевой музыки...")
        
        -- Всегда останавливаем предыдущую музыку
        UT_BATTLE_MUSIC.Stop()

        local track = nil

        -- 🎯 если есть враг и он в исключениях
        if enemy and enemy.class and UT_BATTLE_MUSIC.tracks.npc[enemy.class] then
            track = UT_BATTLE_MUSIC.tracks.npc[enemy.class]
            print("[UNDERTALE] Выбрана специальная музыка для: "..(enemy.class or "unknown"))
        else
            -- обычная музыка (выбираем СЛУЧАЙНУЮ доступную)
            local available_tracks = {}
            local list = UT_BATTLE_MUSIC.tracks.default
            
            -- Собираем все доступные треки
            for _, test_track in ipairs(list) do
                if file.Exists("sound/" .. test_track, "GAME") then
                    table.insert(available_tracks, test_track)
                end
            end
            
            if #available_tracks > 0 then
                -- Выбираем случайный трек из доступных
                track = available_tracks[math.random(#available_tracks)]
                print("[UNDERTALE] Выбрана случайная музыка: "..track)
                print("[UNDERTALE] Доступно треков: "..#available_tracks)
            else
                track = list[1] or "undertale/enemy_approaching.mp3"
                print("[UNDERTALE] ❌ Нет доступных треков, использую: "..track)
            end
        end

        -- ПРОВЕРЯЕМ ФАЙЛ
        print("[UNDERTALE] Проверка файла: sound/" .. track)
        
        if file.Exists("sound/" .. track, "GAME") then
            print("[UNDERTALE] ✅ Файл найден: sound/" .. track)
            
            -- ПРОСТОЙ МЕТОД: sound.PlayFile с громкостью
            sound.PlayFile("sound/" .. track, "", function(chan, err, errName)
                if IsValid(chan) then
                    print("[UNDERTALE] ✅ Музыкальный канал создан")
                    
                    -- Настройки (увеличиваем громкость до 5)
                    chan:SetVolume(0.8)
                    chan:EnableLooping(true)
                    chan:Play()
                    
                    UT_BATTLE_MUSIC.soundObject = chan
                    UT_BATTLE_MUSIC.isPlaying = true
                    UT_BATTLE_MUSIC.currentTrack = track
                    
                    -- Убираем папку из названия для отладки
                    local display_name = track:match("([^/]+)$") or track
                    print("[UNDERTALE] 🎵 Музыка играет: "..display_name)
                    -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
                    
                    -- Зацикливание через таймер
                    UT_BATTLE_MUSIC.StartMusicTimer(chan, track)
                else
                    print("[UNDERTALE] ❌ Ошибка загрузки: "..(err or "unknown").." - "..(errName or ""))
                    
                    -- ПРОБУЕМ surface.PlaySound как запасной вариант
                    print("[UNDERTALE] Пробуем surface.PlaySound...")
                    surface.PlaySound(track)
                    UT_BATTLE_MUSIC.isPlaying = true
                    UT_BATTLE_MUSIC.currentTrack = track
                    
                    -- Для surface.PlaySound делаем таймер перезапуска
                    timer.Create("UT_MusicRestartTimer", 180, 0, function()
                        if UT_BATTLE_MUSIC.isPlaying then
                            surface.PlaySound(track)
                        end
                    end)
                end
            end)
            
            return true
        else
            print("[UNDERTALE] ❌ Файл не найден: sound/" .. track)
            print("    Проверьте путь: addons/gm-tale/sound/" .. track)
            
            -- Пробуем другие треки
            local available_tracks = {}
            for _, test_track in ipairs(UT_BATTLE_MUSIC.tracks.default) do
                if file.Exists("sound/" .. test_track, "GAME") then
                    table.insert(available_tracks, test_track)
                end
            end
            
            if #available_tracks > 0 then
                track = available_tracks[math.random(#available_tracks)]
                print("[UNDERTALE] Найден альтернативный файл: "..track)
                
                -- Рекурсивно запускаем с найденным треком
                return UT_BATTLE_MUSIC.Start({class = "default"})
            else
                print("[UNDERTALE] ❌ Нет доступных музыкальных файлов!")
                -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
            end
        end
        
        return false
    end

    -- Таймер для управления музыкой
    function UT_BATTLE_MUSIC.StartMusicTimer(channel, track)
        -- Удаляем старый таймер
        timer.Remove("UT_MusicTimer")
        
        -- Создаем новый таймер для проверки состояния
        timer.Create("UT_MusicTimer", 1, 0, function()
            if not UT_BATTLE_MUSIC.isPlaying then
                timer.Remove("UT_MusicTimer")
                return
            end
            
            -- Проверяем канал
            if not IsValid(channel) then
                print("[UNDERTALE] Музыкальный канал потерян, перезапускаем...")
                UT_BATTLE_MUSIC.isPlaying = false
                UT_BATTLE_MUSIC.Start({class = "default"})
                timer.Remove("UT_MusicTimer")
            end
        end)
    end

    -- 🚪 выход из боя
    function UT_BATTLE_MUSIC.EndBattle()
        print("[UNDERTALE] Остановка боевой музыки")
        UT_BATTLE_MUSIC.Stop()
    end

    -- 🎵 ПРОВЕРКА ФАЙЛОВ
    function UT_BATTLE_MUSIC.CheckFiles()
        print("[UNDERTALE] Проверка музыкальных файлов...")
        
        local all_tracks = {}
        for _, track in ipairs(UT_BATTLE_MUSIC.tracks.default) do
            table.insert(all_tracks, track)
        end
        for _, track in pairs(UT_BATTLE_MUSIC.tracks.npc) do
            table.insert(all_tracks, track)
        end
        
        local found = 0
        for _, track in ipairs(all_tracks) do
            if file.Exists("sound/" .. track, "GAME") then
                found = found + 1
                print("  ✅ sound/" .. track)
            else
                print("  ❌ sound/" .. track)
            end
        end
        
        print("[UNDERTALE] Найдено файлов: "..found.."/"..#all_tracks)
        
        -- Проверяем основные звуки боя
        print("\n[UNDERTALE] Проверка звуков боя:")
        local battle_sounds = {
            "undertale-select-sound.mp3",
            "undertale-slash.mp3", 
            "undertale-attack-slash-green-screen.mp3",
            "undertale-critical.mp3",
            "undertale-miss.mp3"
        }
        
        for _, sound_file in ipairs(battle_sounds) do
            if file.Exists("sound/" .. sound_file, "GAME") then
                print("  ✅ " .. sound_file)
            else
                print("  ❌ " .. sound_file)
            end
        end
        
        return found > 0
    end

    -- 🎵 ТЕСТОВЫЕ КОМАНДЫ (тоже убираем сообщения в чат)
    concommand.Add("ut_test_music", function()
        print("[UNDERTALE] ===== ТЕСТ МУЗЫКИ =====")
        
        -- Сначала проверяем файлы
        UT_BATTLE_MUSIC.CheckFiles()
        
        -- Запускаем тестовую музыку
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Start then
            print("[UNDERTALE] Запускаем тестовую музыку...")
            local success = UT_BATTLE_MUSIC.Start({class = "npc_zombie"})
            
            if success then
                print("[UNDERTALE] Тест музыки запущен! ut_stop_music - остановить")
                -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
            else
                print("[UNDERTALE] Не удалось запустить музыку! Проверьте консоль.")
                -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
            end
        else
            print("[UNDERTALE] ОШИБКА: UT_BATTLE_MUSIC не загружен!")
        end
    end)

    concommand.Add("ut_stop_music", function()
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
            UT_BATTLE_MUSIC.Stop()
            print("[UNDERTALE] Музыка остановлена!")
            -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
        end
    end)

    concommand.Add("ut_music_volume", function(ply, cmd, args)
        if args[1] then
            local volume = tonumber(args[1]) or 0.5
            volume = math.Clamp(volume, 0, 1)
            
            if UT_BATTLE_MUSIC.soundObject and IsValid(UT_BATTLE_MUSIC.soundObject) then
                UT_BATTLE_MUSIC.soundObject:SetVolume(volume)
                print("[UNDERTALE] Громкость установлена: " .. volume)
            end
        end
    end)

    concommand.Add("ut_music_status", function()
        print("[UNDERTALE] ===== СТАТУС МУЗЫКИ =====")
        print("isPlaying: " .. tostring(UT_BATTLE_MUSIC.isPlaying))
        print("currentTrack: " .. (UT_BATTLE_MUSIC.currentTrack or "нет"))
        print("soundObject: " .. (IsValid(UT_BATTLE_MUSIC.soundObject) and "валиден" or "не валиден"))
        
        if UT_BATTLE_MUSIC.isPlaying then
            local display_name = UT_BATTLE_MUSIC.currentTrack and UT_BATTLE_MUSIC.currentTrack:match("([^/]+)$") or "неизвестно"
            print("[UNDERTALE] Сейчас играет: " .. display_name)
            -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
        else
            print("[UNDERTALE] Музыка не играет")
            -- УБРАЛИ СООБЩЕНИЕ В ЧАТ
        end
    end)

    -- КОМАНДА ДЛЯ ПРОВЕРКИ СТРУКТУРЫ
    concommand.Add("ut_check_sounds", function()
        print("[UNDERTALE] ===== ПРОВЕРКА СТРУКТУРЫ ЗВУКОВ =====")
        
        -- Проверяем папку undertale
        local files = file.Find("sound/undertale/*", "GAME")
        
        print("Папка sound/undertale/:")
        if files and #files > 0 then
            for _, f in ipairs(files) do
                print("  " .. f)
            end
        else
            print("  ПУСТО! Файлы не найдены")
        end
        
        -- Проверяем корень sound
        print("\nКорень sound/:")
        local root_files = file.Find("sound/*.mp3", "GAME")
        if root_files and #root_files > 0 then
            for _, f in ipairs(root_files) do
                if string.match(f, "undertale") then
                    print("  " .. f)
                end
            end
        end
    end)

    -- Автопроверка при загрузке (убираем сообщение в чат)
    timer.Simple(5, function()
        print("[UNDERTALE] Автопроверка музыкальных файлов...")
        UT_BATTLE_MUSIC.CheckFiles()
    end)

    print("[UNDERTALE] Фиксированная система боевой музыки загружена (без чата)")
    
    -- Простой тест через 15 секунд (убираем сообщение в чат)
    timer.Simple(15, function()
        print("[UNDERTALE] Введите ut_test_music для проверки музыки")
    end)
end