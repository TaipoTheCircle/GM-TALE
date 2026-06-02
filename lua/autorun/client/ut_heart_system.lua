-- ФАЙЛ: ut_heart_system.lua (ПОЛНАЯ РАБОЧАЯ ВЕРСИЯ)
if CLIENT then
    print("[UNDERTALE] Загрузка системы разных цветов души...")
    
    UT_HEART_SYSTEM = UT_HEART_SYSTEM or {}
    
    -- Текущий тип души
    UT_HEART_SYSTEM.currentType = "RED"
    
    -- Состояние для синей души (прыжки)
    UT_HEART_SYSTEM.blueState = {
        isJumping = false,
        jumpStartTime = 0,
        jumpDuration = 0.4,
        jumpHeight = 30,
        jumpVelocity = 0,
        gravity = 800,
        yOffset = 0,
        isOnGround = true
    }
    
    -- Позиция сердца для разных режимов
    UT_HEART_SYSTEM.heartX = 0
    UT_HEART_SYSTEM.heartY = 0
    UT_HEART_SYSTEM.heartYOffset = 0  -- Добавлено!
    
    -- Флаги активности
    UT_HEART_SYSTEM.isActive = false
    UT_HEART_SYSTEM.onDamage = nil
    UT_HEART_SYSTEM.onComplete = nil
    UT_HEART_SYSTEM.startTime = 0
    UT_HEART_SYSTEM.duration = 8
    UT_HEART_SYSTEM.bounds = nil
    UT_HEART_SYSTEM.bullets = {}
    UT_HEART_SYSTEM.attackData = nil
    
    -- Спрайты для разных душ
    UT_HEART_SYSTEM.heartSprites = {
        RED = "undertale/heart_red.png",
        BLUE = "undertale/heart_blue.png",
        GREEN = "undertale/heart_green.png",
        YELLOW = "undertale/heart_yellow.png",
        PURPLE = "undertale/heart_purple.png"
    }
    
    -- Установить тип души
    function UT_HEART_SYSTEM.SetHeartType(heartType)
        UT_HEART_SYSTEM.currentType = heartType
        print("[UNDERTALE] Тип души изменён на: " .. heartType)
        
        -- Сброс состояния синей души
        if heartType ~= "BLUE" then
            UT_HEART_SYSTEM.blueState.isJumping = false
            UT_HEART_SYSTEM.blueState.yOffset = 0
            UT_HEART_SYSTEM.blueState.isOnGround = true
            UT_HEART_SYSTEM.heartYOffset = 0
        end
    end
    
    -- Получить материал души
    function UT_HEART_SYSTEM.GetHeartMaterial()
        local spritePath = UT_HEART_SYSTEM.heartSprites[UT_HEART_SYSTEM.currentType]
        if spritePath and file.Exists("materials/" .. spritePath, "GAME") then
            local material = Material(spritePath)
            if not material:IsError() then
                return material
            end
        end
        return nil
    end
    
    -- Обновление синей души (прыжки)
    function UT_HEART_SYSTEM.UpdateBlueHeart(dt, leftPressed, rightPressed, upPressed, downPressed, jumpPressed)
        local bounds = UT_HEART_SYSTEM.bounds or {left = 100, right = ScrW() - 100, top = 300, bottom = 700}
        local heartSize = 20
        
        -- Горизонтальное движение
        local moveSpeed = 300
        if leftPressed then
            UT_HEART_SYSTEM.heartX = UT_HEART_SYSTEM.heartX - moveSpeed * dt
        end
        if rightPressed then
            UT_HEART_SYSTEM.heartX = UT_HEART_SYSTEM.heartX + moveSpeed * dt
        end
        
        -- Границы по горизонтали
        UT_HEART_SYSTEM.heartX = math.Clamp(UT_HEART_SYSTEM.heartX, 
            bounds.left + heartSize, 
            bounds.right - heartSize)
        
        -- Прыжок
        if jumpPressed and UT_HEART_SYSTEM.blueState.isOnGround then
            UT_HEART_SYSTEM.blueState.isJumping = true
            UT_HEART_SYSTEM.blueState.isOnGround = false
            UT_HEART_SYSTEM.blueState.jumpVelocity = -400
            UT_HEART_SYSTEM.blueState.jumpStartTime = CurTime()
        end
        
        -- Физика прыжка
        if UT_HEART_SYSTEM.blueState.isJumping then
            UT_HEART_SYSTEM.blueState.jumpVelocity = UT_HEART_SYSTEM.blueState.jumpVelocity + UT_HEART_SYSTEM.blueState.gravity * dt
            UT_HEART_SYSTEM.blueState.yOffset = UT_HEART_SYSTEM.blueState.yOffset + UT_HEART_SYSTEM.blueState.jumpVelocity * dt
            
            -- Приземление
            if UT_HEART_SYSTEM.blueState.yOffset >= 0 then
                UT_HEART_SYSTEM.blueState.isJumping = false
                UT_HEART_SYSTEM.blueState.isOnGround = true
                UT_HEART_SYSTEM.blueState.yOffset = 0
                UT_HEART_SYSTEM.blueState.jumpVelocity = 0
            end
        end
        
        UT_HEART_SYSTEM.heartYOffset = UT_HEART_SYSTEM.blueState.yOffset
        
        return UT_HEART_SYSTEM.heartX, UT_HEART_SYSTEM.heartYOffset
    end
    
    -- Обновление красной души (свободное движение)
    function UT_HEART_SYSTEM.UpdateRedHeart(dt, leftPressed, rightPressed, upPressed, downPressed)
        local bounds = UT_HEART_SYSTEM.bounds or {left = 100, right = ScrW() - 100, top = 300, bottom = 700}
        local heartSize = 20
        local moveSpeed = 300
        
        if leftPressed then
            UT_HEART_SYSTEM.heartX = UT_HEART_SYSTEM.heartX - moveSpeed * dt
        end
        if rightPressed then
            UT_HEART_SYSTEM.heartX = UT_HEART_SYSTEM.heartX + moveSpeed * dt
        end
        if upPressed then
            UT_HEART_SYSTEM.heartY = UT_HEART_SYSTEM.heartY - moveSpeed * dt
        end
        if downPressed then
            UT_HEART_SYSTEM.heartY = UT_HEART_SYSTEM.heartY + moveSpeed * dt
        end
        
        UT_HEART_SYSTEM.heartX = math.Clamp(UT_HEART_SYSTEM.heartX, 
            bounds.left + heartSize, 
            bounds.right - heartSize)
        UT_HEART_SYSTEM.heartY = math.Clamp(UT_HEART_SYSTEM.heartY, 
            bounds.top + heartSize, 
            bounds.bottom - heartSize)
        
        return UT_HEART_SYSTEM.heartX, UT_HEART_SYSTEM.heartY
    end
    
    -- Отрисовка сердца
    function UT_HEART_SYSTEM.DrawHeart(x, y, size, isSelected)
        local material = UT_HEART_SYSTEM.GetHeartMaterial()
        
        if material then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
            surface.DrawTexturedRect(x - size, y - size, size * 2, size * 2)
        else
            -- Запасной вариант: цветной ромб
            local colors = {
                RED = Color(255, 0, 0),
                BLUE = Color(0, 100, 255),
                GREEN = Color(0, 255, 0),
                YELLOW = Color(255, 255, 0),
                PURPLE = Color(160, 32, 240)
            }
            local color = colors[UT_HEART_SYSTEM.currentType] or Color(255, 0, 0)
            
            surface.SetDrawColor(color.r, color.g, color.b, 255)
            draw.NoTexture()
            
            local points = {
                {x = x, y = y - size},
                {x = x + size, y = y},
                {x = x, y = y + size},
                {x = x - size, y = y}
            }
            surface.DrawPoly(points)
        end
        
        if isSelected then
            surface.SetDrawColor(255, 255, 0, 200)
            for i = 1, 3 do
                surface.DrawOutlinedRect(x - size - i, y - size - i, size * 2 + i*2, size * 2 + i*2, 2)
            end
        end
    end
    
    -- Think (обновление)
    function UT_HEART_SYSTEM.Think()
        if not UT_HEART_SYSTEM.isActive then return end
        
        local dt = FrameTime()
        local leftPressed = input.IsKeyDown(KEY_LEFT)
        local rightPressed = input.IsKeyDown(KEY_RIGHT)
        local upPressed = input.IsKeyDown(KEY_UP)
        local downPressed = input.IsKeyDown(KEY_DOWN)
        local jumpPressed = input.IsKeyDown(KEY_SPACE)
        
        if UT_HEART_SYSTEM.currentType == "BLUE" then
            local x, yOffset = UT_HEART_SYSTEM.UpdateBlueHeart(dt, leftPressed, rightPressed, upPressed, downPressed, jumpPressed)
            UT_HEART_SYSTEM.heartX = x
            UT_HEART_SYSTEM.heartYOffset = yOffset
        else
            local x, y = UT_HEART_SYSTEM.UpdateRedHeart(dt, leftPressed, rightPressed, upPressed, downPressed)
            UT_HEART_SYSTEM.heartX = x
            UT_HEART_SYSTEM.heartY = y
        end
    end
    
    -- Отрисовка (только сердце, без фона)
    function UT_HEART_SYSTEM.Draw()
        if not UT_HEART_SYSTEM.isActive then return end
        
        local bounds = UT_HEART_SYSTEM.bounds
        if not bounds then return end
        
        local heartSize = 20
        
        -- Рисуем сердце (без фона)
        if UT_HEART_SYSTEM.currentType == "BLUE" then
            UT_HEART_SYSTEM.DrawHeart(UT_HEART_SYSTEM.heartX, 
                (UT_HEART_SYSTEM.bounds.top or 300) + (UT_HEART_SYSTEM.heartYOffset or 0), 
                heartSize, false)
        else
            UT_HEART_SYSTEM.DrawHeart(UT_HEART_SYSTEM.heartX, UT_HEART_SYSTEM.heartY, heartSize, false)
        end
  
        
        -- Подсказка для синей души
        if UT_HEART_SYSTEM.currentType == "BLUE" then
            draw.SimpleText("ПРОБЕЛ - ПРЫЖОК", "UT_Small", 
                ScrW()/2, (bounds.bottom or 700) + 30, 
                Color(200, 200, 255), TEXT_ALIGN_CENTER)
        end
        
        -- Таймер
        if UT_HEART_SYSTEM.startTime > 0 then
            local timeLeft = math.max(0, UT_HEART_SYSTEM.duration - (CurTime() - UT_HEART_SYSTEM.startTime))
            draw.SimpleText(string.format("%.1f", timeLeft), "UT_Small", 
                (bounds.right or ScrW() - 30) - 30, (bounds.top or 300) + 10, 
                Color(255, 255, 255), TEXT_ALIGN_RIGHT)
        end
    end
    
    -- Запуск фазы сердца
    function UT_HEART_SYSTEM.StartHeartPhase(heartType, bounds, onDamage, onComplete, attackData)
        print("[UNDERTALE] Запуск фазы сердца с типом: " .. (heartType or "RED"))
        
        -- Сброс состояния
        UT_HEART_SYSTEM.StopHeartPhase()
        
        UT_HEART_SYSTEM.SetHeartType(heartType or "RED")
        UT_HEART_SYSTEM.bounds = bounds or {left = 100, right = ScrW() - 100, top = 300, bottom = 700}
        
        -- Сброс позиции в центр
        UT_HEART_SYSTEM.heartX = (UT_HEART_SYSTEM.bounds.left + UT_HEART_SYSTEM.bounds.right) / 2
        UT_HEART_SYSTEM.heartY = (UT_HEART_SYSTEM.bounds.top + UT_HEART_SYSTEM.bounds.bottom) / 2
        UT_HEART_SYSTEM.heartYOffset = 0
        
        UT_HEART_SYSTEM.isActive = true
        UT_HEART_SYSTEM.onDamage = onDamage
        UT_HEART_SYSTEM.onComplete = onComplete
        UT_HEART_SYSTEM.startTime = CurTime()
        UT_HEART_SYSTEM.duration = (attackData and attackData.duration) or 8
        UT_HEART_SYSTEM.attackData = attackData
        UT_HEART_SYSTEM.bullets = {}
        
        -- Запуск таймера
        timer.Create("UT_HeartPhaseTimer", UT_HEART_SYSTEM.duration, 1, function()
            if UT_HEART_SYSTEM.isActive then
                UT_HEART_SYSTEM.EndHeartPhase()
            end
        end)
        
        -- Добавляем хуки
        hook.Add("Think", "UT_HeartSystemThink", UT_HEART_SYSTEM.Think)
        hook.Add("HUDPaint", "UT_HeartSystemDraw", UT_HEART_SYSTEM.Draw)
    end
    
    -- Завершение фазы сердца
    function UT_HEART_SYSTEM.EndHeartPhase()
        if not UT_HEART_SYSTEM.isActive then return end
        
        UT_HEART_SYSTEM.isActive = false
        
        timer.Remove("UT_HeartPhaseTimer")
        hook.Remove("Think", "UT_HeartSystemThink")
        hook.Remove("HUDPaint", "UT_HeartSystemDraw")
        
        if UT_HEART_SYSTEM.onComplete then
            UT_HEART_SYSTEM.onComplete()
        end
        
        print("[UNDERTALE] Фаза сердца завершена")
    end
    
    -- Остановка фазы сердца
    function UT_HEART_SYSTEM.StopHeartPhase()
        UT_HEART_SYSTEM.isActive = false
        timer.Remove("UT_HeartPhaseTimer")
        hook.Remove("Think", "UT_HeartSystemThink")
        hook.Remove("HUDPaint", "UT_HeartSystemDraw")
    end
    
    -- Получить урон
    function UT_HEART_SYSTEM.TakeDamage(amount)
        if not UT_HEART_SYSTEM.isActive then return end
        
        if UT_HEART_SYSTEM.onDamage then
            UT_HEART_SYSTEM.onDamage(amount)
        end
    end
    
    print("[UNDERTALE] Система разных цветов души загружена")
end