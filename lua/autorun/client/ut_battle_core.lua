-- ФАЙЛ: ut_battle_core.lua (ПОЛНЫЙ С УПРАВЛЕНИЕМ ВРАГАМИ)
if CLIENT then
    print("[UNDERTALE] Загрузка оптимизированного ядра с управлением врагами...")
    
    -- Создаем UT_HEART_SYSTEM сразу, если его нет
    if not UT_HEART_SYSTEM then
        UT_HEART_SYSTEM = {}
        print("[UNDERTALE] Создан UT_HEART_SYSTEM для совместимости")
    end
    
    -- Если UT_HEART_CORE еще не существует, создаем его с правильной структурой
    if not UT_HEART_CORE then
        UT_HEART_CORE = {
            is_active = false,
            player = {
                is_alive = true,
                hp = 20,
                max_hp = 20
            },
            heart = {
                x = 0,
                y = 0,
                size = 15,
                speed = 300,
                color = Color(255, 0, 0)
            },
            bullets = {},
            panel_bounds = {left = 0, right = 0, top = 0, bottom = 0},
            current_message = nil,
            blink_timer = 0
        }
        print("[UNDERTALE] Создан UT_HEART_CORE с правильной структурой")
    end
    
    -- Модуль ядра боевой системы (основной)
    UT_BATTLE_CORE = UT_BATTLE_CORE or {}
    
    -- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
    UT_BATTLE_CORE.battleActive = false
    UT_BATTLE_CORE.battleFrame = nil
    UT_BATTLE_CORE.selectedButton = 1
    UT_BATTLE_CORE.selectedTarget = 1
    UT_BATTLE_CORE.battleMode = "MENU"
    UT_BATTLE_CORE.keyCooldown = 0
    UT_BATTLE_CORE.lastKeyPress = 0
    UT_BATTLE_CORE.keyRepeatDelay = 0.4
    UT_BATTLE_CORE.attackActive = false
    UT_BATTLE_CORE.attackInProgress = false
    UT_BATTLE_CORE.attackTimer = 0
    UT_BATTLE_CORE.attackBarPos = 0
    UT_BATTLE_CORE.attackBarSpeed = 400
    UT_BATTLE_CORE.attackBarWidth = 30
    UT_BATTLE_CORE.attackDamage = 0
    UT_BATTLE_CORE.attackHitZone = {start = 0, finish = 0}
    UT_BATTLE_CORE.attackMaxDamage = 15
    UT_BATTLE_CORE.attackResult = nil
    UT_BATTLE_CORE.attackBlinkTimer = 0
    UT_BATTLE_CORE.attackSpacePressed = false
    UT_BATTLE_CORE.playerHp = 20
    UT_BATTLE_CORE.playerMaxHp = 20
    UT_BATTLE_CORE.buttons = {
        { name = "FIGHT", normal = "undertale/attack.png", selected = "undertale/attack_use.png" },
        { name = "ACT", normal = "undertale/act.png", selected = "undertale/act_use.png" },
        { name = "ITEM", normal = "undertale/item.png", selected = "undertale/item_use.png" },
        { name = "MERCY", normal = "undertale/mercy.png", selected = "undertale/mercy_use.png" }
    }
    UT_BATTLE_CORE.currentTargets = {}
    UT_BATTLE_CORE.btnImages = {}
    UT_BATTLE_CORE.dialogPanel = nil
    UT_BATTLE_CORE.btnPanel = nil
    UT_BATTLE_CORE.infoPanel = nil
    UT_BATTLE_CORE.currentEnemy = nil
    UT_BATTLE_CORE.lastCleanup = 0
    
    -- УДАЛЕНИЕ МЕРТВЫХ ВРАГОВ
    function UT_BATTLE_CORE.RemoveDeadEnemies()
        if not UT_BATTLE_CORE.currentTargets then 
            print("[UNDERTALE] Нет врагов для очистки")
            return 0 
        end
        
        local removedCount = 0
        
        for i = #UT_BATTLE_CORE.currentTargets, 1, -1 do
            local enemy = UT_BATTLE_CORE.currentTargets[i]
            
            -- Удаляем врагов, которые мертвы дольше 3 секунд
            if enemy.hp <= 0 and (enemy.deathTimer or 0) > 3 then
                table.remove(UT_BATTLE_CORE.currentTargets, i)
                removedCount = removedCount + 1
                print("[UNDERTALE] Враг удален из боя: " .. (enemy.name or "Unknown"))
                
                -- Если это был реальный entity, помечаем его
                if enemy.entity and IsValid(enemy.entity) then
                    enemy.entity.BattleTriggered = false
                end
            end
        end
        
        -- Обновляем selectedTarget если нужно
        if removedCount > 0 then
            if UT_BATTLE_CORE.selectedTarget > #UT_BATTLE_CORE.currentTargets then
                UT_BATTLE_CORE.selectedTarget = math.max(1, #UT_BATTLE_CORE.currentTargets)
                print("[UNDERTALE] Обновлен selectedTarget: " .. UT_BATTLE_CORE.selectedTarget)
            end
            
            -- Если все враги мертвы - победа
            if #UT_BATTLE_CORE.currentTargets == 0 then
                print("[UNDERTALE] Все враги побеждены!")
                chat.AddText(Color(0, 255, 0), "[ПОБЕДА!] ", Color(255, 255, 255), 
                    "Вы победили всех врагов!")
                
                timer.Simple(3, function()
                    if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                        UT_BATTLE_CORE.EndBattle(true)
                    end
                end)
            end
        end
        
        return removedCount
    end
    
    -- ПРОВЕРКА ПОБЕДЫ
    function UT_BATTLE_CORE.CheckForVictory()
        if not UT_BATTLE_CORE.currentTargets or #UT_BATTLE_CORE.currentTargets == 0 then
            return true
        end
        
        -- Проверяем, есть ли живые враги
        for _, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
            if enemy.hp > 0 then
                return false
            end
        end
        
        return true
    end
    
    -- ПОЛУЧЕНИЕ СЛЕДУЮЩЕГО ЖИВОГО ВРАГА
    function UT_BATTLE_CORE.GetNextLivingEnemy(startIndex)
        if not UT_BATTLE_CORE.currentTargets then return nil end
        
        local start = startIndex or 1
        local count = #UT_BATTLE_CORE.currentTargets
        
        -- Ищем вперед
        for i = start, count do
            if UT_BATTLE_CORE.currentTargets[i].hp > 0 then
                return i
            end
        end
        
        -- Ищем с начала
        for i = 1, start - 1 do
            if UT_BATTLE_CORE.currentTargets[i].hp > 0 then
                return i
            end
        end
        
        return nil -- Все враги мертвы
    end
    
    -- ОБНОВЛЕНИЕ ПОЗИЦИЙ ВРАГОВ
    function UT_BATTLE_CORE.UpdateEnemiesGrid()
        if not UT_BATTLE_CORE.currentTargets then return end
        
        -- Обновляем таймеры смерти
        for _, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
            if enemy.hp <= 0 and enemy.deathTimer then
                enemy.deathTimer = enemy.deathTimer + FrameTime()
            end
        end
        
        -- Автоматически удаляем мертвых врагов
        if CurTime() - UT_BATTLE_CORE.lastCleanup > 1 then
            local removed = UT_BATTLE_CORE.RemoveDeadEnemies()
            if removed > 0 then
                print("[UNDERTALE] Автоочистка: удалено " .. removed .. " врагов")
            end
            UT_BATTLE_CORE.lastCleanup = CurTime()
        end
    end
    
    -- ИНИЦИАЛИЗАЦИЯ ГРАНИЦ
    function UT_HEART_CORE.InitializeBounds()
        -- Размеры как у диалоговой панели в ut_battle_hud.lua
        local dialogW = 900
        local dialogH = 250
        local panelX = ScrW()/2 - dialogW/2
        local panelY = ScrH() * 0.55
        
        -- Устанавливаем границы (с небольшим отступом)
        UT_HEART_CORE.panel_bounds = {
            left = panelX + 20,
            right = panelX + dialogW - 20,
            top = panelY + 20,
            bottom = panelY + dialogH - 40
        }
        
        -- Начальная позиция сердца в центре панели
        UT_HEART_CORE.heart.x = (UT_HEART_CORE.panel_bounds.left + UT_HEART_CORE.panel_bounds.right) / 2
        UT_HEART_CORE.heart.y = (UT_HEART_CORE.panel_bounds.top + UT_HEART_CORE.panel_bounds.bottom) / 2
        
        print("[UNDERTALE] Границы сердца установлены")
    end
    
    -- СОЗДАНИЕ СНАРЯДОВ
    function UT_HEART_CORE.CreateBullets()
        local bounds = UT_HEART_CORE.panel_bounds
        local width = bounds.right - bounds.left
        local height = bounds.bottom - bounds.top
        
        -- Снаряды летят сверху вниз
        for i = 1, 6 do
            table.insert(UT_HEART_CORE.bullets, {
                x = math.random(bounds.left + 30, bounds.right - 30),
                y = bounds.top - 20,
                speed = math.random(150, 220),
                width = 10,
                height = 10,
                color = Color(255, 255, 255)
            })
        end
        
        -- Иногда снаряды летят сбоку
        if math.random() > 0.5 then
            for i = 1, 4 do
                local start_side = math.random(1, 2)
                if start_side == 1 then -- Слева
                    table.insert(UT_HEART_CORE.bullets, {
                        x = bounds.left - 20,
                        y = math.random(bounds.top + 30, bounds.bottom - 30),
                        speed = math.random(120, 180),
                        width = 10,
                        height = 10,
                        color = Color(200, 200, 255),
                        vx = 1,
                        vy = 0
                    })
                else -- Справа
                    table.insert(UT_HEART_CORE.bullets, {
                        x = bounds.right + 20,
                        y = math.random(bounds.top + 30, bounds.bottom - 30),
                        speed = math.random(120, 180),
                        width = 10,
                        height = 10,
                        color = Color(200, 200, 255),
                        vx = -1,
                        vy = 0
                    })
                end
            end
        end
    end
    
    -- ОБНОВЛЕНИЕ СЕРДЦА
    function UT_HEART_CORE.UpdateHeart()
        if not UT_HEART_CORE.is_active then return end
        if not UT_HEART_CORE.player.is_alive then return end
        
        local frame_time = FrameTime()
        local move_x, move_y = 0, 0
        
        -- Управление
        if input.IsKeyDown(KEY_LEFT) then
            move_x = -1
        end
        if input.IsKeyDown(KEY_RIGHT) then
            move_x = 1
        end
        if input.IsKeyDown(KEY_UP) then
            move_y = -1
        end
        if input.IsKeyDown(KEY_DOWN) then
            move_y = 1
        end
        
        -- Обновление позиции
        UT_HEART_CORE.heart.x = UT_HEART_CORE.heart.x + (move_x * UT_HEART_CORE.heart.speed * frame_time)
        UT_HEART_CORE.heart.y = UT_HEART_CORE.heart.y + (move_y * UT_HEART_CORE.heart.speed * frame_time)
        
        -- Границы панели
        local bounds = UT_HEART_CORE.panel_bounds
        UT_HEART_CORE.heart.x = math.Clamp(UT_HEART_CORE.heart.x, 
            bounds.left + UT_HEART_CORE.heart.size, 
            bounds.right - UT_HEART_CORE.heart.size)
        UT_HEART_CORE.heart.y = math.Clamp(UT_HEART_CORE.heart.y, 
            bounds.top + UT_HEART_CORE.heart.size, 
            bounds.bottom - UT_HEART_CORE.heart.size)
    end
    
    -- ОБНОВЛЕНИЕ СНАРЯДОВ
    function UT_HEART_CORE.UpdateBullets()
        if not UT_HEART_CORE.is_active then return end
        
        local frame_time = FrameTime()
        local bounds = UT_HEART_CORE.panel_bounds
        
        for i = #UT_HEART_CORE.bullets, 1, -1 do
            local bullet = UT_HEART_CORE.bullets[i]
            
            if not bullet then
                table.remove(UT_HEART_CORE.bullets, i)
                continue
            end
            
            -- Движение снаряда
            if bullet.vx then
                bullet.x = bullet.x + (bullet.vx * bullet.speed * frame_time)
            else
                bullet.y = bullet.y + (bullet.speed * frame_time)
            end
            
            -- Проверка столкновения с сердцем
            if UT_HEART_CORE.player.is_alive then
                local dx = bullet.x - UT_HEART_CORE.heart.x
                local dy = bullet.y - UT_HEART_CORE.heart.y
                local distance = math.sqrt(dx * dx + dy * dy)
                local collision_distance = (bullet.width/2) + (UT_HEART_CORE.heart.size * 0.8)
                
                if distance < collision_distance then
                    UT_HEART_CORE.OnHeartHit()
                    table.remove(UT_HEART_CORE.bullets, i)
                    continue
                end
            end
            
            -- Удаление снарядов за пределами панели
            local margin = 50
            if bullet.y > bounds.bottom + margin or 
               bullet.y < bounds.top - margin or
               bullet.x > bounds.right + margin or 
               bullet.x < bounds.left - margin then
                table.remove(UT_HEART_CORE.bullets, i)
            end
        end
    end
    
    -- ОБРАБОТКА ПОПАДАНИЯ
function UT_HEART_CORE.OnHeartHit()
    if not UT_HEART_CORE.player.is_alive then return end
    
    UT_HEART_CORE.player.hp = math.max(0, UT_HEART_CORE.player.hp - 2)
    
    -- 🚀 НОВЫЙ ЗВУК УРОНА
    if UT_SOUNDS and UT_SOUNDS.PlayDamageTaken then
        UT_SOUNDS.PlayDamageTaken()
    else
        surface.PlaySound("buttons/button15.wav")
    end
    
    -- 🚀 АКТИВИРУЕМ МИГАНИЕ
    UT_HEART_CORE.blink_timer = CurTime()
    
    -- Вибрация сердца при уроне
    local shakeAmount = 5
    UT_HEART_CORE.heart.x = math.Clamp(
        UT_HEART_CORE.heart.x + (math.random() - 0.5) * shakeAmount,
        UT_HEART_CORE.panel_bounds.left + UT_HEART_CORE.heart.size,
        UT_HEART_CORE.panel_bounds.right - UT_HEART_CORE.heart.size
    )
    UT_HEART_CORE.heart.y = math.Clamp(
        UT_HEART_CORE.heart.y + (math.random() - 0.5) * shakeAmount,
        UT_HEART_CORE.panel_bounds.top + UT_HEART_CORE.heart.size,
        UT_HEART_CORE.panel_bounds.bottom - UT_HEART_CORE.heart.size
    )
    
    if UT_BATTLE_CORE then
        UT_BATTLE_CORE.playerHp = UT_HEART_CORE.player.hp
    end
    
    if UT_BATTLE_HUD and UT_BATTLE_HUD.AddHeartMessage then
        UT_BATTLE_HUD.AddHeartMessage("* Вы получили урон! HP: "..UT_HEART_CORE.player.hp.."/20")
    end
    
    if UT_HEART_CORE.player.hp <= 0 then
        UT_HEART_CORE.player.is_alive = false
        
        if UT_BATTLE_HUD and UT_BATTLE_HUD.AddHeartMessage then
            UT_BATTLE_HUD.AddHeartMessage("* Вы были побеждены...")
        end
        
        timer.Simple(3, function()
            UT_HEART_CORE.StopHeartPhase()
            if UT_BATTLE_CORE then
                UT_BATTLE_CORE.EndBattle(false)
            end
        end)
    end
end
    
    -- ОТРИСОВКА
    function UT_HEART_CORE.Draw()
        if not UT_HEART_CORE.is_active then return end
        
        local bounds = UT_HEART_CORE.panel_bounds
        
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(bounds.left, bounds.top, 
                        bounds.right - bounds.left, 
                        bounds.bottom - bounds.top)
        
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(bounds.left, bounds.top, 
                               bounds.right - bounds.left, 
                               bounds.bottom - bounds.top, 2)
        
        for _, bullet in ipairs(UT_HEART_CORE.bullets) do
            if bullet then
                surface.SetDrawColor(bullet.color.r, bullet.color.g, bullet.color.b, 255)
                surface.DrawRect(
                    bullet.x - bullet.width/2,
                    bullet.y - bullet.height/2,
                    bullet.width,
                    bullet.height
                )
                
                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawOutlinedRect(
                    bullet.x - bullet.width/2,
                    bullet.y - bullet.height/2,
                    bullet.width,
                    bullet.height,
                    1
                )
            end
        end
        
if UT_HEART_CORE.player.is_alive then
    local heart_color = UT_HEART_CORE.heart.color
    
    -- Мигание при получении урона
    if UT_HEART_CORE.blink_timer and CurTime() - UT_HEART_CORE.blink_timer < 0.5 then
        local blink = math.sin(CurTime() * 20) > 0
        if blink then
            heart_color = Color(0, 0, 0, 100)  -- Белый при мигании
        else
            heart_color = Color(255, 100, 100, 255)  -- Светло-красный
        end
    end
    
    surface.SetDrawColor(heart_color.r, heart_color.g, heart_color.b, 255)
    draw.NoTexture()
            
            local points = {
                {x = UT_HEART_CORE.heart.x, y = UT_HEART_CORE.heart.y - UT_HEART_CORE.heart.size},
                {x = UT_HEART_CORE.heart.x + UT_HEART_CORE.heart.size, y = UT_HEART_CORE.heart.y},
                {x = UT_HEART_CORE.heart.x, y = UT_HEART_CORE.heart.y + UT_HEART_CORE.heart.size},
                {x = UT_HEART_CORE.heart.x - UT_HEART_CORE.heart.size, y = UT_HEART_CORE.heart.y}
            }
            
            surface.DrawPoly(points)
            
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawOutlinedRect(
                UT_HEART_CORE.heart.x - UT_HEART_CORE.heart.size,
                UT_HEART_CORE.heart.y - UT_HEART_CORE.heart.size,
                UT_HEART_CORE.heart.size * 2,
                UT_HEART_CORE.heart.size * 2,
                1
            )
        end
        
        if UT_HEART_CORE.current_message then
            draw.SimpleText(UT_HEART_CORE.current_message, "DermaDefault", 
                bounds.left + 10, bounds.top + 10, 
                Color(255, 255, 255))
        end
    end
    
    -- ГЛАВНЫЕ ФУНКЦИИ
    function UT_HEART_CORE.StartHeartPhase(enemy_data)
        print("[UNDERTALE] Запуск фазы сердца внутри панели!")
        
        UT_HEART_CORE.StopHeartPhase()
        
        if not UT_HEART_CORE.player then
            UT_HEART_CORE.player = {
                is_alive = true,
                hp = 20,
                max_hp = 20
            }
        end
        
        if not UT_HEART_CORE.heart then
            UT_HEART_CORE.heart = {
                x = 0,
                y = 0,
                size = 15,
                speed = 300,
                color = Color(255, 0, 0)
            }
        end
        
        UT_HEART_CORE.is_active = true
        UT_HEART_CORE.player.is_alive = true
        UT_HEART_CORE.player.hp = 20
        UT_HEART_CORE.bullets = {}
        UT_HEART_CORE.blink_timer = 0
        
        UT_HEART_CORE.InitializeBounds()
        
        timer.Simple(1, function()
            if UT_HEART_CORE.is_active then
                UT_HEART_CORE.CreateBullets()
            end
        end)
        
        hook.Add("Think", "UT_HeartPhaseThink", function()
            if UT_HEART_CORE.is_active then
                UT_HEART_CORE.UpdateHeart()
                UT_HEART_CORE.UpdateBullets()
            end
        end)
        
        hook.Add("HUDPaint", "UT_HeartPhaseDraw", function()
            if UT_HEART_CORE.is_active then
                UT_HEART_CORE.Draw()
            end
        end)
        
        timer.Create("UT_HeartBulletTimer", 2.5, 0, function()
            if UT_HEART_CORE.is_active and UT_HEART_CORE.player.is_alive then
                UT_HEART_CORE.CreateBullets()
            else
                timer.Remove("UT_HeartBulletTimer")
            end
        end)
        
        if enemy_data and enemy_data.dialog then
            local random_dialog = enemy_data.dialog[math.random(#enemy_data.dialog)]
            if UT_BATTLE_HUD and UT_BATTLE_HUD.AddHeartMessage then
                UT_BATTLE_HUD.AddHeartMessage(random_dialog)
            end
        end
        
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            UT_BATTLE_CORE.dialogPanel.Paint = function(self, w, h)
                draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                if UT_BATTLE_HUD and UT_BATTLE_HUD.currentMessage then
                    draw.SimpleText(UT_BATTLE_HUD.currentMessage, "UT_Menu", 50, 30, Color(255, 255, 255))
                else
                    draw.SimpleText("* Враг атакует! Уклоняйтесь!", "UT_Menu", 50, 30, Color(255, 255, 255))
                end
                
                draw.SimpleText("ВАШЕ HP: "..UT_HEART_CORE.player.hp.."/20", "UT_Menu", 
                    w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                    
                draw.SimpleText("Используйте стрелки для уклонения", "UT_Small", 
                    w/2, h - 60, Color(200, 200, 255), TEXT_ALIGN_CENTER)
            end
        end
        
        print("[UNDERTALE] Фаза сердца запущена в панели!")
        return true
    end
    
    function UT_BATTLE_CORE.EndBattle(player_won)
        print("[UNDERTALE] Завершение боя, победа игрока: "..tostring(player_won))
        
        if UT_HEART_SIMPLE then UT_HEART_SIMPLE.Stop() end
        if UT_HEART_CORE and UT_HEART_CORE.StopHeartPhase then UT_HEART_CORE.StopHeartPhase() end
        
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then UT_BATTLE_MUSIC.Stop() end
        
        timer.Remove("UT_CheckDeadEnemies")
        
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            UT_BATTLE_CORE.dialogPanel:SetSize(900, 250)
            UT_BATTLE_CORE.dialogPanel:SetPos(ScrW()/2 - 450, ScrH() * 0.55)
        end
        
        timer.Simple(3, function()
            UT_BATTLE_CORE.StopAllSystems()
            
            if player_won then
                chat.AddText(Color(0, 255, 0), "[ПОБЕДА] ", Color(255, 255, 255), 
                    "Вы победили всех врагов! Бой окончен.")
            else
                chat.AddText(Color(255, 0, 0), "[ПОРАЖЕНИЕ] ", Color(255, 255, 255), 
                    "Вы были побеждены...")
            end
        end)
    end
    
    function UT_BATTLE_CORE.StopAllSystems()
        print("[UNDERTALE] Полная остановка всех систем боя")
        
        if IsValid(UT_BATTLE_CORE.battleFrame) then
            UT_BATTLE_CORE.battleFrame:Remove()
            UT_BATTLE_CORE.battleFrame = nil
        end
        
        UT_BATTLE_CORE.battleActive = false
        UT_BATTLE_CORE.battleMode = "MENU"
        
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
            UT_BATTLE_MUSIC.Stop()
        end
        
        if UT_HEART_CORE and UT_HEART_CORE.StopHeartPhase then
            UT_HEART_CORE.StopHeartPhase()
        end
        
        if UT_HEART_SIMPLE then
            UT_HEART_SIMPLE.Stop()
        end
        
        UT_BATTLE_CORE.currentTargets = {}
        UT_BATTLE_CORE.currentEnemy = nil
        
        timer.Remove("UT_CheckDeadEnemies")
        timer.Remove("UT_HeartBulletTimer")
        timer.Remove("UT_SimpleHeart_Bullets")
        
        hook.Remove("Think", "UT_AttackThink")
        hook.Remove("Think", "UT_HeartPhaseThink")
        hook.Remove("Think", "UT_SimpleHeart_Think")
        hook.Remove("HUDPaint", "UT_HeartPhaseDraw")
        hook.Remove("Think", "UT_UpdateEnemiesGrid")
        
        if UT_BATTLE_CORE.PlaySoundSafe then
            UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
        end
        
        chat.AddText(Color(255, 0, 0), "[UNDERTALE] ", Color(255, 255, 255), "Бой окончен!")
        
        print("[UNDERTALE] Все системы боя остановлены")
    end
    
    function UT_HEART_CORE.StopHeartPhase()
        print("[UNDERTALE] Остановка фазы сердца")
        
        UT_HEART_CORE.is_active = false
        
        timer.Remove("UT_HeartBulletTimer")
        
        hook.Remove("Think", "UT_HeartPhaseThink")
        hook.Remove("HUDPaint", "UT_HeartPhaseDraw")
        
        UT_HEART_CORE.bullets = {}
    end
    
    -- СОВМЕСТИМЫЕ ФУНКЦИИ
    if not UT_HEART_SYSTEM then
        UT_HEART_SYSTEM = {}
    end
    
    UT_HEART_SYSTEM.StartHeartMode = function()
        print("[UNDERTALE] UT_HEART_SYSTEM.StartHeartMode() - перенаправление")
        return UT_HEART_CORE.StartHeartPhase()
    end
    
    UT_HEART_SYSTEM.StopHeartMode = function()
        print("[UNDERTALE] UT_HEART_SYSTEM.StopHeartMode()")
        UT_HEART_CORE.StopHeartPhase()
    end
    
    UT_HEART_SYSTEM.AddHeartMessage = function(message)
        UT_HEART_CORE.current_message = message
    end
    
    UT_HEART_CORE.StartHeartMode = UT_HEART_CORE.StartHeartPhase
    UT_HEART_CORE.StopHeartMode = UT_HEART_CORE.StopHeartPhase
    
    -- ДОБАВЛЯЕМ ХУК ДЛЯ ОБНОВЛЕНИЯ СЕТКИ
    hook.Add("Think", "UT_UpdateEnemiesGrid", function()
        if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
            UT_BATTLE_CORE.UpdateEnemiesGrid()
        end
    end)
    
    -- БАЗОВЫЕ ФУНКЦИИ
    UT_BATTLE_CORE.PlaySoundSafe = UT_BATTLE_CORE.PlaySoundSafe or function(soundName)
        if file.Exists("sound/"..soundName, "GAME") then
            surface.PlaySound(soundName)
            return true
        else
            surface.PlaySound("buttons/button14.wav")
            return false
        end
    end
    
    UT_BATTLE_CORE.UpdateButtonImages = UT_BATTLE_CORE.UpdateButtonImages or function()
        if not UT_BATTLE_CORE.btnImages then return end
        for i, btnData in pairs(UT_BATTLE_CORE.btnImages) do
            if IsValid(btnData.image) then
                local useSelected = (UT_BATTLE_CORE.battleMode == "MENU" and UT_BATTLE_CORE.selectedButton == i)
                local imagePath = useSelected and btnData.data.selected or btnData.data.normal
                
                if file.Exists("materials/"..imagePath, "GAME") then
                    btnData.image:SetImage(imagePath)
                end
            end
        end
    end
    
    -- КОМАНДА ДЛЯ ТЕСТА
    concommand.Add("ut_test_panel_heart", function()
        print("[UNDERTALE] Тест фазы сердца в панели")
        
        if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
            UT_BATTLE_HUD.CreateBattleMenu()
        end
        
        timer.Simple(1, function()
            if UT_HEART_CORE and UT_HEART_CORE.StartHeartPhase then
                local test_enemy = {
                    name = "ТЕСТ",
                    dialog = {
                        "* Атака начинается!",
                        "* Попробуй увернуться!",
                        "* Смотри внимательно!"
                    }
                }
                
                UT_HEART_CORE.StartHeartPhase(test_enemy)
                chat.AddText(Color(0, 255, 0), "[ТЕСТ] ", Color(255, 255, 255), 
                    "Фаза сердца запущена в диалоговой панели!")
            end
        end)
    end)
    
    print("[UNDERTALE] Оптимизированное ядро с управлением врагами загружено")
end