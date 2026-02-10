-- ФАЙЛ: ut_battle_hud.lua (УПРОЩЕННАЯ ВЕРСИЯ БЕЗ СЕТКИ)
if CLIENT then
    print("[UNDERTALE] Загрузка модуля интерфейса БЕЗ СЕТКИ...")
    
    -- Проверяем что ядро загружено
    if not UT_BATTLE_CORE then
        print("[UNDERTALE] ОШИБКА: Ядро боевой системы не загружено!")
        UT_BATTLE_CORE = {
            battleActive = false,
            battleFrame = nil,
            selectedButton = 1,
            selectedTarget = 1,
            battleMode = "MENU",
            playerHp = 20,
            playerMaxHp = 20,
            buttons = {},
            currentTargets = {},
            btnImages = {},
            dialogPanel = nil,
            btnPanel = nil,
            infoPanel = nil,
            currentEnemy = nil
        }
    end
    
    -- Модуль интерфейса
    UT_BATTLE_HUD = UT_BATTLE_HUD or {}
    UT_BATTLE_HUD.heartActive = false
    UT_BATTLE_HUD.currentMessage = ""
    
    -- КЭШ МАТЕРИАЛОВ
    UT_BATTLE_HUD.enemyMaterialCache = {}
    UT_BATTLE_HUD.gridMaterial = nil
    
    -- СОЗДАНИЕ ШРИФТОВ (только основные)
    surface.CreateFont("UT_Menu", {
        font = "Arial",
        size = 24,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("UT_Small", {
        font = "Arial",
        size = 18,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("UT_PlayerName", {
        font = "Arial",
        size = 20,
        weight = 700,
        antialias = true
    })
    
    surface.CreateFont("UT_Attack", {
        font = "Arial",
        size = 36,
        weight = 900,  -- Очень жирный
        antialias = true
    })
    
    surface.CreateFont("UT_EnemyName", {
        font = "Arial",
        size = 28,  -- Увеличили
        weight = 900,  -- Очень жирный
        antialias = true
    })
    
    -- ПОЛУЧЕНИЕ МАТЕРИАЛА ВРАГА
    UT_BATTLE_HUD.GetEnemyMaterial = function(enemyClass)
        if not enemyClass then return nil end
        
        local cacheKey = enemyClass
        if not UT_BATTLE_HUD.enemyMaterialCache[cacheKey] then
            local spritePath = "enemies/" .. enemyClass .. "/enemy.png"
            
            if file.Exists("materials/" .. spritePath, "GAME") then
                local material = Material(spritePath)
                if not material:IsError() then
                    UT_BATTLE_HUD.enemyMaterialCache[cacheKey] = material
                end
            end
        end
        
        return UT_BATTLE_HUD.enemyMaterialCache[cacheKey]
    end 
    
    -- ПОЛУЧЕНИЕ ФОНА ГРИДА
    UT_BATTLE_HUD.GetGridMaterial = function()
        if not UT_BATTLE_HUD.gridMaterial then
            local gridPath = "undertale/grid.png"
            if file.Exists("materials/" .. gridPath, "GAME") then
                local material = Material(gridPath)
                if not material:IsError() then
                    UT_BATTLE_HUD.gridMaterial = material
                end
            end
        end
        return UT_BATTLE_HUD.gridMaterial
    end
    
    -- 🔴 ВАЖНО: НОВАЯ ФУНКЦИЯ ДЛЯ БОЛЬШОГО ВРАГА
    UT_BATTLE_HUD.DrawLargeEnemy = function(enemy, x, y, w, h)
        -- Определяем выбран ли враг
        local isSelected = false
        if UT_BATTLE_CORE.selectedTarget and UT_BATTLE_CORE.currentTargets then
            local selectedEnemy = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            isSelected = selectedEnemy == enemy
        end
        
        -- Большой спрайт врага
        local spriteW = w * 0.9
        local spriteH = h * 0.85
        local spriteX = x + (w - spriteW) / 2
        local spriteY = y + (h - spriteH) / 2
        
        -- Спрайт врага
        local material = UT_BATTLE_HUD.GetEnemyMaterial(enemy.class or "npc_zombie")
        
        if material and not material:IsError() then
            -- Толстая черная обводка
            surface.SetDrawColor(0, 0, 0, 220)
            for i = 1, 5 do
                surface.DrawOutlinedRect(spriteX - i, spriteY - i, spriteW + i*2, spriteH + i*2, 1)
            end
            
            -- Сам спрайт
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
            surface.DrawTexturedRect(spriteX, spriteY, spriteW, spriteH)
            
            -- Желтая обводка для выбранного
            if isSelected then
                surface.SetDrawColor(255, 255, 0, 220)
                for i = 1, 8 do
                    surface.DrawOutlinedRect(spriteX - i - 5, spriteY - i - 5, 
                        spriteW + (i+5)*2, spriteH + (i+5)*2, 1)
                end
                
                -- Анимация пульсации для выбранного врага
                local pulse = math.sin(CurTime() * 3) * 0.05 + 0.95
                surface.SetDrawColor(255, 255, 0, 80)
                surface.DrawOutlinedRect(
                    spriteX - 15 * pulse, 
                    spriteY - 15 * pulse, 
                    spriteW + 30 * pulse, 
                    spriteH + 30 * pulse, 
                    3
                )
            end
        else
            -- Запасной вариант: большой цветной прямоугольник
            surface.SetDrawColor(200, 50, 50, 220)
            surface.DrawRect(spriteX, spriteY, spriteW, spriteH)
            
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawOutlinedRect(spriteX - 3, spriteY - 3, spriteW + 6, spriteH + 6, 5)
            
            -- Текст класса
            draw.SimpleTextOutlined(enemy.class or "ENEMY", "UT_EnemyName", 
                x + w/2, y + h/2, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                3, Color(0, 0, 0, 200))
        end
        
        -- ИМЯ ВРАГА ПОД СПРАЙТОМ (БОЛЬШОЙ ТЕКСТ)
        local nameY = y + h + 10
        draw.SimpleTextOutlined(enemy.name or "Враг", "UT_EnemyName", 
            x + w/2, nameY, 
            Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            3, Color(0, 0, 0, 200))
        
        -- БОЛЬШОЙ HP БАР
        local hpPercent = math.max(0, enemy.hp / enemy.maxhp)
        local hpBarW = w * 0.8
        local hpBarH = 15  -- Толстый!
        local hpBarX = x + (w - hpBarW) / 2
        local hpBarY = nameY + 30
        
        -- Фон HP бара с толстой обводкой
        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(hpBarX, hpBarY, hpBarW, hpBarH)
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawOutlinedRect(hpBarX - 2, hpBarY - 2, hpBarW + 4, hpBarH + 4, 3)
        
        -- Заполнение HP бара
        local hpColor
        if hpPercent > 0.5 then
            hpColor = Color(0, 255, 0, 255)
        elseif hpPercent > 0.2 then
            hpColor = Color(255, 255, 0, 255)
        else
            hpColor = Color(255, 50, 0, 255)
            -- Пульсация при низком HP
            local pulse = math.sin(CurTime() * 5) * 0.3 + 0.7
            hpColor = Color(255 * pulse, 50 * pulse, 0, 255)
        end
        
        surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 255)
        surface.DrawRect(hpBarX, hpBarY, hpBarW * hpPercent, hpBarH)
        
        -- Текст HP (БОЛЬШОЙ)
        draw.SimpleTextOutlined(math.ceil(enemy.hp) .. "/" .. enemy.maxhp, "UT_EnemyName", 
            x + w/2, hpBarY - 20, 
            Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            2, Color(0, 0, 0, 200))
    end
    
    -- 🔴 ВАЖНО: НОВАЯ ФУНКЦИЯ ДЛЯ БОЛЬШОГО МЕРТВОГО ВРАГА
    UT_BATTLE_HUD.DrawLargeDeadEnemy = function(enemy, x, y, w, h)
        -- Полупрозрачный серый спрайт
        local spriteW = w * 0.8
        local spriteH = h * 0.75
        local spriteX = x + (w - spriteW) / 2
        local spriteY = y + (h - spriteH) / 2
        
        -- Серый спрайт врага
        local material = UT_BATTLE_HUD.GetEnemyMaterial(enemy.class or "npc_zombie")
        if material then
            surface.SetDrawColor(100, 100, 100, 150)
            surface.SetMaterial(material)
            surface.DrawTexturedRect(spriteX, spriteY, spriteW, spriteH)
        end
        
        -- БОЛЬШОЙ КРАСНЫЙ КРЕСТ (толстый)
        surface.SetDrawColor(200, 0, 0, 200)
        local crossThickness = 8
        
        -- Вертикальная линия креста
        surface.DrawRect(x + w/2 - crossThickness/2, y, crossThickness, h)
        -- Горизонтальная линия креста
        surface.DrawRect(x, y + h/2 - crossThickness/2, w, crossThickness)
        
        -- Диагональные кресты (X)
        for i = 1, 5 do
            surface.DrawLine(x + i, y + i, x + w - i, y + h - i)
            surface.DrawLine(x + w - i, y + i, x + i, y + h - i)
        end
        
        -- Текст "МЕРТВ" (БОЛЬШОЙ)
        draw.SimpleTextOutlined("✝ МЕРТВ", "UT_Attack", 
            x + w/2, y + h + 20, 
            Color(200, 50, 50, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            3, Color(0, 0, 0, 200))
    end
    
    -- 🔴 ВАЖНО: УПРОЩЕННАЯ ФУНКЦИЯ ОТРИСОВКИ ВРАГОВ НА GRID
    UT_BATTLE_HUD.DrawEnemiesOnGrid = function()
        if not UT_BATTLE_CORE.currentTargets or #UT_BATTLE_CORE.currentTargets == 0 then 
            return 
        end
        
        -- Размеры PNG фона (609x236) - это просто фон!
        local gridW = 1609
        local gridH = 580
        local gridX = ScrW()/2 - gridW/2
        local gridY = ScrH() * 0.03
        
        -- Рисуем PNG фон (ПРОСТО ДЛЯ КРАСОТЫ)
        local gridMaterial = UT_BATTLE_HUD.GetGridMaterial()
        if gridMaterial then
            surface.SetDrawColor(255, 255, 255, 180)  -- Полупрозрачный
            surface.SetMaterial(gridMaterial)
            surface.DrawTexturedRect(gridX, gridY, gridW, gridH)
        end
        
        -- 🔴🔴🔴 ВРАГИ РИСУЮТСЯ ПОВЕРХ GRID И ЗАНИМАЮТ 2-3 ЯЧЕЙКИ 🔴🔴🔴
        local enemies = UT_BATTLE_CORE.currentTargets
        local enemyCount = #enemies
        
        if enemyCount == 1 then
            -- Один враг - ОГРОМНЫЙ по центру
            local enemy = enemies[1]
            local enemyWidth = 500  -- Очень широкий
            local enemyHeight = 400 -- Очень высокий
            local enemyX = ScrW()/2 - enemyWidth/2  -- Центр экрана, а не grid!
            local enemyY = gridY + gridH/2 - enemyHeight/2  -- Центр по вертикали grid
            
            -- Рисуем на 50px ВЫШЕ grid чтобы перекрывать
            if enemy.hp > 0 then
                UT_BATTLE_HUD.DrawLargeEnemy(enemy, enemyX, enemyY - 50, enemyWidth, enemyHeight)
            else
                UT_BATTLE_HUD.DrawLargeDeadEnemy(enemy, enemyX, enemyY - 50, enemyWidth, enemyHeight)
            end
            
        elseif enemyCount == 2 then
            -- Два врага: левый и правый (БОЛЬШИЕ)
            local enemyWidth = 450
            local enemyHeight = 380
            local spacing = 200  -- Расстояние между врагами
            
            for i, enemy in ipairs(enemies) do
                local enemyX
                if i == 1 then
                    enemyX = ScrW()/2 - enemyWidth - spacing/2  -- Левый
                else
                    enemyX = ScrW()/2 + spacing/2  -- Правый
                end
                local enemyY = gridY + gridH/2 - enemyHeight/2 - 40
                
                if enemy.hp > 0 then
                    UT_BATTLE_HUD.DrawLargeEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                else
                    UT_BATTLE_HUD.DrawLargeDeadEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                end
            end
            
        elseif enemyCount == 3 then
            -- Три врага: треугольник (БОЛЬШИЕ)
            local enemyWidth = 400
            local enemyHeight = 350
            
            local positions = {
                {x = ScrW()/2 - enemyWidth/2, y = gridY + 50},  -- Верхний центр
                {x = ScrW()/2 - enemyWidth - 100, y = gridY + gridH - enemyHeight - 50},  -- Левый низ
                {x = ScrW()/2 + 100, y = gridY + gridH - enemyHeight - 50}  -- Правый низ
            }
            
            for i, enemy in ipairs(enemies) do
                if positions[i] then
                    if enemy.hp > 0 then
                        UT_BATTLE_HUD.DrawLargeEnemy(enemy, positions[i].x, positions[i].y, enemyWidth, enemyHeight)
                    else
                        UT_BATTLE_HUD.DrawLargeDeadEnemy(enemy, positions[i].x, positions[i].y, enemyWidth, enemyHeight)
                    end
                end
            end
            
        else
            -- Много врагов - в линию (БОЛЬШИЕ)
            local enemyWidth = 220
            local enemyHeight = 270
            local totalWidth = enemyWidth * enemyCount + 100 * (enemyCount - 1)
            local startX = ScrW()/2 - totalWidth/2
            
            for i, enemy in ipairs(enemies) do
                local enemyX = startX + (i - 1) * (enemyWidth + 100)
                local enemyY = gridY + 330
                
                if enemy.hp > 0 then
                    UT_BATTLE_HUD.DrawLargeEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                else
                    UT_BATTLE_HUD.DrawLargeDeadEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                end
            end
        end
        
        -- В конце DrawEnemiesOnGrid добавляем стрелку выбора:
        if UT_BATTLE_CORE.battleMode == "FIGHT" and UT_BATTLE_CORE.selectedTarget then
            local selectedEnemy = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            if selectedEnemy and selectedEnemy.hp > 0 then
                -- Находим позицию выбранного врага
                local enemyIndex = UT_BATTLE_CORE.selectedTarget
                local enemyCount = #UT_BATTLE_CORE.currentTargets
                
                -- БОЛЬШАЯ ЖЕЛТАЯ СТРЕЛКА СПРАВА ОТ ВРАГА
                local arrowX, arrowY, arrowSize
                
                if enemyCount == 1 then
                    arrowX = ScrW()/2 + 300  -- Справа от центрального врага
                    arrowY = ScrH() * 0.25 + 100
                    arrowSize = 40
                elseif enemyCount == 2 then
                    arrowX = (enemyIndex == 1) and (ScrW()/2 - 550) or (ScrW()/2 + 550)
                    arrowY = ScrH() * 0.25 + 100
                    arrowSize = 35
                else
                    -- Для остальных случаев
                    arrowX = ScrW()/2 + 400
                    arrowY = ScrH() * 0.25 + 100
                    arrowSize = 30
                end
                
                -- Рисуем ОГРОМНУЮ стрелку
                surface.SetDrawColor(255, 255, 0, 255)
                
                -- Треугольная стрелка
                surface.DrawPoly({
                    {x = arrowX, y = arrowY - arrowSize},
                    {x = arrowX + arrowSize, y = arrowY},
                    {x = arrowX, y = arrowY + arrowSize}
                })
                
                -- Обводка стрелки
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawPoly({
                    {x = arrowX - 2, y = arrowY - arrowSize - 2},
                    {x = arrowX + arrowSize + 2, y = arrowY},
                    {x = arrowX - 2, y = arrowY + arrowSize + 2}
                })
                
                -- Текст "ВЫБРАН"
                draw.SimpleTextOutlined("► ВЫБРАН", "UT_Attack", 
                    arrowX + arrowSize + 20, arrowY, 
                    Color(255, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER,
                    3, Color(0, 0, 0, 200))
            end
        end
    end
    
    -- ДОБАВЛЕНИЕ СООБЩЕНИЯ В ДИАЛОГ
    UT_BATTLE_HUD.AddHeartMessage = function(message)
        UT_BATTLE_HUD.currentMessage = message
        UT_BATTLE_HUD.messageTimer = CurTime()
        
        if UT_HEART_CORE then
            UT_HEART_CORE.current_message = message
        end
        
        print("[UNDERTALE] Сообщение сердца: "..message)
        
        -- Обновляем диалоговую панель
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            UT_BATTLE_CORE.dialogPanel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                -- Отображаем текущее сообщение
                draw.SimpleText(UT_BATTLE_HUD.currentMessage, "UT_Menu", w/2, h/2 - 20, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER)
                
                -- HP игрока внизу
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Menu", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- ОБНОВЛЕНИЕ ДИАЛОГОВОЙ ПАНЕЛИ (ДЛЯ РЕЖИМА FIGHT - ПОКАЗЫВАЕМ ВСЕХ ВРАГОВ)
    UT_BATTLE_HUD.UpdateDialogPanel = function()
        if not UT_BATTLE_CORE or not IsValid(UT_BATTLE_CORE.dialogPanel) then 
            print("[UNDERTALE] Диалоговая панель не существует")
            return 
        end
        
        UT_BATTLE_HUD.currentEnemyMessage = UT_BATTLE_HUD.currentEnemyMessage or ""
        
        UT_BATTLE_CORE.dialogPanel.Paint = function(self, w, h)
            draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
            surface.SetDrawColor(255, 255, 255, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            if UT_BATTLE_CORE.battleMode == "MENU" then
                if UT_BATTLE_CORE.currentEnemy and UT_BATTLE_CORE.currentEnemy.data then
                    local enemyData = UT_BATTLE_CORE.currentEnemy.data
                    
                    if UT_BATTLE_HUD.currentEnemyMessage == "" and enemyData.dialog then
                        local dialogLines = enemyData.dialog
                        if #dialogLines > 0 then
                            UT_BATTLE_HUD.currentEnemyMessage = dialogLines[math.random(#dialogLines)]
                        else
                            UT_BATTLE_HUD.currentEnemyMessage = "* Враг перед вами..."
                        end
                    end
                    
                    draw.SimpleText(UT_BATTLE_HUD.currentEnemyMessage, "UT_Menu", w/2, h/2 - 20, 
                        Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        
                    draw.SimpleText("Что вы будете делать?", "UT_Menu", w/2, h/2 + 20, 
                        Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("Что вы будетете делать?", "UT_Menu", w/2, h/2, 
                        Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                    
            elseif UT_BATTLE_CORE.battleMode == "FIGHT" and not UT_BATTLE_CORE.attackInProgress then
                -- В РЕЖИМЕ FIGHT ПОКАЗЫВАЕМ СПИСОК ВСЕХ ВРАГОВ (как в Undertale)
                if UT_BATTLE_CORE.currentTargets and #UT_BATTLE_CORE.currentTargets > 0 then
                    local startY = 30
                    local lineHeight = 40
                    
                    draw.SimpleText("Кого атаковать?", "UT_Menu", 50, 20, Color(255, 255, 255))
                    
                    for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
                        local yPos = startY + (i-1) * lineHeight
                        local isSelected = (i == UT_BATTLE_CORE.selectedTarget)
                        local color = Color(255, 255, 255)
                        local prefix = "  "
                        
                        if enemy.hp <= 0 then
                            color = Color(150, 150, 150, 150)
                            prefix = "✝ "
                        elseif isSelected then
                            color = Color(255, 255, 0)
                            prefix = "► "
                        end
                        
                        -- Имя врага и HP
                        local enemyText = prefix .. enemy.name
                        draw.SimpleText(enemyText, "UT_Menu", 70, yPos, color)
                        
                        -- HP справа
                        local hpColor = Color(255, 255, 255)
                        if enemy.hp > 0 then
                            local hpPercent = enemy.hp / enemy.maxhp
                            if hpPercent < 0.3 then
                                hpColor = Color(255, 50, 50)
                            elseif hpPercent < 0.7 then
                                hpColor = Color(255, 255, 50)
                            else
                                hpColor = Color(50, 255, 50)
                            end
                            
                            draw.SimpleText("♥ " .. math.ceil(enemy.hp) .. "/" .. enemy.maxhp, "UT_Menu", 
                                w - 50, yPos, hpColor, TEXT_ALIGN_RIGHT)
                        else
                            draw.SimpleText("МЕРТВ", "UT_Menu", 
                                w - 50, yPos, Color(200, 50, 50), TEXT_ALIGN_RIGHT)
                        end
                    end
                    
                    -- Подсказка управления
                    draw.SimpleText("↑ ↓ - Выбор цели", "UT_Small", 50, h - 60, Color(200, 200, 255))
                    draw.SimpleText("ENTER - Атаковать", "UT_Small", 50, h - 35, Color(200, 255, 200))
                    draw.SimpleText("ESC - Назад", "UT_Small", w - 50, h - 35, Color(255, 200, 200), TEXT_ALIGN_RIGHT)
                end
                
            elseif UT_BATTLE_CORE.battleMode == "ACT" then
                draw.SimpleText("* Выберите действие", "UT_Menu", 50, 50, Color(255, 255, 255))
                
                local actions = {"ПРИВЕТСТВОВАТЬ", "ПОДАРИТЬ ЦВЕТОК", "РАССКАЗАТЬ ШУТКУ"}
                
                for i, action in ipairs(actions) do
                    local yPos = 100 + (i-1) * 50
                    local color = Color(255, 255, 255)
                    
                    if i == (UT_BATTLE_CORE.selectedTarget or 1) then
                        color = Color(255, 255, 0)
                        draw.SimpleText("►", "UT_Menu", 50, yPos, color)
                    end
                    
                    draw.SimpleText("* "..action, "UT_Menu", 90, yPos, color)
                end
                
            elseif UT_BATTLE_CORE.battleMode == "ATTACK" then
                -- Фон атаки
                surface.SetDrawColor(30, 30, 50, 200)
                surface.DrawRect(0, 0, w, h)
                
                surface.SetDrawColor(255, 255, 255, 30)
                for i = 0, w, 50 do
                    surface.DrawLine(i, 0, i, h)
                end
                for i = 0, h, 50 do
                    surface.DrawLine(0, i, w, i)
                end
                
                -- ЗОНА МАКСИМАЛЬНОГО УРОНА
                local zoneColor = Color(0, 255, 0, 50)
                if UT_BATTLE_CORE.attackResult == "hit" or UT_BATTLE_CORE.attackResult == "critical" then
                    zoneColor = Color(255, 255, 0, 80)
                end
                
                surface.SetDrawColor(zoneColor.r, zoneColor.g, zoneColor.b, zoneColor.a)
                surface.DrawRect(UT_BATTLE_CORE.attackHitZone.start, 0, 
                    UT_BATTLE_CORE.attackHitZone.finish - UT_BATTLE_CORE.attackHitZone.start, h)
                
                surface.SetDrawColor(0, 255, 0, 150)
                surface.DrawOutlinedRect(UT_BATTLE_CORE.attackHitZone.start, 0, 
                    UT_BATTLE_CORE.attackHitZone.finish - UT_BATTLE_CORE.attackHitZone.start, h, 2)
                    
                -- ТЕКСТ "АТАКА!"
                draw.SimpleText("АТАКА!", "UT_Attack", w/2, 30, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER)
                
                -- ДВИЖУЩАЯСЯ ПОЛОСКА
                if UT_BATTLE_CORE.attackActive or UT_BATTLE_CORE.attackResult then
                    local barColor = Color(255, 255, 255)
                    if UT_BATTLE_CORE.attackResult == "hit" then
                        barColor = Color(0, 255, 0)
                    elseif UT_BATTLE_CORE.attackResult == "critical" then
                        barColor = Color(255, 255, 0)
                    elseif UT_BATTLE_CORE.attackResult == "miss" then
                        barColor = Color(255, 50, 50)
                    end
                    
                    -- Мигание при попадании
                    if UT_BATTLE_CORE.attackResult and CurTime() - UT_BATTLE_CORE.attackBlinkTimer < 0.5 then
                        local blink = math.sin(CurTime() * 20) > 0
                        if blink then
                            barColor = Color(255, 255, 0)
                        end
                    end
                    
                    surface.SetDrawColor(barColor.r, barColor.g, barColor.b, 200)
                    surface.DrawRect(UT_BATTLE_CORE.attackBarPos, h/2 - 10, UT_BATTLE_CORE.attackBarWidth, 20)
                    
                    surface.SetDrawColor(255, 255, 255, 150)
                    surface.DrawOutlinedRect(UT_BATTLE_CORE.attackBarPos, h/2 - 10, 
                        UT_BATTLE_CORE.attackBarWidth, 20, 2)
                    
                    surface.SetDrawColor(255, 0, 0, 200)
                    surface.DrawLine(UT_BATTLE_CORE.attackBarPos + UT_BATTLE_CORE.attackBarWidth/2, h/2 - 15, 
                                    UT_BATTLE_CORE.attackBarPos + UT_BATTLE_CORE.attackBarWidth/2, h/2 + 15)
                end
                
                -- РЕЗУЛЬТАТ АТАКИ
                if UT_BATTLE_CORE.attackResult then
                    local resultText = ""
                    local resultColor = Color(255, 255, 255)
                    
                    if UT_BATTLE_CORE.attackResult == "hit" then
                        resultText = "ПОПАДАНИЕ: "..UT_BATTLE_CORE.attackDamage.." урона"
                        resultColor = Color(0, 255, 0)
                    elseif UT_BATTLE_CORE.attackResult == "critical" then
                        resultText = "КРИТИЧЕСКИЙ УДАР: "..UT_BATTLE_CORE.attackDamage.." урона!"
                        resultColor = Color(255, 255, 0)
                    elseif UT_BATTLE_CORE.attackResult == "miss" then
                        resultText = "ПРОМАХ!"
                        resultColor = Color(255, 50, 50)
                    end
                    
                    draw.SimpleText(resultText, "UT_Menu", w/2, h - 50, 
                        resultColor, TEXT_ALIGN_CENTER)
                end
                
                -- ПОДСКАЗКА
                if UT_BATTLE_CORE.attackActive then
                    draw.SimpleText("Нажмите ПРОБЕЛ когда полоска в зелёной зоне!", "UT_Small", 
                        w/2, h - 80, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                end
                
            elseif UT_BATTLE_CORE.battleMode == "HEART_PHASE" then
                if UT_BATTLE_HUD.currentMessage ~= "" then
                    draw.SimpleText(UT_BATTLE_HUD.currentMessage, "UT_Menu", 50, 50, 
                        Color(255, 255, 255))
                else
                    draw.SimpleText("* Враг атакует! Уклоняйтесь!", "UT_Menu", 50, 50, 
                        Color(255, 255, 255))
                end
                
                local player_hp = UT_HEART_CORE and UT_HEART_CORE.player and UT_HEART_CORE.player.hp or (UT_BATTLE_CORE.playerHp or 20)
                draw.SimpleText("ВАШЕ HP: "..player_hp.."/20", "UT_Menu", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                    
                draw.SimpleText("← ↑ ↓ → - Уклонение", "UT_Small", 
                    w/2, h - 60, Color(200, 200, 255), TEXT_ALIGN_CENTER)
                    
            elseif UT_BATTLE_CORE.battleMode == "HEART" then
                if UT_BATTLE_HUD.currentMessage ~= "" then
                    draw.SimpleText(UT_BATTLE_HUD.currentMessage, "UT_Menu", 50, 50, 
                        Color(255, 255, 255))
                else
                    draw.SimpleText("* Враг готовится атаковать...", "UT_Menu", 50, 50, 
                        Color(255, 255, 255))
                end
                
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Menu", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- СОЗДАНИЕ БОЕВОГО МЕНЮ
    UT_BATTLE_HUD.CreateBattleMenu = function()
        print("[UNDERTALE] Создание боевого меню с PNG фоном...")
        
        -- ВАЖНО: Проверяем что UT_BATTLE_CORE существует
        if not UT_BATTLE_CORE then
            print("[UNDERTALE] КРИТИЧЕСКАЯ ОШИБКА: UT_BATTLE_CORE не существует!")
            chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
                "Ядро боевой системы не загружено!")
            return
        end
        
        -- Инициализируем если нужно
        if UT_BATTLE_CORE.battleActive == nil then
            UT_BATTLE_CORE.battleActive = false
        end
        
        if UT_BATTLE_CORE.battleActive then
            print("[UNDERTALE] Бой уже активен!")
            return
        end
        
        UT_BATTLE_CORE.battleActive = true
        UT_BATTLE_CORE.selectedButton = 1
        UT_BATTLE_CORE.selectedTarget = 1
        UT_BATTLE_CORE.battleMode = "MENU"
        UT_BATTLE_CORE.keyCooldown = 0
        UT_BATTLE_CORE.btnImages = {}
        UT_BATTLE_CORE.attackActive = false
        UT_BATTLE_CORE.attackInProgress = false
        UT_BATTLE_CORE.attackResult = nil
        
        -- Инициализация кнопок если не существует
        if not UT_BATTLE_CORE.buttons then
            UT_BATTLE_CORE.buttons = {
                { name = "FIGHT", normal = "undertale/attack.png", selected = "undertale/attack_use.png" },
                { name = "ACT", normal = "undertale/act.png", selected = "undertale/act_use.png" },
                { name = "ITEM", normal = "undertale/item.png", selected = "undertale/item_use.png" },
                { name = "MERCY", normal = "undertale/mercy.png", selected = "undertale/mercy_use.png" }
            }
        end
        
        -- Используем данные врага из триггера или тестовые
        if not UT_BATTLE_CORE.currentTargets or #UT_BATTLE_CORE.currentTargets == 0 then
            UT_BATTLE_CORE.currentTargets = {
                {name = "СОЛДАТ", hp = 30, maxhp = 30, class = "npc_combine_s"},
                {name = "ЗОМБИ", hp = 25, maxhp = 25, class = "npc_zombie"},
                {name = "АНТЛИОН", hp = 35, maxhp = 35, class = "npc_antlion_s"},
                {name = "РАБОЧИЙ", hp = 20, maxhp = 20, class = "npc_antlionworker"}
            }
        end
        
        -- СОЗДАЕМ ОСНОВНОЙ ФРЕЙМ
        if IsValid(UT_BATTLE_CORE.battleFrame) then UT_BATTLE_CORE.battleFrame:Remove() end
        
        UT_BATTLE_CORE.battleFrame = vgui.Create("DFrame")
        UT_BATTLE_CORE.battleFrame:SetSize(ScrW(), ScrH())
        UT_BATTLE_CORE.battleFrame:SetPos(0, 0)
        UT_BATTLE_CORE.battleFrame:SetTitle("")
        UT_BATTLE_CORE.battleFrame:ShowCloseButton(false)
        UT_BATTLE_CORE.battleFrame:SetDraggable(false)
        UT_BATTLE_CORE.battleFrame:MakePopup()
        UT_BATTLE_CORE.battleFrame:SetKeyboardInputEnabled(true)
        
        -- ФОН ФРЕЙМА С ОТОБРАЖЕНИЕМ PNG ФОНА И ВРАГОВ
        UT_BATTLE_CORE.battleFrame.Paint = function(self, w, h)
            -- Черный фон
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)
            
            -- Рисуем PNG фон с врагами
            UT_BATTLE_HUD.DrawEnemiesOnGrid()
            
            -- Затемненная область под диалоговой панелью
            local dialogY = ScrH() * 0.55
            surface.SetDrawColor(0, 0, 0, 180)
            surface.DrawRect(0, dialogY - 50, w, h - dialogY + 50)
            
            -- Градиент сверху
            for i = 0, 50 do
                local alpha = 255 * (1 - i/50)
                surface.SetDrawColor(0, 0, 0, alpha)
                surface.DrawRect(0, i, w, 1)
            end
            
            -- Подсказка в углу
            draw.SimpleText("UNDERTALE BATTLE SYSTEM", "UT_Small", 20, 20, 
                Color(0, 255, 0, 150))
        end
        
        -- ДИАЛОГОВАЯ ПАНЕЛЬ
        local dialogW = 900
        local dialogH = 250
        UT_BATTLE_CORE.dialogPanel = vgui.Create("DPanel", UT_BATTLE_CORE.battleFrame)
        UT_BATTLE_CORE.dialogPanel:SetSize(dialogW, dialogH)
        UT_BATTLE_CORE.dialogPanel:SetPos(ScrW()/2 - dialogW/2, ScrH() * 0.55)
        
        UT_BATTLE_HUD.UpdateDialogPanel()
        
        -- ПАНЕЛЬ КНОПОК
        UT_BATTLE_CORE.btnPanel = vgui.Create("DPanel", UT_BATTLE_CORE.battleFrame)
        UT_BATTLE_CORE.btnPanel:SetSize(ScrW(), 130)
        UT_BATTLE_CORE.btnPanel:SetPos(0, ScrH() - 130)
        UT_BATTLE_CORE.btnPanel.Paint = function() end
        
        local totalBtnWidth = 0
        local btnWidths = {}
        
        for i, data in ipairs(UT_BATTLE_CORE.buttons) do
            if file.Exists("materials/"..data.normal, "GAME") then
                local material = Material(data.normal)
                if material and not material:IsError() then
                    local texWidth = material:Width() or 763
                    local texHeight = material:Height() or 273
                    local scale = 90 / texHeight
                    btnWidths[i] = texWidth * scale
                else
                    btnWidths[i] = 180
                end
            else
                btnWidths[i] = 180
            end
            totalBtnWidth = totalBtnWidth + btnWidths[i]
        end
        
        local totalSpacing = ScrW() - totalBtnWidth
        local spacing = totalSpacing / (#UT_BATTLE_CORE.buttons + 1)
        local currentX = spacing
        
        for i, data in ipairs(UT_BATTLE_CORE.buttons) do
            local btnW = btnWidths[i]
            local btnH = 90
            local btnY = 20
            
            local hasTexture = file.Exists("materials/"..data.normal, "GAME")
            
            if hasTexture then
                local btnContainer = vgui.Create("DPanel", UT_BATTLE_CORE.btnPanel)
                btnContainer:SetSize(btnW, btnH)
                btnContainer:SetPos(currentX, btnY)
                btnContainer.Paint = function(self, w, h)
                    if UT_BATTLE_CORE.battleMode == "MENU" and UT_BATTLE_CORE.selectedButton == i then
                        surface.SetDrawColor(255, 255, 0, 30)
                        surface.DrawRect(0, 0, w, h)
                        
                        surface.SetDrawColor(255, 255, 0, 200)
                        surface.DrawOutlinedRect(0, 0, w, h, 3)
                    end
                end
                
                local btnImage = vgui.Create("DImage", btnContainer)
                btnImage:SetSize(btnW, btnH)
                btnImage:SetKeepAspect(true)
                btnImage:SetImage(data.normal)
                
                UT_BATTLE_CORE.btnImages[i] = { image = btnImage, data = data }
            else
                local btnContainer = vgui.Create("DPanel", UT_BATTLE_CORE.btnPanel)
                btnContainer:SetSize(btnW, btnH)
                btnContainer:SetPos(currentX, btnY)
                btnContainer.Paint = function() end
                
                -- Создаем простую кнопку как запасной вариант
                local simpleBtn = vgui.Create("DButton", btnContainer)
                simpleBtn:SetSize(btnW, btnH)
                simpleBtn:SetPos(0, 0)
                simpleBtn:SetText(data.name)
                simpleBtn:SetFont("UT_Menu")
                simpleBtn.Paint = function(self, w, h)
                    surface.SetDrawColor(100, 100, 100, 200)
                    surface.DrawRect(0, 0, w, h)
                    
                    if UT_BATTLE_CORE.battleMode == "MENU" and UT_BATTLE_CORE.selectedButton == i then
                        surface.SetDrawColor(255, 255, 0, 100)
                        surface.DrawRect(0, 0, w, h)
                    end
                end
                
                UT_BATTLE_CORE.btnImages[i] = { image = simpleBtn, data = data }
            end
            
            currentX = currentX + btnW + spacing
        end
        
        -- ПАНЕЛЬ ИНФОРМАЦИИ ОБ ИГРОКЕ
        local fightBtnIndex = 1
        local fightBtnX = 0
        local fightBtnWidth = 0
        
        -- Находим кнопку FIGHT для позиционирования
        for i, data in ipairs(UT_BATTLE_CORE.buttons) do
            if data.name == "FIGHT" then
                fightBtnIndex = i
                local totalBtnWidthRecalc = 0
                local btnWidthsRecalc = {}
                
                for j, btnData in ipairs(UT_BATTLE_CORE.buttons) do
                    local material = Material(btnData.normal)
                    if material and not material:IsError() then
                        local texWidth = material:Width() or 763
                        local texHeight = material:Height() or 273
                        local scale = 90 / texHeight
                        btnWidthsRecalc[j] = texWidth * scale
                    else
                        btnWidthsRecalc[j] = 180
                    end
                    totalBtnWidthRecalc = totalBtnWidthRecalc + btnWidthsRecalc[j]
                end
                
                local totalSpacingRecalc = ScrW() - totalBtnWidthRecalc
                local spacingRecalc = totalSpacingRecalc / (#UT_BATTLE_CORE.buttons + 1)
                
                fightBtnWidth = btnWidthsRecalc[fightBtnIndex]
                fightBtnX = spacingRecalc
                for j = 1, fightBtnIndex-1 do
                    fightBtnX = fightBtnX + btnWidthsRecalc[j] + spacingRecalc
                end
                break
            end
        end
        
        UT_BATTLE_CORE.infoPanel = vgui.Create("DPanel", UT_BATTLE_CORE.battleFrame)
        local infoWidth = fightBtnWidth + 40
        local infoHeight = 60
        local infoX = fightBtnX - 20
        local infoY = ScrH() - 130 - infoHeight - 10
        
        UT_BATTLE_CORE.infoPanel:SetSize(infoWidth, infoHeight)
        UT_BATTLE_CORE.infoPanel:SetPos(infoX, infoY)
        
        UT_BATTLE_CORE.infoPanel.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(255, 255, 255, 100)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            local playerName = "ИГРОК"
            if IsValid(LocalPlayer()) then
                playerName = LocalPlayer():Nick() or "ИГРОК"
            end
            
            draw.SimpleText(playerName.."  LV 1", "UT_PlayerName", 
                w/2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            
            draw.SimpleText("HP:", "UT_Small", 10, 35, Color(255, 255, 255))
            
            local hpPercent = (UT_BATTLE_CORE.playerHp or 20) / (UT_BATTLE_CORE.playerMaxHp or 20)
            local hpBarWidth = w - 80
            local hpBarHeight = 15
            local hpBarX = 40
            local hpBarY = 33
            
            surface.SetDrawColor(50, 50, 50, 255)
            surface.DrawRect(hpBarX, hpBarY, hpBarWidth, hpBarHeight)
            
            local currentHpWidth = hpBarWidth * hpPercent
            
            if hpPercent > 0.5 then
                surface.SetDrawColor(255, 255, 0, 255)
            elseif hpPercent > 0.2 then
                surface.SetDrawColor(255, 165, 0, 255)
            else
                surface.SetDrawColor(255, 50, 0, 255)
            end
            
            surface.DrawRect(hpBarX, hpBarY, currentHpWidth, hpBarHeight)
            
            surface.SetDrawColor(255, 255, 255, 100)
            surface.DrawOutlinedRect(hpBarX, hpBarY, hpBarWidth, hpBarHeight, 2)
            
            draw.SimpleText((UT_BATTLE_CORE.playerHp or 20).." / "..(UT_BATTLE_CORE.playerMaxHp or 20), "UT_Small", 
                hpBarX + hpBarWidth + 5, 35, Color(255, 255, 255))
        end
        
        if UT_BATTLE_CORE.UpdateButtonImages then
            UT_BATTLE_CORE.UpdateButtonImages()
        end
        
        -- ОБРАБОТКА КЛАВИАТУРЫ
        UT_BATTLE_CORE.battleFrame.OnKeyCodePressed = function(self, key)
            if UT_BATTLE_INPUT and UT_BATTLE_INPUT.HandleKeyPress then
                UT_BATTLE_INPUT.HandleKeyPress(key)
            end
        end
        
        -- НАСТРОЙКА ХУКА ВВОДА (НУЖНО ОБНОВИТЬ UT_BATTLE_INPUT.lua ДЛЯ НОВОЙ НАВИГАЦИИ)
        if UT_BATTLE_INPUT and UT_BATTLE_INPUT.SetupInputHook then
            UT_BATTLE_INPUT.SetupInputHook()
        end
        
        print("[UNDERTALE] Боевое меню с PNG фоном создано!")
        chat.AddText(Color(0, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "Бой начат!")
        chat.AddText(Color(255, 255, 0), "[ПОДСКАЗКА] ", Color(255, 255, 255), 
            "↑ ↓ для выбора цели в списке, ENTER для действия, ESC для выхода")
    end
    
    -- ВОССТАНОВЛЕНИЕ ПАНЕЛИ ПОСЛЕ СЕРДЦА
    UT_BATTLE_HUD.RestorePanel = function()
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            local panel = UT_BATTLE_CORE.dialogPanel
            panel:SetSize(900, 250)
            panel:SetPos(ScrW()/2 - 450, ScrH() * 0.55)
            UT_BATTLE_HUD.UpdateDialogPanel()
        end
    end
    
    print("[UNDERTALE] Модуль интерфейса БЕЗ СЕТКИ загружен")
end