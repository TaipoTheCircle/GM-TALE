-- ФАЙЛ: ut_nihilanth_battle.lua
-- СПЕЦИАЛЬНАЯ БИТВА С НИХИЛАНТОМ (как с Азриэлем)
if CLIENT then
    print("[UNDERTALE] Загрузка битвы с Нихилантом...")
    
    UT_NIHILANTH_BATTLE = UT_NIHILANTH_BATTLE or {}
    
    -- Состояние битвы
    UT_NIHILANTH_BATTLE.isActive = false
    UT_NIHILANTH_BATTLE.phase = 1
    UT_NIHILANTH_BATTLE.rainbowTimer = 0
    UT_NIHILANTH_BATTLE.enemyX = 0
    UT_NIHILANTH_BATTLE.enemyY = 0
    UT_NIHILANTH_BATTLE.angle = 0
    UT_NIHILANTH_BATTLE.radius = 350        -- Радиус полёта
    UT_NIHILANTH_BATTLE.speed = 1.2         -- Скорость полёта
    
    -- Цвета для радужного фона
    UT_NIHILANTH_BATTLE.rainbowColors = {
        Color(255, 0, 0),      -- Красный
        Color(255, 127, 0),    -- Оранжевый
        Color(255, 255, 0),    -- Жёлтый
        Color(0, 255, 0),      -- Зелёный
        Color(0, 0, 255),      -- Синий
        Color(75, 0, 130),     -- Индиго
        Color(148, 0, 211)     -- Фиолетовый
    }
    
    -- Материал для Нихиланта
    UT_NIHILANTH_BATTLE.nihilanthMaterial = nil
    
    -- ===== ЗАГРУЗКА ТЕКСТУРЫ НИХИЛАНТА =====
    function UT_NIHILANTH_BATTLE.LoadTexture()
        local paths = {
            "nihilanth/nihilanth.png",
            "enemies/nihilanth/enemy.png",
            "undertale/nihilanth.png"
        }
        for _, path in ipairs(paths) do
            if file.Exists("materials/" .. path, "GAME") then
                local mat = Material(path)
                if not mat:IsError() then
                    UT_NIHILANTH_BATTLE.nihilanthMaterial = mat
                    print("[UNDERTALE] Загружена текстура Нихиланта: " .. path)
                    return
                end
            end
        end
        print("[UNDERTALE] Текстура Нихиланта не найдена, будет использована резервная отрисовка")
    end
    
    -- ===== РАДУЖНЫЙ ФОН С РАСПЛЫВАНИЕМ ОТ ЦЕНТРА =====
    -- ===== РАДУЖНЫЙ ФОН С РАСПЛЫВАНИЕМ ОТ ЦЕНТРА =====
    function UT_NIHILANTH_BATTLE.DrawRainbowBackground()
        local w, h = ScrW(), ScrH()
        UT_NIHILANTH_BATTLE.rainbowTimer = UT_NIHILANTH_BATTLE.rainbowTimer + FrameTime() * 2.5
        
        -- Центр экрана
        local centerX = w / 2
        local centerY = h / 2
        
        -- Рисуем радиальные полосы (прямоугольниками вместо кругов)
        local numBars = 60
        
        for i = 0, numBars do
            local progress = i / numBars
            local angle = math.rad(i * 6 + UT_NIHILANTH_BATTLE.rainbowTimer * 50)
            
            -- Цвет зависит от угла
            local colorIndex = math.floor((i + UT_NIHILANTH_BATTLE.rainbowTimer * 10) % #UT_NIHILANTH_BATTLE.rainbowColors) + 1
            local color = UT_NIHILANTH_BATTLE.rainbowColors[colorIndex]
            
            -- Плавное затухание к краям
            local alpha = 255 * (1 - math.abs(progress - 0.5) * 1.2)
            alpha = math.Clamp(alpha, 80, 255)
            
            -- Рисуем сектор (треугольник от центра)
            local len1 = 100
            local len2 = math.sqrt(w^2 + h^2)
            
            local x1 = centerX + math.cos(angle - 0.05) * len1
            local y1 = centerY + math.sin(angle - 0.05) * len1
            local x2 = centerX + math.cos(angle + 0.05) * len1
            local y2 = centerY + math.sin(angle + 0.05) * len1
            local x3 = centerX + math.cos(angle + 0.05) * len2
            local y3 = centerY + math.sin(angle + 0.05) * len2
            local x4 = centerX + math.cos(angle - 0.05) * len2
            local y4 = centerY + math.sin(angle - 0.05) * len2
            
            surface.SetDrawColor(color.r, color.g, color.b, alpha)
            surface.DrawPoly({
                {x = x1, y = y1},
                {x = x2, y = y2},
                {x = x3, y = y3},
                {x = x4, y = y4}
            })
        end
        
        -- Рисуем волны цвета (круги с заливкой)
        for ring = 1, 8 do
            local radius = ring * 80 + UT_NIHILANTH_BATTLE.rainbowTimer * 50
            radius = radius % 500
            
            local colorIndex = ring % #UT_NIHILANTH_BATTLE.rainbowColors + 1
            local color = UT_NIHILANTH_BATTLE.rainbowColors[colorIndex]
            
            surface.SetDrawColor(color.r, color.g, color.b, 80)
            -- Рисуем круг через множество линий (так как DrawCircle не работает)
            for ang = 0, 360, 15 do
                local rad = math.rad(ang)
                local x1 = centerX + math.cos(rad) * radius
                local y1 = centerY + math.sin(rad) * radius
                local x2 = centerX + math.cos(rad + math.rad(15)) * radius
                local y2 = centerY + math.sin(rad + math.rad(15)) * radius
                surface.DrawLine(x1, y1, x2, y2)
            end
        end
        
        -- Наложение тёмной вуали
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end
    
    -- ===== ФУНКЦИЯ ДЛЯ РИСОВАНИЯ НИХИЛАНТА (увеличенный размер) =====
    function UT_NIHILANTH_BATTLE.DrawNihilanth(w, h)
        -- Движение по траектории в виде бесконечности (лемниската)
        UT_NIHILANTH_BATTLE.angle = UT_NIHILANTH_BATTLE.angle + FrameTime() * UT_NIHILANTH_BATTLE.speed
        
        -- Формула лемнискаты
        local t = UT_NIHILANTH_BATTLE.angle
        local a = UT_NIHILANTH_BATTLE.radius
        
        local denominator = 1 + math.sin(t)^2
        local xOffset = a * math.cos(t) / denominator
        local yOffset = a * math.sin(t) * math.cos(t) / denominator * 0.8  -- чуть меньше по вертикали
        
        UT_NIHILANTH_BATTLE.enemyX = w/2 + xOffset
        UT_NIHILANTH_BATTLE.enemyY = h * 0.35 + yOffset
        
        -- УВЕЛИЧЕННЫЙ РАЗМЕР!
        local enemySize = 350    -- Было 200, стало 350 (больше)
        
        -- Эффект пульсации
        local pulse = math.sin(CurTime() * 3) * 0.03 + 1
        local drawSize = enemySize * pulse
        
        -- Рисуем Нихиланта
        if UT_NIHILANTH_BATTLE.nihilanthMaterial then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(UT_NIHILANTH_BATTLE.nihilanthMaterial)
            surface.DrawTexturedRect(
                UT_NIHILANTH_BATTLE.enemyX - drawSize/2,
                UT_NIHILANTH_BATTLE.enemyY - drawSize/2,
                drawSize, drawSize
            )
        else
            -- Резервная отрисовка (пурпурный шар с глазами) — тоже увеличенная
            surface.SetDrawColor(150, 0, 255, 255)
            surface.DrawRect(
                UT_NIHILANTH_BATTLE.enemyX - drawSize/2,
                UT_NIHILANTH_BATTLE.enemyY - drawSize/2,
                drawSize, drawSize
            )
            
            -- Глаза (пропорционально увеличены)
            local eyeSize = 60
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(
                UT_NIHILANTH_BATTLE.enemyX - 70,
                UT_NIHILANTH_BATTLE.enemyY - 50,
                eyeSize, eyeSize
            )
            surface.DrawRect(
                UT_NIHILANTH_BATTLE.enemyX + 10,
                UT_NIHILANTH_BATTLE.enemyY - 50,
                eyeSize, eyeSize
            )
            
            -- Зрачки
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(
                UT_NIHILANTH_BATTLE.enemyX - 60,
                UT_NIHILANTH_BATTLE.enemyY - 40,
                40, 40
            )
            surface.DrawRect(
                UT_NIHILANTH_BATTLE.enemyX + 20,
                UT_NIHILANTH_BATTLE.enemyY - 40,
                40, 40
            )
            
            -- Рот
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(
                UT_NIHILANTH_BATTLE.enemyX - 40,
                UT_NIHILANTH_BATTLE.enemyY + 30,
                80, 25
            )
        end
        
        return UT_NIHILANTH_BATTLE.enemyX, UT_NIHILANTH_BATTLE.enemyY, enemySize
    end
    
    -- ===== ПОЛУЧЕНИЕ АТАК ДЛЯ НИХИЛАНТА =====
    function UT_NIHILANTH_BATTLE.GetAttacks()
        return {
            { type = "Projectile", count = 10, speed = 280, damage = 3, color = Color(255, 0, 255), size = 25 },
            { type = "Circle", count = 28, speed = 220, damage = 2, radius = 400, color = Color(255, 100, 0) },
            { type = "Rain", count = 25, speed = 320, damage = 3, size = 20, color = Color(0, 255, 255) },
            { type = "Homing", count = 6, speed = 200, damage = 2, homingStrength = 2, color = Color(255, 50, 255) }
        }
    end

        -- ===== ПОКАЗАТЬ ДИАЛОГ =====
    function UT_NIHILANTH_BATTLE.ShowDialog(lines, onComplete)
        if not lines or #lines == 0 then
            if onComplete then onComplete() end
            return
        end
        
        local lineIndex = 1
        
        local function ShowNextLine()
            if lineIndex > #lines then
                if onComplete then onComplete() end
                return
            end
            
            if UT_BATTLE_HUD and UT_BATTLE_HUD.ShowTypingDialogText then
                UT_BATTLE_HUD.ShowTypingDialogText(lines[lineIndex], UT_BATTLE_CORE.dialogPanel, function()
                    lineIndex = lineIndex + 1
                    timer.Simple(0.8, ShowNextLine)
                end)
            else
                -- Fallback, если функции нет
                chat.AddText(Color(255, 255, 255), lines[lineIndex])
                lineIndex = lineIndex + 1
                timer.Simple(1.5, ShowNextLine)
            end
        end
        
        ShowNextLine()
    end
    
function UT_NIHILANTH_BATTLE.Start()
        print("[UNDERTALE] Запуск битвы с Нихилантом!")
        
        if not UT_BATTLE_CORE then
            print("[UNDERTALE] ОШИБКА: UT_BATTLE_CORE не найден!")
            return
        end
        
        -- Останавливаем все старые системы сердца
        if UT_HEART_CORE then
            UT_HEART_CORE.is_active = false
            UT_HEART_CORE.StopHeartPhase()
            hook.Remove("HUDPaint", "UT_HeartPhaseDraw")
            hook.Remove("Think", "UT_HeartPhaseThink")
        end
        
        if UT_HEART_SIMPLE then
            UT_HEART_SIMPLE.Stop()
        end
        
        if UT_HEART_SYSTEM then
            UT_HEART_SYSTEM.isActive = false
            UT_HEART_SYSTEM.StopHeartPhase()
        end
        
        -- ⚠️ ВАЖНО: ОЧИЩАЕМ СПИСОК ВРАГОВ И ДОБАВЛЯЕМ ТОЛЬКО НИХИЛАНТА!
        UT_BATTLE_CORE.currentTargets = {}
        UT_BATTLE_CORE.currentEnemy = nil
        
        -- Добавляем Нихиланта как единственного врага
table.insert(UT_BATTLE_CORE.currentTargets, {
    name = "НИХИЛАНТ",
    hp = 150,
    maxhp = 150,
    class = "npc_nihilanth",  -- ← Теперь данные берутся из UT_ENEMY_DATA!
    isBoss = true,
    attacks = UT_NIHILANTH_BATTLE.GetAttacks(),
    dialog = {
        "* НИХИЛАНТ...",
        "* ОГРОМНЫЙ ТИТАН",
        "* БУДЬТЕ ОСТОРОЖНЫ!"
    }
})
        
        UT_BATTLE_CORE.currentEnemy = {
            entity = nil,
            data = UT_BATTLE_CORE.currentTargets[1],
            currentAttack = 1
        }
        
        UT_NIHILANTH_BATTLE.isActive = true
        UT_NIHILANTH_BATTLE.phase = 1
        UT_NIHILANTH_BATTLE.rainbowTimer = 0
        UT_NIHILANTH_BATTLE.angle = 0
        UT_NIHILANTH_BATTLE.LoadTexture()
        
        -- Останавливаем текущую музыку
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
            UT_BATTLE_MUSIC.Stop()
        end
        
        -- Запускаем музыку Нихиланта
        local musicTracks = {
            "nihilanth/battle.mp3",
            "undertale/hopes_and_dreams.mp3",
            "nihilanth/nihilanth_battle.mp3",
            "undertale/megalovania.mp3"
        }
        for _, track in ipairs(musicTracks) do
            if file.Exists("sound/" .. track, "GAME") then
                sound.PlayFile("sound/" .. track, "", function(chan, err)
                    if IsValid(chan) then
                        chan:SetVolume(0.7)
                        chan:EnableLooping(true)
                        chan:Play()
                        UT_NIHILANTH_BATTLE.musicChannel = chan
                    end
                end)
                break
            end
        end
        
        -- Создаём боевое меню (оно подхватит currentTargets с Нихилантом)
        if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
            UT_BATTLE_HUD.CreateBattleMenu()
        end
        
        -- Модифицируем отрисовку боевого фрейма после создания меню
        timer.Simple(0.1, function()
            if IsValid(UT_BATTLE_CORE.battleFrame) then
                UT_BATTLE_CORE.battleFrame.Paint = function(self, w, h)
                    -- Радужный фон
                    UT_NIHILANTH_BATTLE.DrawRainbowBackground()
                    
                    -- Рисуем Нихиланта
                    UT_NIHILANTH_BATTLE.DrawNihilanth(w, h)
                    
                    -- Рисуем эффекты
                    if UT_DAMAGE_EFFECT and UT_DAMAGE_EFFECT.DrawEffectsOnPanel then
                        UT_DAMAGE_EFFECT.DrawEffectsOnPanel()
                    end
                    
                    -- Затемнение внизу
                    local dialogY = ScrH() * 0.55
                    surface.SetDrawColor(0, 0, 0, 180)
                    surface.DrawRect(0, dialogY - 50, w, h - dialogY + 50)
                    
                    for i = 0, 50 do
                        local alpha = 255 * (1 - i/50)
                        surface.SetDrawColor(0, 0, 0, alpha)
                        surface.DrawRect(0, i, w, 1)
                    end
                    
                    draw.SimpleText("NIHILANTH BATTLE", "UT_Small", 20, 20, 
                        Color(255, 100, 255, 150))
                end
            end
        end)
        
        -- Показываем диалог
        UT_NIHILANTH_BATTLE.ShowDialog({
            "* ...",
            "* Вы чувствуете присутствие...",
            "* НИХИЛАНТ.",
            "* Будьте осторожны!"
        }, function()
            UT_NIHILANTH_BATTLE.StartPhase()
        end)
    end
    
    -- ===== НАЧАТЬ ФАЗУ АТАКИ =====
    function UT_NIHILANTH_BATTLE.StartPhase()
        if not UT_NIHILANTH_BATTLE.isActive then return end
        
        local attacks = UT_NIHILANTH_BATTLE.GetAttacks()
        local attackIndex = (UT_NIHILANTH_BATTLE.phase - 1) % #attacks + 1
        local attack = attacks[attackIndex]
        
        local bounds = {
            left = ScrW()/2 - 430,
            right = ScrW()/2 + 430,
            top = ScrH()/2 - 150,
            bottom = ScrH()/2 + 150
        }
        
        -- Создаём снаряды для атаки
        local bullets = {}
        if UT_CUSTOM_ATTACKS then
            local nihilanthDummy = { class = "nihilanth", customAttacks = { attack } }
            bullets = UT_CUSTOM_ATTACKS.CreateAttack(nihilanthDummy, attack)
        end
        
        UT_HEART_SYSTEM.StartHeartPhase("RED", bounds,
            function(damage)
                UT_BATTLE_CORE.playerHp = math.max(0, UT_BATTLE_CORE.playerHp - (damage or 3))
                if UT_BATTLE_CORE.playerHp <= 0 then
                    UT_NIHILANTH_BATTLE.GameOver()
                end
            end,
            function()
                UT_NIHILANTH_BATTLE.NextPhase()
            end,
            { bullets = bullets, duration = 10 }
        )
    end
    
    -- ===== СЛЕДУЮЩАЯ ФАЗА =====
    function UT_NIHILANTH_BATTLE.NextPhase()
        if not UT_NIHILANTH_BATTLE.isActive then return end
        
        UT_NIHILANTH_BATTLE.phase = UT_NIHILANTH_BATTLE.phase + 1
        
        if UT_NIHILANTH_BATTLE.phase > 8 then
            UT_NIHILANTH_BATTLE.EndBattle(true)
        else
            timer.Simple(1, function()
                UT_NIHILANTH_BATTLE.StartPhase()
            end)
        end
    end
    
    -- ===== ЗАВЕРШЕНИЕ БИТВЫ =====
    function UT_NIHILANTH_BATTLE.EndBattle(victory)
        UT_NIHILANTH_BATTLE.isActive = false
        
        if UT_NIHILANTH_BATTLE.musicChannel and IsValid(UT_NIHILANTH_BATTLE.musicChannel) then
            UT_NIHILANTH_BATTLE.musicChannel:Stop()
        end
        
        if victory then
            UT_NIHILANTH_BATTLE.ShowDialog({
                "* ...",
                "* Нихилант повержен!",
                "* Вы освободили...",
                "* ...всех?"
            }, function()
                if UT_BATTLE_CORE then
                    UT_BATTLE_CORE.EndBattle(true)
                end
            end)
        else
            UT_NIHILANTH_BATTLE.GameOver()
        end
    end
    
    -- ===== GAME OVER =====
    function UT_NIHILANTH_BATTLE.GameOver()
        UT_NIHILANTH_BATTLE.isActive = false
        
        if UT_BATTLE_HUD then
            UT_BATTLE_HUD.AddHeartMessage("* Поражение...")
        end
        
        timer.Simple(3, function()
            if UT_BATTLE_CORE then
                UT_BATTLE_CORE.StopAllSystems()
            end
        end)
    end
    
    -- ===== ТРИГГЕР ДЛЯ НИХИЛАНТА =====
    function UT_NIHILANTH_BATTLE.CheckForNihilanth()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        local nihilanthClasses = {
            "monster_nihilanth",
            "npc_vj_hlr1_nihilanth",
            "npc_vj_hlr1a_nihilanth",
            "monster_alien_nihilanth"
        }
        
        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 500)) do
            for _, className in ipairs(nihilanthClasses) do
                if ent:GetClass() == className and not ent.NihilanthTriggered then
                    ent.NihilanthTriggered = true
                    print("[UNDERTALE] Обнаружен Нихилант! Запуск специальной битвы!")
                    UT_NIHILANTH_BATTLE.Start()
                    return true
                end
            end
        end
        return false
    end
    
    -- Добавляем проверку в триггер
    local oldFindEnemies = UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.FindEnemies
    if UT_BATTLE_TRIGGER then
        UT_BATTLE_TRIGGER.FindEnemies = function()
            if UT_NIHILANTH_BATTLE.CheckForNihilanth() then
                return
            end
            if oldFindEnemies then
                oldFindEnemies()
            end
        end
    end
    
    -- Команда для ручного запуска
    concommand.Add("ut_nihilanth", function()
        UT_NIHILANTH_BATTLE.Start()
    end)
    
    print("[UNDERTALE] Битва с Нихилантом загружена")
end