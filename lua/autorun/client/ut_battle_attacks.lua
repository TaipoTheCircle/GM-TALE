-- ФАЙЛ: ut_battle_attacks.lua
if CLIENT then
    print("[UNDERTALE] Загрузка системы атак врагов...")
    
    UT_BATTLE_ATTACKS = UT_BATTLE_ATTACKS or {}
    
    -- СПРАЙТЫ ДЛЯ АТАК
    UT_BATTLE_ATTACKS.attackSprites = {
        SNIPER = {
            sprite = "undertale/sniper.png",
            width = 32,
            height = 32,
            trail = true,
            trailColor = Color(255, 50, 50, 150)
        },
        WAVE = {
            sprite = "undertale/wave.png",
            width = 40,
            height = 20,
            trail = false,
            trailColor = Color(255, 255, 0, 100)
        },
        CIRCLE = {
            sprite = "undertale/circle.png",
            width = 30,
            height = 30,
            trail = true,
            trailColor = Color(255, 150, 0, 120)
        }
    }
    
    -- Создаем снаряд для атаки
    function UT_BATTLE_ATTACKS.CreateBullet(attackType, startPos, targetPos, speed, color)
        local attackData = UT_BATTLE_ATTACKS.attackSprites[attackType] or UT_BATTLE_ATTACKS.attackSprites.SNIPER
        
        -- Проверяем есть ли спрайт
        local material = Material(attackData.sprite)
        local hasSprite = not material:IsError()
        
        return {
            type = attackType,
            x = startPos.x,
            y = startPos.y,
            targetX = targetPos.x,
            targetY = targetPos.y,
            speed = speed or 200,
            color = color or Color(255, 255, 255),
            width = attackData.width,
            height = attackData.height,
            material = hasSprite and material or nil,
            hasSprite = hasSprite,
            trail = attackData.trail,
            trailPoints = {},
            maxTrailLength = 10,
            alive = true,
            
            -- Расчет направления
            UpdateDirection = function(self)
                local dx = self.targetX - self.x
                local dy = self.targetY - self.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance > 0 then
                    self.vx = (dx / distance) * self.speed
                    self.vy = (dy / distance) * self.speed
                else
                    self.vx = 0
                    self.vy = 0
                end
            end,
            
            -- Обновление позиции
            Update = function(self, dt)
                if not self.alive then return false end
                
                -- Если нет направления, рассчитываем
                if not self.vx then
                    self:UpdateDirection()
                end
                
                -- Обновляем позицию
                self.x = self.x + self.vx * dt
                self.y = self.y + self.vy * dt
                
                -- Добавляем точку в трейл
                if self.trail then
                    table.insert(self.trailPoints, 1, {x = self.x, y = self.y})
                    if #self.trailPoints > self.maxTrailLength then
                        table.remove(self.trailPoints)
                    end
                end
                
                -- Проверяем достижение цели
                local dx = self.targetX - self.x
                local dy = self.targetY - self.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance < 10 then
                    self.alive = false
                    return false
                end
                
                -- Проверяем выход за границы
                if self.x < 0 or self.x > ScrW() or self.y < 0 or self.y > ScrH() then
                    self.alive = false
                    return false
                end
                
                return true
            end,
            
            -- Отрисовка
            Draw = function(self)
                if not self.alive then return end
                
                -- Рисуем трейл
                if self.trail and #self.trailPoints > 1 then
                    local trailColor = UT_BATTLE_ATTACKS.attackSprites[self.type].trailColor
                    
                    for i = 1, #self.trailPoints - 1 do
                        local point1 = self.trailPoints[i]
                        local point2 = self.trailPoints[i + 1]
                        
                        if point1 and point2 then
                            local alpha = (i / #self.trailPoints) * trailColor.a
                            surface.SetDrawColor(trailColor.r, trailColor.g, trailColor.b, alpha)
                            surface.DrawLine(point1.x, point1.y, point2.x, point2.y)
                        end
                    end
                end
                
                -- Рисуем снаряд
                if self.hasSprite and self.material then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(self.material)
                    surface.DrawTexturedRect(
                        self.x - self.width/2,
                        self.y - self.height/2,
                        self.width,
                        self.height
                    )
                    
                    -- Добавляем цветовой оттенок
                    surface.SetDrawColor(self.color.r, self.color.g, self.color.b, 100)
                    surface.DrawRect(
                        self.x - self.width/2,
                        self.y - self.height/2,
                        self.width,
                        self.height
                    )
                else
                    -- Запасной вариант: цветной круг/квадрат
                    surface.SetDrawColor(self.color.r, self.color.g, self.color.b, 255)
                    
                    if self.type == "CIRCLE" then
                        for i = 0, 16 do
                            local angle1 = (i / 16) * math.pi * 2
                            local angle2 = ((i + 1) / 16) * math.pi * 2
                            
                            surface.DrawLine(
                                self.x + math.cos(angle1) * self.width/2,
                                self.y + math.sin(angle1) * self.width/2,
                                self.x + math.cos(angle2) * self.width/2,
                                self.y + math.sin(angle2) * self.width/2
                            )
                        end
                    else
                        surface.DrawRect(
                            self.x - self.width/2,
                            self.y - self.height/2,
                            self.width,
                            self.height
                        )
                        
                        -- Обводка
                        surface.SetDrawColor(0, 0, 0, 150)
                        surface.DrawOutlinedRect(
                            self.x - self.width/2,
                            self.y - self.height/2,
                            self.width,
                            self.height,
                            1
                        )
                    end
                end
            end
        }
    end
    
    -- Создаем атаку врага
    function UT_BATTLE_ATTACKS.CreateEnemyAttack(enemy, attackIndex)
        if not enemy or not enemy.attacks or not enemy.attacks[attackIndex] then
            return {}
        end
        
        local attackData = enemy.attacks[attackIndex]
        local bullets = {}
        
        -- Начальная позиция (позиция врага в сетке)
        local gridPos = UT_BATTLE_ATTACKS.GetEnemyGridPosition(enemy)
        
        -- Целевая позиция (позиция сердца игрока)
        local heartPos = {
            x = ScrW() / 2,
            y = ScrH() * 0.55 + 125  -- Центр диалоговой панели
        }
        
        -- Создаем снаряды в зависимости от типа атаки
        if attackData.type == "SNIPER" then
            for i = 1, attackData.count or 8 do
                local angle = math.random() * math.pi * 2
                local distance = math.random(100, 300)
                
                local startPos = {
                    x = gridPos.x + math.cos(angle) * distance,
                    y = gridPos.y + math.sin(angle) * distance
                }
                
                -- Добавляем небольшой разброс к цели
                local targetOffset = {
                    x = heartPos.x + math.random(-30, 30),
                    y = heartPos.y + math.random(-30, 30)
                }
                
                local bullet = UT_BATTLE_ATTACKS.CreateBullet(
                    "SNIPER",
                    startPos,
                    targetOffset,
                    attackData.speed or 200,
                    attackData.color or Color(255, 50, 50)
                )
                
                table.insert(bullets, bullet)
            end
        elseif attackData.type == "WAVE" then
            -- Волновые атаки
            local waveCount = attackData.count or 5
            
            for wave = 1, waveCount do
                for i = 1, 3 do
                    local startPos = {
                        x = gridPos.x + (i - 2) * 50,
                        y = gridPos.y - 100 - wave * 40
                    }
                    
                    local targetPos = {
                        x = heartPos.x + (i - 2) * 30,
                        y = heartPos.y
                    }
                    
                    local bullet = UT_BATTLE_ATTACKS.CreateBullet(
                        "WAVE",
                        startPos,
                        targetPos,
                        attackData.speed or 180,
                        attackData.color or Color(255, 255, 0)
                    )
                    
                    table.insert(bullets, bullet)
                end
            end
        elseif attackData.type == "CIRCLE" then
            -- Круговые атаки
            local circleCount = attackData.count or 16
            
            for i = 1, circleCount do
                local angle = (i / circleCount) * math.pi * 2
                local radius = 150
                
                local startPos = {
                    x = gridPos.x + math.cos(angle) * radius,
                    y = gridPos.y + math.sin(angle) * radius
                }
                
                local bullet = UT_BATTLE_ATTACKS.CreateBullet(
                    "CIRCLE",
                    startPos,
                    heartPos,
                    attackData.speed or 150,
                    attackData.color or Color(255, 150, 0)
                )
                
                table.insert(bullets, bullet)
            end
        end
        
        return bullets
    end
    
    -- Получаем позицию врага в сетке
    function UT_BATTLE_ATTACKS.GetEnemyGridPosition(enemy)
        if not UT_BATTLE_CORE.currentTargets then
            return {x = ScrW()/2, y = ScrH()*0.3}
        end
        
        -- Находим индекс врага
        local enemyIndex = 1
        for i, target in ipairs(UT_BATTLE_CORE.currentTargets) do
            if target == enemy then
                enemyIndex = i
                break
            end
        end
        
        -- Вычисляем позицию в сетке
        local gridW = ScrW() * 0.9
        local gridH = ScrH() * 0.4
        local gridX = ScrW()/2 - gridW/2
        local gridY = ScrH() * 0.1
        
        local cols = 6
        local rows = 2
        local cellW = gridW / cols
        local cellH = gridH / rows
        
        -- Распределение как в DrawEnemiesGrid
        local col, row
        if enemyIndex == 1 then
            col = math.floor(cols / 2)
            row = math.floor(rows / 2)
        elseif enemyIndex == 2 then
            col = math.floor(cols / 2) + 1
            row = math.floor(rows / 2)
        elseif enemyIndex == 3 then
            col = math.floor(cols / 2) - 1
            row = math.floor(rows / 2)
        elseif enemyIndex == 4 then
            col = math.floor(cols / 2)
            row = math.floor(rows / 2) + 1
        elseif enemyIndex == 5 then
            col = math.floor(cols / 2)
            row = math.floor(rows / 2) - 1
        else
            col = (enemyIndex - 1) % cols
            row = math.floor((enemyIndex - 1) / cols)
        end
        
        col = math.Clamp(col, 0, cols - 1)
        row = math.Clamp(row, 0, rows - 1)
        
        return {
            x = gridX + col * cellW + cellW/2,
            y = gridY + row * cellH + cellH/2
        }
    end
    
    print("[UNDERTALE] Система атак врагов загружена")
end