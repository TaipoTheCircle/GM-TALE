-- ФАЙЛ: ut_battle_hud.lua (С АНИМАЦИЕЙ ВРАГОВ И ПЕЧАТАНИЕМ ТЕКСТА)
if CLIENT then
    print("[UNDERTALE] Загрузка модуля интерфейса с анимацией врагов...")
    
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
    
    -- ====== ПЕРЕМЕННЫЕ ДЛЯ АНИМАЦИИ ВРАГОВ ======
    UT_BATTLE_HUD.enemyAnimations = {}
    
    -- Функция инициализации анимации для врага
    UT_BATTLE_HUD.InitEnemyAnimation = function(enemy)
        if not enemy or not enemy.class then return end
        
        local enemyId = tostring(enemy.entity or enemy.class)
        if not UT_BATTLE_HUD.enemyAnimations[enemyId] then
            UT_BATTLE_HUD.enemyAnimations[enemyId] = {
                idleScale = 1.0,
                idleDirection = 1,
                idleSpeed = 0.8,
                lastUpdate = CurTime(),
                deathAnimProgress = 0,
                isDying = false
            }
        end
        return UT_BATTLE_HUD.enemyAnimations[enemyId]
    end
    
    -- Функция обновления анимации врага
    UT_BATTLE_HUD.UpdateEnemyAnimation = function(enemy, animData)
        if not enemy or not animData then return end
        
        local dt = FrameTime()
        
        if enemy.hp > 0 then
            if not animData.isDying then
                animData.idleScale = animData.idleScale + (animData.idleDirection * animData.idleSpeed * dt)
                
                if animData.idleScale >= 1.08 then
                    animData.idleScale = 1.08
                    animData.idleDirection = -1
                elseif animData.idleScale <= 0.92 then
                    animData.idleScale = 0.92
                    animData.idleDirection = 1
                end
            end
        else
            if not animData.isDying then
                animData.isDying = true
                animData.deathAnimProgress = 0
            end
            
            if animData.isDying and animData.deathAnimProgress < 1 then
                animData.deathAnimProgress = math.min(1, animData.deathAnimProgress + dt * 2)
            end
        end
        
        return animData
    end
    
    -- КЭШ МАТЕРИАЛОВ
    UT_BATTLE_HUD.enemyMaterialCache = {}
    UT_BATTLE_HUD.gridMaterial = nil
    
    -- СОЗДАНИЕ ШРИФТОВ
    surface.CreateFont("UT_Pixel", {
        font = "Courier New",
        size = 24,
        weight = 700,
        antialias = false
    })
    
    surface.CreateFont("UT_Pixel_Small", {
        font = "Courier New",
        size = 18,
        weight = 500,
        antialias = false
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
        weight = 900,
        antialias = true
    })
    
    surface.CreateFont("UT_EnemyName", {
        font = "Arial",
        size = 28,
        weight = 900,
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
    
    -- ====== ФУНКЦИЯ ДЛЯ ЖИВОГО ВРАГА ======
   UT_BATTLE_HUD.DrawLargeEnemy = function(enemy, x, y, w, h)
        local isSelected = false
        if UT_BATTLE_CORE.selectedTarget and UT_BATTLE_CORE.currentTargets then
            local selectedEnemy = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            isSelected = selectedEnemy == enemy
        end
        
        -- Используем новую систему частей
        if UT_ENEMY_PARTS and UT_ENEMY_PARTS.DrawEnemyByParts then
            UT_ENEMY_PARTS.DrawEnemyByParts(enemy, x, y, w, h, isSelected)
        else
            -- Fallback на старую отрисовку
            UT_BATTLE_HUD.DrawLegacyEnemy(enemy, x, y, w, h, isSelected)
        end
    end
    
    -- Старая функция (переименуйте существующую DrawLargeEnemy в DrawLegacyEnemy)
    UT_BATTLE_HUD.DrawLegacyEnemy = function(enemy, x, y, w, h, isSelected)
        
        local scaleX = animData.idleScale
        local scaleY = 1 + (1 - animData.idleScale) * 0.5
        
        local baseW = w * 0.9
        local baseH = h * 0.85
        local spriteW = baseW * scaleX
        local spriteH = baseH * scaleY
        local spriteX = x + (w - spriteW) / 2
        local spriteY = y + (h - spriteH) / 2
        
        local shakeX = 0
        local shakeY = 0
        if isSelected then
            shakeX = math.sin(CurTime() * 20) * 2
            shakeY = math.cos(CurTime() * 18) * 1
        end
        
        local material = UT_BATTLE_HUD.GetEnemyMaterial(enemy.class or "npc_zombie")
        
        if material and not material:IsError() then
            surface.SetDrawColor(0, 0, 0, 220)
            for i = 1, 5 do
                surface.DrawOutlinedRect(spriteX - i + shakeX, spriteY - i + shakeY, 
                    spriteW + i*2, spriteH + i*2, 1)
            end
            
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
            surface.DrawTexturedRect(spriteX + shakeX, spriteY + shakeY, spriteW, spriteH)
            
            if isSelected then
                surface.SetDrawColor(255, 255, 0, 220)
                for i = 1, 6 do
                    surface.DrawOutlinedRect(spriteX - i - 3 + shakeX, spriteY - i - 3 + shakeY, 
                        spriteW + (i+3)*2, spriteH + (i+3)*2, 2)
                end
            end
        else
            surface.SetDrawColor(200, 50, 50, 220)
            surface.DrawRect(spriteX + shakeX, spriteY + shakeY, spriteW, spriteH)
            
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawOutlinedRect(spriteX - 3 + shakeX, spriteY - 3 + shakeY, spriteW + 6, spriteH + 6, 5)
            
            draw.SimpleTextOutlined(enemy.class or "ENEMY", "UT_EnemyName", 
                x + w/2 + shakeX, y + h/2 + shakeY, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                3, Color(0, 0, 0, 200))
        end
        
        if enemy.hp > 0 then
            local nameY = y + h + 10
            draw.SimpleTextOutlined(enemy.name or "Враг", "UT_EnemyName", 
                x + w/2, nameY, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                3, Color(0, 0, 0, 200))
            
            local hpPercent = math.max(0, enemy.hp / enemy.maxhp)
            local hpBarW = w * 0.8
            local hpBarH = 15
            local hpBarX = x + (w - hpBarW) / 2
            local hpBarY = nameY + 30
            
            surface.SetDrawColor(50, 50, 50, 200)
            surface.DrawRect(hpBarX, hpBarY, hpBarW, hpBarH)
            surface.SetDrawColor(0, 0, 0, 180)
            surface.DrawOutlinedRect(hpBarX - 2, hpBarY - 2, hpBarW + 4, hpBarH + 4, 3)
            
            local hpColor
            if hpPercent > 0.5 then
                hpColor = Color(0, 255, 0, 255)
            elseif hpPercent > 0.2 then
                hpColor = Color(255, 255, 0, 255)
            else
                hpColor = Color(255, 50, 0, 255)
                local pulse = math.sin(CurTime() * 5) * 0.3 + 0.7
                hpColor = Color(255 * pulse, 50 * pulse, 0, 255)
            end
            
            surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 255)
            surface.DrawRect(hpBarX, hpBarY, hpBarW * hpPercent, hpBarH)
            
            draw.SimpleTextOutlined(math.ceil(enemy.hp) .. "/" .. enemy.maxhp, "UT_EnemyName", 
                x + w/2, hpBarY - 20, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                2, Color(0, 0, 0, 200))
        end
    end
    
    -- ====== ФУНКЦИЯ ДЛЯ МЕРТВОГО ВРАГА ======
    UT_BATTLE_HUD.DrawDeadEnemy = function(enemy, x, y, w, h)
        local animData = UT_BATTLE_HUD.InitEnemyAnimation(enemy)
        animData = UT_BATTLE_HUD.UpdateEnemyAnimation(enemy, animData)
        
        local alpha = 255 * (1 - animData.deathAnimProgress)
        
        if alpha <= 0 then
            return
        end
        
        local scale = 1 - animData.deathAnimProgress * 0.5
        local spriteW = w * 0.8 * scale
        local spriteH = h * 0.75 * scale
        local spriteX = x + (w - spriteW) / 2
        local spriteY = y + (h - spriteH) / 2
        
        local material = UT_BATTLE_HUD.GetEnemyMaterial(enemy.class or "npc_zombie")
        if material then
            surface.SetDrawColor(100, 100, 100, alpha * 0.7)
            surface.SetMaterial(material)
            surface.DrawTexturedRect(spriteX, spriteY, spriteW, spriteH)
        end
    end
    
    -- ====== ФУНКЦИЯ ОТРИСОВКИ ВРАГОВ ======
    UT_BATTLE_HUD.DrawEnemiesOnGrid = function()
        if not UT_BATTLE_CORE.currentTargets or #UT_BATTLE_CORE.currentTargets == 0 then 
            return 
        end
        
        local gridW = 1609
        local gridH = 580
        local gridX = ScrW()/2 - gridW/2
        local gridY = ScrH() * 0.03
        
        local gridMaterial = UT_BATTLE_HUD.GetGridMaterial()
        if gridMaterial then
            surface.SetDrawColor(255, 255, 255, 180)
            surface.SetMaterial(gridMaterial)
            surface.DrawTexturedRect(gridX, gridY, gridW, gridH)
        end
        
        local enemies = UT_BATTLE_CORE.currentTargets
        local enemyCount = #enemies
        
        if enemyCount == 1 then
            local enemy = enemies[1]
            local enemyWidth = 500
            local enemyHeight = 400
            local enemyX = ScrW()/2 - enemyWidth/2
            local enemyY = gridY + gridH/2 - enemyHeight/2
            
            if enemy.hp > 0 then
                UT_BATTLE_HUD.DrawLargeEnemy(enemy, enemyX, enemyY - 50, enemyWidth, enemyHeight)
            else
                UT_BATTLE_HUD.DrawDeadEnemy(enemy, enemyX, enemyY - 50, enemyWidth, enemyHeight)
            end
            
        elseif enemyCount == 2 then
            local enemyWidth = 450
            local enemyHeight = 380
            local spacing = 200
            
            for i, enemy in ipairs(enemies) do
                local enemyX
                if i == 1 then
                    enemyX = ScrW()/2 - enemyWidth - spacing/2
                else
                    enemyX = ScrW()/2 + spacing/2
                end
                local enemyY = gridY + gridH/2 - enemyHeight/2 - 40
                
                if enemy.hp > 0 then
                    UT_BATTLE_HUD.DrawLargeEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                else
                    UT_BATTLE_HUD.DrawDeadEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                end
            end
            
        elseif enemyCount == 3 then
            local enemyWidth = 400
            local enemyHeight = 350
            
            local positions = {
                {x = ScrW()/2 - enemyWidth/2, y = gridY + 50},
                {x = ScrW()/2 - enemyWidth - 100, y = gridY + gridH - enemyHeight - 50},
                {x = ScrW()/2 + 100, y = gridY + gridH - enemyHeight - 50}
            }
            
            for i, enemy in ipairs(enemies) do
                if positions[i] then
                    if enemy.hp > 0 then
                        UT_BATTLE_HUD.DrawLargeEnemy(enemy, positions[i].x, positions[i].y, enemyWidth, enemyHeight)
                    else
                        UT_BATTLE_HUD.DrawDeadEnemy(enemy, positions[i].x, positions[i].y, enemyWidth, enemyHeight)
                    end
                end
            end
            
        else
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
                    UT_BATTLE_HUD.DrawDeadEnemy(enemy, enemyX, enemyY, enemyWidth, enemyHeight)
                end
            end
        end
        
        if UT_BATTLE_CORE.battleMode == "FIGHT" and UT_BATTLE_CORE.selectedTarget then
            local selectedEnemy = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            if selectedEnemy and selectedEnemy.hp > 0 then
                local arrowX, arrowY, arrowSize
                
                if enemyCount == 1 then
                    arrowX = ScrW()/2 + 300
                    arrowY = ScrH() * 0.25 + 100
                    arrowSize = 40
                elseif enemyCount == 2 then
                    local targetIndex = UT_BATTLE_CORE.selectedTarget
                    arrowX = (targetIndex == 1) and (ScrW()/2 - 550) or (ScrW()/2 + 550)
                    arrowY = ScrH() * 0.25 + 100
                    arrowSize = 35
                else
                    arrowX = ScrW()/2 + 400
                    arrowY = ScrH() * 0.25 + 100
                    arrowSize = 30
                end
                
                surface.SetDrawColor(255, 255, 0, 255)
                surface.DrawPoly({
                    {x = arrowX, y = arrowY - arrowSize},
                    {x = arrowX + arrowSize, y = arrowY},
                    {x = arrowX, y = arrowY + arrowSize}
                })
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawPoly({
                    {x = arrowX - 2, y = arrowY - arrowSize - 2},
                    {x = arrowX + arrowSize + 2, y = arrowY},
                    {x = arrowX - 2, y = arrowY + arrowSize + 2}
                })
                
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
        
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            UT_BATTLE_CORE.dialogPanel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                draw.SimpleText(UT_BATTLE_HUD.currentMessage, "UT_Pixel", w/2, h/2 - 20, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER)
                
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Pixel", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- ====== ФУНКЦИЯ ПЕЧАТАНИЯ ТЕКСТА ======
    function UT_BATTLE_HUD.ShowTypingDialogText(message, panel, onComplete)
        if not IsValid(panel) then return end
        
        local fullText = message
        local charIndex = 0
        local displayedText = ""
        local lastCharTime = CurTime()
        local typingSpeed = 0.05
        local isComplete = false
        
        local hookId = "UT_DialogTyping_" .. tostring(panel)
        
        if panel.typingActive then
            hook.Remove("Think", hookId)
            panel.typingActive = false
        end
        
        panel.typingActive = true
        panel.Paint = nil
        
        local function UpdateTyping()
            if not IsValid(panel) then 
                hook.Remove("Think", hookId)
                return 
            end
            
            if isComplete then return end
            
            local currentTime = CurTime()
            
            if currentTime - lastCharTime >= typingSpeed then
                if charIndex < #fullText then
                    charIndex = charIndex + 1
                    displayedText = string.sub(fullText, 1, charIndex)
                    lastCharTime = currentTime
                    
                    if UT_SOUNDS and UT_SOUNDS.PlayTypingSound then
                        UT_SOUNDS.PlayTypingSound()
                    end
                    
                    panel:InvalidateLayout()
                else
                    isComplete = true
                    panel.typingActive = false
                    if onComplete then
                        onComplete()
                    end
                    hook.Remove("Think", hookId)
                end
            end
        end
        
        hook.Add("Think", hookId, UpdateTyping)
        
        panel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 230))
            surface.SetDrawColor(255, 255, 255, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            local cleanText = displayedText
            if cleanText then
                cleanText = cleanText:gsub("%!%!", "!")
                cleanText = cleanText:gsub("%?%?", "?")
            end
            
            draw.SimpleText(cleanText or "", "UT_Pixel", 
                w/2, h/2 - 20, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            if not isComplete and math.floor(CurTime() * 12) % 2 == 0 then
                surface.SetFont("UT_Pixel")
                local textWidth = surface.GetTextSize(cleanText or "")
                draw.SimpleText("_", "UT_Pixel", 
                    w/2 + textWidth/2 + 8, h/2 - 20,
                    Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            draw.SimpleText("HP "..(UT_BATTLE_CORE and UT_BATTLE_CORE.playerHp or 20).." / 20", "UT_Pixel_Small", 
                w - 20, h - 25, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
        end
    end
    
    -- ====== ОБНОВЛЕНИЕ ДИАЛОГОВОЙ ПАНЕЛИ ======
    UT_BATTLE_HUD.UpdateDialogPanel = function()
        if not UT_BATTLE_CORE or not IsValid(UT_BATTLE_CORE.dialogPanel) then 
            return 
        end
        
        local panel = UT_BATTLE_CORE.dialogPanel
        
        if UT_BATTLE_CORE.battleMode == "MENU" then
            local dialogText = ""
            local showExtraText = false
            local extraText = ""
            
            if UT_BATTLE_CORE.currentEnemy and UT_BATTLE_CORE.currentEnemy.data then
                local enemyData = UT_BATTLE_CORE.currentEnemy.data
                if enemyData.dialog and #enemyData.dialog > 0 then
                    dialogText = enemyData.dialog[math.random(#enemyData.dialog)]
                else
                    dialogText = "* Враг перед вами..."
                end
            else
                dialogText = "* Что вы будете делать?"
            end
            showExtraText = true
            extraText = "Что вы будете делать?"
            
            dialogText = dialogText:gsub("%!%!", "!")
            dialogText = dialogText:gsub("%?%?", "?")
            
            if dialogText ~= "" then
                UT_BATTLE_HUD.ShowTypingDialogText(dialogText, panel, function()
                    if showExtraText and extraText ~= "" then
                        timer.Simple(0.3, function()
                            if IsValid(panel) then
                                panel.Paint = function(self, w, h)
                                    draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 230))
                                    surface.SetDrawColor(255, 255, 255, 150)
                                    surface.DrawOutlinedRect(0, 0, w, h, 2)
                                    
                                    draw.SimpleText(dialogText, "UT_Pixel", 
                                        w/2, h/2 - 30, 
                                        Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                    
                                    draw.SimpleText(extraText, "UT_Pixel", 
                                        w/2, h/2 + 10, 
                                        Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                    
                                    draw.SimpleText("HP "..(UT_BATTLE_CORE.playerHp or 20).." / 20", "UT_Pixel_Small", 
                                        w - 20, h - 25, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
                                end
                            end
                        end)
                    end
                end)
            end
            
        elseif UT_BATTLE_CORE.battleMode == "FIGHT" and not UT_BATTLE_CORE.attackInProgress then
            panel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                if UT_BATTLE_CORE.currentTargets and #UT_BATTLE_CORE.currentTargets > 0 then
                    local startY = 30
                    local lineHeight = 40
                    
                    draw.SimpleText("Кого атаковать?", "UT_Pixel", 50, 20, Color(255, 255, 255))
                    
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
                        
                        local enemyText = prefix .. enemy.name
                        draw.SimpleText(enemyText, "UT_Pixel", 70, yPos, color)
                        
                        if enemy.hp > 0 then
                            local hpColor = Color(255, 255, 255)
                            local hpPercent = enemy.hp / enemy.maxhp
                            if hpPercent < 0.3 then
                                hpColor = Color(255, 50, 50)
                            elseif hpPercent < 0.7 then
                                hpColor = Color(255, 255, 50)
                            else
                                hpColor = Color(50, 255, 50)
                            end
                            
                            draw.SimpleText("♥ " .. math.ceil(enemy.hp) .. "/" .. enemy.maxhp, "UT_Pixel", 
                                w - 50, yPos, hpColor, TEXT_ALIGN_RIGHT)
                        else
                            draw.SimpleText("МЕРТВ", "UT_Pixel", 
                                w - 50, yPos, Color(200, 50, 50), TEXT_ALIGN_RIGHT)
                        end
                    end
                    
                    draw.SimpleText("↑ ↓ - Выбор цели", "UT_Small", 50, h - 60, Color(200, 200, 255))
                    draw.SimpleText("ENTER - Атаковать", "UT_Small", 50, h - 35, Color(200, 255, 200))
                    draw.SimpleText("ESC - Назад", "UT_Small", w - 50, h - 35, Color(255, 200, 200), TEXT_ALIGN_RIGHT)
                end
                
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Pixel", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
            
        elseif UT_BATTLE_CORE.battleMode == "ACT_TARGET" then
            panel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                if UT_BATTLE_CORE.currentTargets and #UT_BATTLE_CORE.currentTargets > 0 then
                    local startY = 30
                    local lineHeight = 40
                    
                    draw.SimpleText("На кого применить действие?", "UT_Pixel", 50, 20, Color(255, 255, 255))
                    
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
                        
                        local enemyText = prefix .. enemy.name
                        draw.SimpleText(enemyText, "UT_Pixel", 70, yPos, color)
                        
                        if enemy.hp > 0 then
                            local hpColor = Color(255, 255, 255)
                            local hpPercent = enemy.hp / enemy.maxhp
                            if hpPercent < 0.3 then
                                hpColor = Color(255, 50, 50)
                            elseif hpPercent < 0.7 then
                                hpColor = Color(255, 255, 50)
                            else
                                hpColor = Color(50, 255, 50)
                            end
                            
                            draw.SimpleText("♥ " .. math.ceil(enemy.hp) .. "/" .. enemy.maxhp, "UT_Pixel", 
                                w - 50, yPos, hpColor, TEXT_ALIGN_RIGHT)
                        else
                            draw.SimpleText("МЕРТВ", "UT_Pixel", 
                                w - 50, yPos, Color(200, 50, 50), TEXT_ALIGN_RIGHT)
                        end
                    end
                    
                    draw.SimpleText("↑ ↓ - Выбор цели", "UT_Small", 50, h - 60, Color(200, 200, 255))
                    draw.SimpleText("ENTER - Подтвердить", "UT_Small", 50, h - 35, Color(200, 255, 200))
                    draw.SimpleText("ESC - Назад", "UT_Small", w - 50, h - 35, Color(255, 200, 200), TEXT_ALIGN_RIGHT)
                end
                
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Pixel", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
            
        elseif UT_BATTLE_CORE.battleMode == "ACT" then
            panel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                local target = UT_BATTLE_CORE.currentTargets and UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
                local actions = {}
                
                if target and target.class and UT_ENEMY_DATA then
                    local enemy_data = UT_ENEMY_DATA.Get(target.class)
                    if enemy_data and enemy_data.acts then
                        for _, act in ipairs(enemy_data.acts) do
                            table.insert(actions, act.name)
                        end
                    end
                end
                
                if #actions == 0 then
                    actions = {"ПРОВЕРИТЬ", "ПОГОВОРИТЬ", "ПОЩАДИТЬ"}
                end
                
                draw.SimpleText("* Выберите действие", "UT_Pixel", 50, 50, Color(255, 255, 255))
                
                for i, action in ipairs(actions) do
                    local yPos = 100 + (i-1) * 50
                    local color = Color(255, 255, 255)
                    
                    if i == (UT_BATTLE_CORE.selectedAct or 1) then
                        color = Color(255, 255, 0)
                        draw.SimpleText("►", "UT_Pixel", 50, yPos, color)
                    end
                    
                    draw.SimpleText("* "..action, "UT_Pixel", 90, yPos, color)
                end
                
                draw.SimpleText("↑ ↓ - Выбор действия", "UT_Small", 50, h - 60, Color(200, 200, 255))
                draw.SimpleText("ENTER - Выполнить", "UT_Small", 50, h - 35, Color(200, 255, 200))
                draw.SimpleText("ESC - Назад", "UT_Small", w - 50, h - 35, Color(255, 200, 200), TEXT_ALIGN_RIGHT)
                
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Pixel", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
            
        elseif UT_BATTLE_CORE.battleMode == "ATTACK" then
            panel.Paint = function(self, w, h)
                surface.SetDrawColor(30, 30, 50, 200)
                surface.DrawRect(0, 0, w, h)
                
                surface.SetDrawColor(255, 255, 255, 30)
                for i = 0, w, 50 do
                    surface.DrawLine(i, 0, i, h)
                end
                for i = 0, h, 50 do
                    surface.DrawLine(0, i, w, i)
                end
                
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
                    
                draw.SimpleText("АТАКА!", "UT_Attack", w/2, 30, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER)
                
                if UT_BATTLE_CORE.attackActive or UT_BATTLE_CORE.attackResult then
                    local barColor = Color(255, 255, 255)
                    if UT_BATTLE_CORE.attackResult == "hit" then
                        barColor = Color(0, 255, 0)
                    elseif UT_BATTLE_CORE.attackResult == "critical" then
                        barColor = Color(255, 255, 0)
                    elseif UT_BATTLE_CORE.attackResult == "miss" then
                        barColor = Color(255, 50, 50)
                    end
                    
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
                    
                    draw.SimpleText(resultText, "UT_Pixel", w/2, h - 50, 
                        resultColor, TEXT_ALIGN_CENTER)
                end
                
                if UT_BATTLE_CORE.attackActive then
                    draw.SimpleText("Нажмите ПРОБЕЛ когда полоска в зелёной зоне!", "UT_Small", 
                        w/2, h - 80, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                end
            end
            
        elseif UT_BATTLE_CORE.battleMode == "HEART_PHASE" then
            panel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                if UT_BATTLE_HUD.currentMessage ~= "" then
                    draw.SimpleText(UT_BATTLE_HUD.currentMessage, "UT_Pixel", 50, 50, 
                        Color(255, 255, 255))
                else
                    draw.SimpleText("* Враг атакует! Уклоняйтесь!", "UT_Pixel", 50, 50, 
                        Color(255, 255, 255))
                end
                
                local player_hp = UT_HEART_CORE and UT_HEART_CORE.player and UT_HEART_CORE.player.hp or (UT_BATTLE_CORE.playerHp or 20)
                draw.SimpleText("ВАШЕ HP: "..player_hp.."/20", "UT_Pixel", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                    
                draw.SimpleText("← ↑ ↓ → - Уклонение", "UT_Small", 
                    w/2, h - 60, Color(200, 200, 255), TEXT_ALIGN_CENTER)
            end
        end
    end
    
-- ====== СОЗДАНИЕ БОЕВОГО МЕНЮ ======
UT_BATTLE_HUD.CreateBattleMenu = function()
    print("[UNDERTALE] Создание боевого меню с PNG фоном...")
    
    if not UT_BATTLE_CORE then
        print("[UNDERTALE] КРИТИЧЕСКАЯ ОШИБКА: UT_BATTLE_CORE не существует!")
        chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
            "Ядро боевой системы не загружено!")
        return
    end
    
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
    UT_BATTLE_CORE.selectedAct = 1
    UT_BATTLE_CORE.battleMode = "MENU"
    UT_BATTLE_CORE.keyCooldown = 0
    UT_BATTLE_CORE.btnImages = {}
    UT_BATTLE_CORE.attackActive = false
    UT_BATTLE_CORE.attackInProgress = false
    UT_BATTLE_CORE.attackResult = nil
    
    if not UT_BATTLE_CORE.buttons then
        UT_BATTLE_CORE.buttons = {
            { name = "FIGHT", normal = "undertale/attack.png", selected = "undertale/attack_use.png" },
            { name = "ACT", normal = "undertale/act.png", selected = "undertale/act_use.png" },
            { name = "ITEM", normal = "undertale/item.png", selected = "undertale/item_use.png" },
            { name = "MERCY", normal = "undertale/mercy.png", selected = "undertale/mercy_use.png" }
        }
    end
    
    if not UT_BATTLE_CORE.currentTargets or #UT_BATTLE_CORE.currentTargets == 0 then
        UT_BATTLE_CORE.currentTargets = {
            {name = "СОЛДАТ", hp = 30, maxhp = 30, class = "npc_combine_s"},
            {name = "ЗОМБИ", hp = 25, maxhp = 25, class = "npc_zombie"},
            {name = "АНТЛИОН", hp = 35, maxhp = 35, class = "npc_antlion_s"},
            {name = "РАБОЧИЙ", hp = 20, maxhp = 20, class = "npc_antlionworker"}
        }
    end
    
    if IsValid(UT_BATTLE_CORE.battleFrame) then UT_BATTLE_CORE.battleFrame:Remove() end
    
    UT_BATTLE_CORE.battleFrame = vgui.Create("DFrame")
    UT_BATTLE_CORE.battleFrame:SetSize(ScrW(), ScrH())
    UT_BATTLE_CORE.battleFrame:SetPos(0, 0)
    UT_BATTLE_CORE.battleFrame:SetTitle("")
    UT_BATTLE_CORE.battleFrame:ShowCloseButton(false)
    UT_BATTLE_CORE.battleFrame:SetDraggable(false)
    UT_BATTLE_CORE.battleFrame:MakePopup()
    UT_BATTLE_CORE.battleFrame:SetKeyboardInputEnabled(true)
    
    UT_BATTLE_CORE.battleFrame.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        
        UT_BATTLE_HUD.DrawEnemiesOnGrid()
        
        -- Рисуем эффекты ПОВЕРХ врагов
        if UT_DAMAGE_EFFECT and UT_DAMAGE_EFFECT.DrawEffectsOnPanel then
            UT_DAMAGE_EFFECT.DrawEffectsOnPanel()
        end
        
        local dialogY = ScrH() * 0.55
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(0, dialogY - 50, w, h - dialogY + 50)
        
        for i = 0, 50 do
            local alpha = 255 * (1 - i/50)
            surface.SetDrawColor(0, 0, 0, alpha)
            surface.DrawRect(0, i, w, 1)
        end
        
        draw.SimpleText("UNDERTALE BATTLE SYSTEM", "UT_Small", 20, 20, 
            Color(0, 255, 0, 150))
    end
    
    local dialogW = 900
    local dialogH = 250
    UT_BATTLE_CORE.dialogPanel = vgui.Create("DPanel", UT_BATTLE_CORE.battleFrame)
    UT_BATTLE_CORE.dialogPanel:SetSize(dialogW, dialogH)
    UT_BATTLE_CORE.dialogPanel:SetPos(ScrW()/2 - dialogW/2, ScrH() * 0.55)
    
    UT_BATTLE_HUD.UpdateDialogPanel()
    
    UT_BATTLE_CORE.btnPanel = vgui.Create("DPanel", UT_BATTLE_CORE.battleFrame)
    UT_BATTLE_CORE.btnPanel:SetSize(ScrW(), 130)
    UT_BATTLE_CORE.btnPanel:SetPos(0, ScrH() - 130)
    UT_BATTLE_CORE.btnPanel.Paint = function() end
    
    -- Слой для эффектов поверх всего
    UT_BATTLE_CORE.effectLayer = vgui.Create("DPanel", UT_BATTLE_CORE.battleFrame)
    UT_BATTLE_CORE.effectLayer:SetSize(ScrW(), ScrH())
    UT_BATTLE_CORE.effectLayer:SetPos(0, 0)
    UT_BATTLE_CORE.effectLayer:SetZPos(100)
    UT_BATTLE_CORE.effectLayer.Paint = function(self, w, h)
        if UT_DAMAGE_EFFECT and UT_DAMAGE_EFFECT.DrawEffectsOnPanel then
            UT_DAMAGE_EFFECT.DrawEffectsOnPanel()
        end
    end
    
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
            
            local simpleBtn = vgui.Create("DButton", btnContainer)
            simpleBtn:SetSize(btnW, btnH)
            simpleBtn:SetPos(0, 0)
            simpleBtn:SetText(data.name)
            simpleBtn:SetFont("UT_Pixel")
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
    
    local fightBtnIndex = 1
    local fightBtnX = 0
    local fightBtnWidth = 0
    
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
    
    UT_BATTLE_CORE.battleFrame.OnKeyCodePressed = function(self, key)
        if UT_BATTLE_INPUT and UT_BATTLE_INPUT.HandleKeyPress then
            UT_BATTLE_INPUT.HandleKeyPress(key)
        end
    end
    
    if UT_BATTLE_INPUT and UT_BATTLE_INPUT.SetupInputHook then
        UT_BATTLE_INPUT.SetupInputHook()
    end
    
    print("[UNDERTALE] Боевое меню с PNG фоном создано!")
    chat.AddText(Color(0, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "Бой начат!")
    chat.AddText(Color(255, 255, 0), "[ПОДСКАЗКА] ", Color(255, 255, 255), 
        "← → для выбора действия, ↑ ↓ для выбора цели/действия, ENTER для подтверждения")
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
    
    -- Получить позицию врага на экране
    function UT_BATTLE_HUD.GetEnemyPosition(enemy)
        if not enemy then return ScrW()/2 - 110, ScrH() * 0.2, 220, 270 end
        
        local enemies = UT_BATTLE_CORE.currentTargets
        local enemyCount = #enemies
        
        local enemyIndex = 1
        for i, e in ipairs(enemies) do
            if e == enemy then
                enemyIndex = i
                break
            end
        end
        
        local gridY = ScrH() * 0.03
        local gridH = 580
        
        if enemyCount == 1 then
            return ScrW()/2 - 250, gridY + gridH/2 - 200 - 50, 500, 400
        elseif enemyCount == 2 then
            local spacing = 200
            if enemyIndex == 1 then
                return ScrW()/2 - 450 - spacing/2, gridY + gridH/2 - 190 - 40, 450, 380
            else
                return ScrW()/2 + spacing/2, gridY + gridH/2 - 190 - 40, 450, 380
            end
        else
            local enemyWidth = 220
            local totalWidth = enemyWidth * enemyCount + 100 * (enemyCount - 1)
            local startX = ScrW()/2 - totalWidth/2
            return startX + (enemyIndex - 1) * (enemyWidth + 100), gridY + 330, 220, 270
        end
    end

    -- Показ числа урона
    function UT_BATTLE_HUD.ShowDamageNumber(damage, is_critical)
        if not IsValid(UT_BATTLE_CORE.dialogPanel) then return end
        
        local damage_number = {
            value = damage,
            is_critical = is_critical,
            x = ScrW() / 2,
            y = ScrH() * 0.55 + 125,
            alpha = 255,
            scale = 1.0,
            lifetime = 0
        }
        
        local function DrawDamageNumber()
            if damage_number.lifetime > 1.5 then
                hook.Remove("HUDPaint", "UT_DamageNumber")
                return
            end
            
            damage_number.lifetime = damage_number.lifetime + FrameTime()
            damage_number.y = damage_number.y - 100 * FrameTime()
            damage_number.alpha = 255 * (1 - damage_number.lifetime / 1.5)
            damage_number.scale = 1 + damage_number.lifetime
            
            local color = damage_number.is_critical and Color(255, 255, 0) or Color(255, 255, 255)
            color.a = damage_number.alpha
            
            draw.SimpleText(
                tostring(damage_number.value),
                "UT_Attack",
                damage_number.x,
                damage_number.y,
                color,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end
        
        hook.Add("HUDPaint", "UT_DamageNumber", DrawDamageNumber)
        
        if is_critical then
            UT_BATTLE_HUD.ScreenShake(5, 0.3)
        end
    end
    
    -- Тряска экрана
    function UT_BATTLE_HUD.ScreenShake(intensity, duration)
        local start_time = CurTime()
        
        local function ApplyShake()
            if CurTime() - start_time > duration then
                hook.Remove("HUDPaint", "UT_ScreenShake")
                return
            end
            
            local progress = (CurTime() - start_time) / duration
            local current_intensity = intensity * (1 - progress)
            
            local shake_x = math.sin(CurTime() * 50) * current_intensity
            local shake_y = math.cos(CurTime() * 47) * current_intensity
            
            if IsValid(UT_BATTLE_CORE.dialogPanel) then
                UT_BATTLE_CORE.dialogPanel:SetPos(
                    ScrW()/2 - 450 + shake_x,
                    ScrH() * 0.55 + shake_y
                )
            end
        end
        
        hook.Add("HUDPaint", "UT_ScreenShake", ApplyShake)
        
        timer.Simple(duration + 0.1, function()
            if IsValid(UT_BATTLE_CORE.dialogPanel) then
                UT_BATTLE_CORE.dialogPanel:SetPos(ScrW()/2 - 450, ScrH() * 0.55)
            end
        end)
    end
    
    print("[UNDERTALE] Модуль интерфейса с анимацией врагов загружен")
end