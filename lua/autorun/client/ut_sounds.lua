-- ФАЙЛ: ut_sounds.lua (ДОПОЛНЕННЫЙ)
if CLIENT then
    print("[UNDERTALE] Загрузка звуковой системы...")
    
    UT_SOUNDS = UT_SOUNDS or {}
    
    UT_SOUNDS.PATHS = {
        DAMAGE_TAKEN = "damage_taken.mp3",
        SELECT = "undertale-select-sound.mp3",
        SLASH = "undertale-slash.mp3",
        ATTACK = "undertale-attack-slash-green-screen.mp3",
        CRITICAL = "undertale-critical.mp3",
        MISS = "undertale-miss.mp3",
        TYPING = "snd_txt2.wav",
        FALLBACK = "buttons/button14.wav"
    }
    
    -- Переменная для хранения текущего звука печатания
    local currentTypingSound = nil
    
    function UT_SOUNDS.PlayDamageTaken()
        local soundPath = UT_SOUNDS.PATHS.DAMAGE_TAKEN
        if file.Exists("sound/" .. soundPath, "GAME") then
            surface.PlaySound(soundPath)
            return true
        else
            surface.PlaySound("buttons/button15.wav")
            return false
        end
    end
    
    -- НОВАЯ ФУНКЦИЯ: Звук печатания с обрезанием предыдущего
    function UT_SOUNDS.PlayTypingSound()
        local soundPath = UT_SOUNDS.PATHS.TYPING
        
        -- Если есть предыдущий звук, останавливаем его
        if currentTypingSound then
            currentTypingSound:Stop()
            currentTypingSound = nil
        end
        
        -- Воспроизводим новый звук
        if file.Exists("sound/" .. soundPath, "GAME") then
            -- Создаём звуковой канал
            local soundChannel = CreateSound(LocalPlayer(), soundPath)
            if soundChannel then
                soundChannel:Play()
                currentTypingSound = soundChannel
                
                -- Автоматически очищаем через 0.1 секунды
                timer.Simple(0.1, function()
                    if currentTypingSound then
                        currentTypingSound:Stop()
                        currentTypingSound = nil
                    end
                end)
            else
                surface.PlaySound(soundPath)
            end
            return true
        else
            surface.PlaySound("buttons/button14.wav")
            return false
        end
    end
    
    -- Альтернативный простой способ через surface.PlaySound с остановкой
    function UT_SOUNDS.PlayTypingSoundSimple()
        -- Просто воспроизводим короткий звук, он сам быстро закончится
        local soundPath = UT_SOUNDS.PATHS.TYPING
        if file.Exists("sound/" .. soundPath, "GAME") then
            surface.PlaySound(soundPath)
        else
            surface.PlaySound("buttons/button14.wav")
        end
    end 
    
    function UT_SOUNDS.Play(soundName)
        local soundPath = UT_SOUNDS.PATHS[soundName]
        if not soundPath then return false end
        if file.Exists("sound/" .. soundPath, "GAME") then
            surface.PlaySound(soundPath)
            return true
        else
            surface.PlaySound(UT_SOUNDS.PATHS.FALLBACK)
            return false
        end
    end
    
    print("[UNDERTALE] Звуковая система загружена")
end