-- ФАЙЛ: ut_sans_battle.lua (СПЕЦИАЛЬНАЯ БИТВА С САНСОМ/КЛЯЙНЕРОМ)
if CLIENT then
    print("[UNDERTALE] Загрузка битвы с Сансом...")

        -- ВАЖНО: Проверяем что UT_BATTLE_CORE существует
    if not UT_BATTLE_CORE then
        print("[UNDERTALE] ОШИБКА: UT_BATTLE_CORE не загружен!")
        return
    end
    
    UT_SANS_BATTLE = UT_SANS_BATTLE or {}
    
    -- Состояние битвы с Сансом
    UT_SANS_BATTLE.isActive = false
    UT_SANS_BATTLE.phase = 1
    UT_SANS_BATTLE.attackIndex = 1
    UT_SANS_BATTLE.lastFrameTime = 0
    UT_SANS_BATTLE.karma = 0  -- Очки кармы (полученный урон)
    UT_SANS_BATTLE.menuSkip = 0  -- Пропуск меню
    
    -- Паттерны атак Санса (как в оригинале)
    UT_SANS_BATTLE.attacks = {
        -- Фаза 1: Костяная стена
        {
            name = "КОСТЯНАЯ СТЕНА",
            duration = 4,
            heartColor = "BLUE",
            patterns = {
                { type = "BONES_HORIZONTAL", count = 5, speed = 200, gap = 60 },
                { type = "BONES_VERTICAL", count = 3, speed = 250, gap = 80 }
            }
        },
        -- Фаза 2: ГАСТЕР БЛАСТЕРЫ
        {
            name = "ГАСТЕР БЛАСТЕР",
            duration = 5,
            heartColor = "BLUE",
            patterns = {
                { type = "GASTER_BLASTER", count = 3, delay = 0.8, warning = true }
            }
        },
        -- Фаза 3: Костяной дождь
        {
            name = "КОСТЯНОЙ ДОЖДЬ",
            duration = 6,
            heartColor = "BLUE",
            patterns = {
                { type = "BONES_RAIN", count = 20, speed = 300, interval = 0.15 }
            }
        },
        -- Фаза 4: Комбо из всего
        {
            name = "ПЕЧАЛЬНЫЙ КОМБО",
            duration = 8,
            heartColor = "RED",
            patterns = {
                { type = "BONES_HORIZONTAL", count = 8, speed = 250, gap = 50 },
                { type = "BONES_VERTICAL", count = 4, speed = 300, gap = 70 },
                { type = "GASTER_BLASTER", count = 2, delay = 1.0, warning = true }
            }
        }
    }
    
    -- Функция смены цвета души (синий/красный)
    UT_SANS_BATTLE.heartCycle = 0
    UT_SANS_BATTLE.switchTimer = 0
    
    function UT_SANS_BATTLE.UpdateHeartColor()
        local currentTime = CurTime()
        
        -- Меняем цвет каждые 2-3 секунды
        if currentTime - UT_SANS_BATTLE.switchTimer > math.random(2, 3) then
            UT_SANS_BATTLE.switchTimer = currentTime
            UT_SANS_BATTLE.heartCycle = UT_SANS_BATTLE.heartCycle + 1
            
            if UT_SANS_BATTLE.heartCycle % 2 == 0 then
                UT_HEART_SYSTEM.SetHeartType("RED")
            else
                UT_HEART_SYSTEM.SetHeartType("BLUE")
            end
        end
    end
    
    -- Создание снарядов для атаки Санса
    function UT_SANS_BATTLE.CreateBullets(pattern, waveIndex)
        local bullets = {}
        local heartPos = {
            x = ScrW() / 2,
            y = ScrH() * 0.55 + 125
        }
        
        if pattern.type == "BONES_HORIZONTAL" then
            -- Горизонтальные кости (летят справа налево или слева направо)
            for i = 1, pattern.count do
                local direction = math.random(1, 2)
                local startX = direction == 1 and ScrW() + 50 or -50
                local targetX = direction == 1 and -50 or ScrW() + 50
                local y = heartPos.y + (i - pattern.count/2) * pattern.gap - 100
                
                table.insert(bullets, {
                    x = startX,
                    y = y,
                    targetX = targetX,
                    targetY = y,
                    speed = pattern.speed,
                    width = 40,
                    height = 15,
                    type = "BONE",
                    color = Color(240, 240, 255),
                    damage = 4
                })
            end
            
        elseif pattern.type == "BONES_VERTICAL" then
            -- Вертикальные кости (летят сверху вниз)
            for i = 1, pattern.count do
                local x = heartPos.x + (i - pattern.count/2) * pattern.gap
                
                table.insert(bullets, {
                    x = x,
                    y = -50,
                    targetX = x,
                    targetY = ScrH() + 50,
                    speed = pattern.speed,
                    width = 15,
                    height = 40,
                    type = "BONE",
                    color = Color(240, 240, 255),
                    damage = 4
                })
            end
            
        elseif pattern.type == "BONES_RAIN" then
            -- Костяной дождь (кости падают сверху)
            for i = 1, pattern.count do
                local x = math.random(100, ScrW() - 100)
                local delay = (i - 1) * pattern.interval
                
                table.insert(bullets, {
                    x = x,
                    y = -50 - delay * 200,
                    targetX = x,
                    targetY = ScrH() + 50,
                    speed = pattern.speed,
                    width = 20,
                    height = 40,
                    type = "BONE",
                    color = Color(240, 240, 255),
                    damage = 3,
                    delay = delay
                })
            end
            
        elseif pattern.type == "GASTER_BLASTER" then
            -- Гастер бластеры
            local positions = {
                {x = ScrW()/4, y = 100, angle = 0},
                {x = ScrW()*3/4, y = 100, angle = 0},
                {x = ScrW()/2, y = 50, angle = 0},
                {x = 100, y = ScrH()/2, angle = 90},
                {x = ScrW() - 100, y = ScrH()/2, angle = -90}
            }
            
            for i = 1, math.min(pattern.count, #positions) do
                local pos = positions[i]
                local warningTime = (i - 1) * (pattern.delay or 0.5)
                
                table.insert(bullets, {
                    x = pos.x,
                    y = pos.y,
                    targetX = heartPos.x,
                    targetY = heartPos.y,
                    speed = 800,
                    width = 60,
                    height = 60,
                    type = "GASTER",
                    color = Color(255, 100, 0),
                    damage = 8,
                    warning = true,
                    warningTime = warningTime,
                    angle = pos.angle
                })
            end
        end
        
        return bullets
    end
    
    -- Диалоги Санса (как в оригинале)
    UT_SANS_BATTLE.dialogs = {
        start = {
            "*хех...",
            "*ты думал я буду просто стоять?",
            "*получай."
        },
        phase2 = {
            "*...",
            "*ты серьёзно?",
            "*ладно, давай повеселимся."
        },
        phase3 = {
            "*...",
            "*устал?",
            "*а мы только начали."
        },
        phase4 = {
            "*хех...",
            "*знаешь...",
            "*я тоже устал.",
            "*но я не остановлюсь."
        },
        death = {
            "*...",
            "*хех...",
            "*молодец...",
            "*не говори никому...",
            "*что я проиграл.",
            "*...",
            "*я пойду...",
            "*баю-бай."
        }
    }
    

    -- Запуск битвы с Сансом
    function UT_SANS_BATTLE.Start()
        print("[UNDERTALE] Запуск битвы с Сансом!")
        
        -- Проверяем зависимости
        if not UT_BATTLE_CORE then
            print("[UNDERTALE] ОШИБКА: UT_BATTLE_CORE не найден!")
            return
        end
        
        if not UT_HEART_SYSTEM then
            print("[UNDERTALE] ОШИБКА: UT_HEART_SYSTEM не найден!")
            return
        end
        
        if not UT_BATTLE_HUD then
            print("[UNDERTALE] ОШИБКА: UT_BATTLE_HUD не найден!")
            return
        end
        
        UT_SANS_BATTLE.isActive = true
        UT_SANS_BATTLE.phase = 1
        UT_SANS_BATTLE.attackIndex = 1
        UT_SANS_BATTLE.karma = 0
        UT_SANS_BATTLE.heartCycle = 0
        UT_SANS_BATTLE.switchTimer = CurTime()
        
        -- Останавливаем текущую музыку
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
            UT_BATTLE_MUSIC.Stop()
        end
        
        -- Создаём боевое меню если его нет
        if not UT_BATTLE_CORE.battleActive then
            if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                UT_BATTLE_HUD.CreateBattleMenu()
            end
        end
        
        -- Показываем диалог
        UT_SANS_BATTLE.ShowDialog(UT_SANS_BATTLE.dialogs.start, function()
            print("[UNDERTALE] Диалог завершён, начинаем фазу!")
            UT_SANS_BATTLE.StartPhase()
        end)
    end
    
    -- Показать диалог Санса
    function UT_SANS_BATTLE.ShowDialog(lines, onComplete)
        local lineIndex = 1
        
        local function ShowNextLine()
            if lineIndex > #lines then
                if onComplete then onComplete() end
                return
            end
            
            if UT_BATTLE_HUD and UT_BATTLE_HUD.ShowTypingDialogText then
                UT_BATTLE_HUD.ShowTypingDialogText(lines[lineIndex], UT_BATTLE_CORE.dialogPanel, function()
                    lineIndex = lineIndex + 1
                    timer.Simple(1, ShowNextLine)
                end)
            end
        end
        
        ShowNextLine()
    end
    
    -- Начать фазу атаки
    function UT_SANS_BATTLE.StartPhase()
        if UT_SANS_BATTLE.phase > #UT_SANS_BATTLE.attacks then
            UT_SANS_BATTLE.EndBattle(true)
            return
        end
        
        local attack = UT_SANS_BATTLE.attacks[UT_SANS_BATTLE.phase]
        
        -- Устанавливаем цвет сердца для фазы
        UT_HEART_SYSTEM.SetHeartType(attack.heartColor)
        
        -- Показываем название атаки
        if UT_BATTLE_HUD then
            UT_BATTLE_HUD.AddHeartMessage("* " .. attack.name .. "!")
        end
        
        -- Запускаем фазу сердца с кастомными снарядами
        local bounds = UT_SANS_BATTLE.GetBounds()
        
        UT_HEART_SYSTEM.StartHeartPhase(attack.heartColor, bounds,
            function(damage)
                -- Получение урона (Карма)
                UT_SANS_BATTLE.karma = UT_SANS_BATTLE.karma + damage
                UT_BATTLE_CORE.playerHp = math.max(0, UT_BATTLE_CORE.playerHp - damage)
                
                if UT_BATTLE_CORE.playerHp <= 0 then
                    UT_SANS_BATTLE.GameOver()
                end
            end,
            function()
                -- Завершение фазы
                UT_SANS_BATTLE.NextAttack()
            end,
            attack  -- Передаём атаку для создания снарядов
        )
    end
    
    -- Получить границы для битвы с Сансом
    function UT_SANS_BATTLE.GetBounds()
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            local panel = UT_BATTLE_CORE.dialogPanel
            local x, y = panel:GetPos()
            local w, h = panel:GetSize()
            return {
                left = x + 20,
                right = x + w - 20,
                top = y + 20,
                bottom = y + h - 20
            }
        end
        
        return {
            left = ScrW()/2 - 430,
            right = ScrW()/2 + 430,
            top = ScrH()/2 - 100,
            bottom = ScrH()/2 + 100
        }
    end
    
    -- Следующая атака
    function UT_SANS_BATTLE.NextAttack()
        if not UT_SANS_BATTLE.isActive then return end
        
        UT_SANS_BATTLE.attackIndex = UT_SANS_BATTLE.attackIndex + 1
        
        -- Проверяем, нужно ли переходить на следующую фазу
        if UT_SANS_BATTLE.attackIndex > 3 then  -- 3 атаки на фазу
            UT_SANS_BATTLE.phase = UT_SANS_BATTLE.phase + 1
            UT_SANS_BATTLE.attackIndex = 1
            
            -- Показываем диалог перед новой фазой
            local dialogKey = "phase" .. UT_SANS_BATTLE.phase
            local dialogs = UT_SANS_BATTLE.dialogs[dialogKey]
            
            if dialogs then
                UT_SANS_BATTLE.ShowDialog(dialogs, function()
                    UT_SANS_BATTLE.StartPhase()
                end)
            else
                UT_SANS_BATTLE.StartPhase()
            end
        else
            UT_SANS_BATTLE.StartPhase()
        end
    end
    
    -- Завершение битвы
    function UT_SANS_BATTLE.EndBattle(victory)
        UT_SANS_BATTLE.isActive = false
        
        if victory then
            UT_SANS_BATTLE.ShowDialog(UT_SANS_BATTLE.dialogs.death, function()
                if UT_BATTLE_CORE then
                    UT_BATTLE_CORE.EndBattle(true)
                end
            end)
        else
            if UT_BATTLE_CORE then
                UT_BATTLE_CORE.EndBattle(false)
            end
        end
    end
    
    -- Game Over
    function UT_SANS_BATTLE.GameOver()
        UT_SANS_BATTLE.isActive = false
        
        if UT_BATTLE_HUD then
            UT_BATTLE_HUD.AddHeartMessage("* game over...")
        end
        
        timer.Simple(3, function()
            if UT_BATTLE_CORE then
                UT_BATTLE_CORE.StopAllSystems()
            end
        end)
    end
    
    print("[UNDERTALE] Битва с Сансом загружена")
end