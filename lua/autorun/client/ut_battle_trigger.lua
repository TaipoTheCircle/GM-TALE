-- ФАЙЛ: ut_battle_trigger.lua (УСИЛЕННАЯ ЗАЩИТА ОТ УРОНА)
if CLIENT then
    print("[UNDERTALE] Загрузка триггера с РЕАЛЬНЫМИ врагами и УСИЛЕННОЙ НЕУЯЗВИМОСТЬЮ...")
    
    UT_BATTLE_TRIGGER = UT_BATTLE_TRIGGER or {}
    
    UT_BATTLE_TRIGGER.detectionRadius = 300
    UT_BATTLE_TRIGGER.checkInterval = 0.5
    UT_BATTLE_TRIGGER.lastCheck = 0
    UT_BATTLE_TRIGGER.battleEntities = {}
    
    UT_BATTLE_TRIGGER.playerWasInvincible = false
    
    -- ТИПЫ ВРАГОВ
    -- ТИПЫ ВРАГОВ (с кастомными атаками)
UT_BATTLE_TRIGGER.EnemyTypes = {
    ["npc_zombie"] = {
        name = "ЗОМБИ",
        hp = 25,
        maxhp = 25,
        class = "npc_zombie",
        customAttacks = {  -- НОВЫЙ ФОРМАТ!
            { type = "Projectile", count = 3, speed = 200, damage = 2, texture = "attack", color = Color(100, 255, 100) },
            { type = "Rain", count = 8, speed = 250, damage = 2, size = 18 },
            { type = "Wave", waves = 2, speed = 180, damage = 2 }
        },
        dialog = { "* Зомби медленно приближается...", "* Вы чувствуете запах гниения", "* Зомби Рычит" }
    },
        
          --["npc_kleiner"] = {
           --   name = "КЛЯЙНЕР",
           --   hp = 1,
            --  maxhp = 1,
           --   class = "npc_kleiner",
           --   isSans = true,
           --   attacks = {},
           --   dialog = { "* хех...", "* ты думал я буду просто стоять?", "* получай." }
         -- },

            ["npc_combine_s"] = {
        name = "СОЛДАТ",
        hp = 30,
        maxhp = 30,
        class = "npc_combine_s",
        customAttacks = {
            { type = "Projectile", count = 5, speed = 350, damage = 3, texture = "attack", color = Color(0, 200, 255) },
            { type = "Laser", count = 2, damage = 5, width = 12 },
            { type = "Homing", count = 2, speed = 250, damage = 3, homingStrength = 3 }
        },
        dialog = { "* Солдат Overwatch нацеливается на вас", "* Слышен звук заряжания оружия", '* Солдат Overwatch говорит: "Стоять!"' }
    },

    ["npc_combine"] = {
        name = "СОЛДАТ",
        hp = 30,
        maxhp = 30,
        class = "npc_combine",
        customAttacks = {
            { type = "Projectile", count = 5, speed = 350, damage = 3, texture = "attack", color = Color(0, 200, 255) },
            { type = "Laser", count = 2, damage = 5, width = 12 },
            { type = "Homing", count = 2, speed = 250, damage = 3, homingStrength = 3 }
        },
        dialog = { "* Солдат Overwatch нацеливается на вас", "* Слышен звук заряжания оружия", '* Солдат Overwatch говорит: "Стоять!"' }
    },
    
    ["npc_antlion"] = {
        name = "МУРАВЬИННЫЙ ЛЕВ",
        hp = 35,
        maxhp = 35,
        class = "npc_antlion",
        customAttacks = {
            { type = "Circle", count = 16, speed = 180, damage = 3, radius = 250, color = Color(255, 150, 0) },
            { type = "Arc", count = 5, speed = 220, damage = 4, arcHeight = 150 },
            { type = "Projectile", count = 4, speed = 280, damage = 3, texture = "attack" }
        },
        dialog = { "* Муравьинный Лев рычит", "* Муравьинный Лев готовится к прыжку", "* Острые когти блестят" }
    },
    
    ["npc_antlionworker"] = {
        name = "РАБОЧИЙ МУРАВЬИННЫХ ЛЬВОВ",
        hp = 20,
        maxhp = 20,
        class = "npc_antlionworker",
        customAttacks = {
            { type = "Wave", waves = 2, speed = 120, damage = 2, color = Color(150, 255, 150) },
            { type = "Projectile", count = 3, speed = 150, damage = 2 }
        },
        dialog = { "* Рабочий суетится", "* Рабочий выглядит слабее других", "* Рабочий все ещё опасен" }
    },
    
    ["npc_headcrab"] = {
        name = "ХЕДКРАБ",
        hp = 15,
        maxhp = 15,
        class = "npc_headcrab",
        customAttacks = {
            { type = "Projectile", count = 4, speed = 180, damage = 2, color = Color(255, 100, 100) },
            { type = "Homing", count = 2, speed = 200, damage = 2, homingStrength = 2 }
        },
        dialog = { "* Хедкраб прыгает!", "* Хедкраб пытается укусить", "* Хедкраб - маленький, но опасный" }
    },
    
    ["npc_fastzombie"] = {
        name = "БЫСТРЫЙ ЗОМБИ",
        hp = 40,
        maxhp = 40,
        class = "npc_fastzombie",
        customAttacks = {
            { type = "Projectile", count = 10, speed = 300, damage = 3, color = Color(255, 0, 0) },
            { type = "Rain", count = 12, speed = 280, damage = 2, size = 15 }
        },
        dialog = { "* Быстрый зомби бежит!", "* Быстрый зомби очень быстрый!", "* Будь осторожен!" }
    }
}
    
    -- ВКЛЮЧЕНИЕ НЕУЯЗВИМОСТИ
    UT_BATTLE_TRIGGER.EnableInvincibility = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        UT_BATTLE_TRIGGER.playerWasInvincible = ply:GetNWBool("ut_invincible", false)
        ply:SetNWBool("ut_invincible", true)
        print("[UNDERTALE] УСИЛЕННАЯ НЕУЯЗВИМОСТЬ ВКЛЮЧЕНА")
        chat.AddText(Color(0, 255, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
            "На время боя вы ПОЛНОСТЬЮ НЕУЯЗВИМЫ в реальном мире!")
    end
    
    -- ВЫКЛЮЧЕНИЕ НЕУЯЗВИМОСТИ
    UT_BATTLE_TRIGGER.DisableInvincibility = function()
        if not UT_BATTLE_TRIGGER.playerWasInvincible then
            local ply = LocalPlayer()
            if IsValid(ply) then ply:SetNWBool("ut_invincible", false) end
            print("[UNDERTALE] Неуязвимость ВЫКЛЮЧЕНА")
            chat.AddText(Color(255, 0, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
                "Вы снова уязвимы в реальном мире!")
        else
            print("[UNDERTALE] Неуязвимость осталась включенной (была включена до боя)")
        end
    end
    
    -- ПОИСК ВРАГОВ ВОКРУГ
    UT_BATTLE_TRIGGER.FindNearbyEnemies = function(centerPos, radius)
        local enemies = {}
        for _, ent in ipairs(ents.FindInSphere(centerPos, radius)) do
            if ent:IsNPC() and not ent.BattleTriggered then
                local enemyType = UT_BATTLE_TRIGGER.EnemyTypes[ent:GetClass()]
                if enemyType then
                    table.insert(enemies, { entity = ent, data = enemyType })
                end
            end
        end
        return enemies
    end
    
    -- ОСТАНОВКА NPC
    UT_BATTLE_TRIGGER.StopNPC = function(ent)
        if not IsValid(ent) then return end
        ent.BattleWasStopped = true
        RunConsoleCommand("ut_stop_npc", tostring(ent:EntIndex()))
    end
    
    -- ВОЗОБНОВЛЕНИЕ NPC
    UT_BATTLE_TRIGGER.ResumeNPC = function(ent)
        if not IsValid(ent) then return end
        ent.BattleWasStopped = nil
        RunConsoleCommand("ut_resume_npc", tostring(ent:EntIndex()))
    end
    
    -- ЗАПУСК БОЯ
    UT_BATTLE_TRIGGER.StartRealBattle = function(triggerEnemy)
        print("[UNDERTALE] ===== ЗАПУСК РЕАЛЬНОГО БОЯ =====")
        if not UT_BATTLE_CORE then return end
        if UT_BATTLE_CORE.battleActive then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        UT_BATTLE_TRIGGER.EnableInvincibility()
        
        local nearbyEnemies = UT_BATTLE_TRIGGER.FindNearbyEnemies(ply:GetPos(), UT_BATTLE_TRIGGER.detectionRadius)
        if #nearbyEnemies == 0 then return end
        
        print("[UNDERTALE] Найдено врагов: " .. #nearbyEnemies)
        
        UT_BATTLE_TRIGGER.battleEntities = {}
        UT_BATTLE_CORE.currentTargets = {}
        
        for i, enemyInfo in ipairs(nearbyEnemies) do
            local ent = enemyInfo.entity
            local data = enemyInfo.data
            
            -- ПРОВЕРКА НА САНСА
            if data.isSans then
                print("[UNDERTALE] Обнаружен Санс! Запуск специальной битвы!")
                if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then UT_BATTLE_MUSIC.Stop() end
                if UT_SANS_BATTLE and UT_SANS_BATTLE.Start then UT_SANS_BATTLE.Start() end
                return
            end
            
            ent.BattleTriggered = true
            ent.InRealBattle = true
            table.insert(UT_BATTLE_TRIGGER.battleEntities, ent)
            UT_BATTLE_TRIGGER.StopNPC(ent)
            
            table.insert(UT_BATTLE_CORE.currentTargets, {
                name = data.name,
                class = ent:GetClass(),
                hp = data.hp,
                maxhp = data.maxhp,
                entity = ent,
                attacks = data.attacks,
                dialog = data.dialog,
                isReal = true
            })
            print("[UNDERTALE] Добавлен враг: " .. data.name)
        end
        
        UT_BATTLE_CORE.currentEnemy = {
            entity = nearbyEnemies[1].entity,
            data = nearbyEnemies[1].data,
            currentAttack = 1
        }
        
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Start then
            UT_BATTLE_MUSIC.Start({class = "default"})
        end
        
        local enemyNames = ""
        for i, target in ipairs(UT_BATTLE_CORE.currentTargets) do
            enemyNames = enemyNames .. target.name
            if i < #UT_BATTLE_CORE.currentTargets then enemyNames = enemyNames .. ", " end
        end
        
        chat.AddText(Color(255, 50, 50), "[БОЙ НАЧАТ!] ", Color(255, 255, 255), "Вы встретили: " .. enemyNames)
        chat.AddText(Color(255, 255, 0), "[СИСТЕМА] ", Color(255, 255, 255), "В бою " .. #UT_BATTLE_CORE.currentTargets .. " врагов!")
        chat.AddText(Color(0, 255, 0), "[УСИЛЕННАЯ НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), "На время боя вы ПОЛНОСТЬЮ НЕУЯЗВИМЫ в реальном мире!")
        
        timer.Simple(1, function()
            if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                UT_BATTLE_HUD.CreateBattleMenu()
            end
        end)
    end
    
    -- ПОИСК ВРАГОВ (ТРИГГЕР)
    UT_BATTLE_TRIGGER.FindEnemies = function()
        if not UT_BATTLE_CORE or UT_BATTLE_CORE.battleActive then return end
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        for _, ent in pairs(ents.FindInSphere(ply:GetPos(), UT_BATTLE_TRIGGER.detectionRadius)) do
            if ent:IsNPC() and not ent.BattleTriggered then
                local enemyType = UT_BATTLE_TRIGGER.EnemyTypes[ent:GetClass()]
                if enemyType then
                    print("[UNDERTALE] Обнаружен враг: "..enemyType.name)
                    UT_BATTLE_TRIGGER.StartRealBattle(ent)
                    break
                end
            end
        end
    end
    
    -- УБИЙСТВО РЕАЛЬНОГО ВРАГА
    UT_BATTLE_TRIGGER.KillRealEnemy = function(enemyData)
        if not enemyData or not enemyData.entity or not IsValid(enemyData.entity) then return end
        local ent = enemyData.entity
        UT_BATTLE_TRIGGER.ResumeNPC(ent)
        RunConsoleCommand("ut_kill_npc", tostring(ent:EntIndex()))
        for i, battleEnt in ipairs(UT_BATTLE_TRIGGER.battleEntities) do
            if battleEnt == ent then
                table.remove(UT_BATTLE_TRIGGER.battleEntities, i)
                break
            end
        end
    end
    
    -- ПРОВЕРКА ОКОНЧАНИЯ БОЯ
    UT_BATTLE_TRIGGER.CheckBattleEnd = function()
        if not UT_BATTLE_CORE or not UT_BATTLE_CORE.currentTargets then return false end
        
        local allDead = true
        for _, target in ipairs(UT_BATTLE_CORE.currentTargets) do
            if target.hp > 0 then allDead = false break end
        end
        
        if allDead and #UT_BATTLE_CORE.currentTargets > 0 then
            for _, target in ipairs(UT_BATTLE_CORE.currentTargets) do
                if target.entity and IsValid(target.entity) then
                    UT_BATTLE_TRIGGER.KillRealEnemy(target)
                end
            end
            for _, ent in ipairs(UT_BATTLE_TRIGGER.battleEntities) do
                if IsValid(ent) then UT_BATTLE_TRIGGER.ResumeNPC(ent) end
            end
            UT_BATTLE_TRIGGER.battleEntities = {}
            return true
        end
        return false
    end
    
    -- СБРОС ТРИГГЕРОВ
    UT_BATTLE_TRIGGER.ResetTriggers = function()
        for _, npc in pairs(ents.FindByClass("npc_*")) do
            if npc.BattleTriggered then npc.BattleTriggered = false end
            if npc.InRealBattle then
                npc.InRealBattle = false
                UT_BATTLE_TRIGGER.ResumeNPC(npc)
            end
        end
        UT_BATTLE_TRIGGER.battleEntities = {}
    end
    
    -- ХУКИ
    hook.Add("Think", "UT_CheckRealBattleEnd", function()
        if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
            if UT_BATTLE_TRIGGER.CheckBattleEnd() then
                timer.Simple(2, function()
                    if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                        UT_BATTLE_CORE.EndBattle(true)
                        UT_BATTLE_TRIGGER.DisableInvincibility()
                    end
                end)
            end
        end
    end)
    
    hook.Add("UT_BattleEnded", "UT_DisableInvincibility", function()
        UT_BATTLE_TRIGGER.DisableInvincibility()
    end)
    
    -- ИНИЦИАЛИЗАЦИЯ
    UT_BATTLE_TRIGGER.Initialize = function()
        UT_BATTLE_TRIGGER.ResetTriggers()
        hook.Add("Think", "UT_BattleTrigger", function()
            if not UT_BATTLE_CORE then return end
            if not UT_BATTLE_TRIGGER.lastCheck then UT_BATTLE_TRIGGER.lastCheck = CurTime() end
            if CurTime() - UT_BATTLE_TRIGGER.lastCheck > UT_BATTLE_TRIGGER.checkInterval then
                UT_BATTLE_TRIGGER.FindEnemies()
                UT_BATTLE_TRIGGER.lastCheck = CurTime()
            end
        end)
        
        concommand.Add("ut_reset_triggers", function()
            UT_BATTLE_TRIGGER.ResetTriggers()
            chat.AddText(Color(0, 255, 0), "[ТРИГГЕРЫ] ", Color(255, 255, 255), "Все триггеры врагов сброшены!")
        end)
        
        concommand.Add("ut_test_real_battle", function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return end
            local enemies = UT_BATTLE_TRIGGER.FindNearbyEnemies(ply:GetPos(), 500)
            if #enemies > 0 then
                UT_BATTLE_TRIGGER.StartRealBattle(enemies[1].entity)
            else
                chat.AddText(Color(255, 0, 0), "[ТЕСТ] ", Color(255, 255, 255), "Рядом нет врагов!")
            end
        end)
    end
    
    timer.Simple(5, function()
        UT_BATTLE_TRIGGER.Initialize()
        print("[UNDERTALE] Реальный триггер боя с усиленной неуязвимостью готов к работе")
        chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), "РЕАЛЬНЫЙ бой активирован. Подойдите к врагам!")
        chat.AddText(Color(0, 255, 0), "[УСИЛЕННАЯ НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), "На время боя вы ПОЛНОСТЬЮ НЕУЯЗВИМЫ в реальном мире!")
    end)
    
    print("[UNDERTALE] Реальный триггер боя с усиленной неуязвимостью загружен")
end

-- СЕРВЕРНАЯ ЧАСТЬ
if SERVER then
    print("[UNDERTALE] Загрузка серверной части триггера...")
    
    util.AddNetworkString("ut_invincible_status")
    
    concommand.Add("ut_stop_npc", function(ply, cmd, args)
        if not args[1] then return end
        local ent = Entity(tonumber(args[1]))
        if IsValid(ent) and ent:IsNPC() then
            ent:SetSchedule(SCHED_IDLE_STAND)
            ent:SetEnemy(NULL)
        end
    end)
    
    concommand.Add("ut_resume_npc", function(ply, cmd, args)
        if not args[1] then return end
        local ent = Entity(tonumber(args[1]))
        if IsValid(ent) and ent:IsNPC() then
            ent:SetSchedule(SCHED_IDLE_WANDER)
        end
    end)
    
    concommand.Add("ut_kill_npc", function(ply, cmd, args)
        if not args[1] then return end
        local ent = Entity(tonumber(args[1]))
        if IsValid(ent) and ent:IsNPC() then
            ent:TakeDamage(ent:Health() + 100, ply, ply)
            ent:Remove()
        end
    end)
    
    concommand.Add("ut_invincible", function(ply, cmd, args)
        if not IsValid(ply) or not args[1] then return end
        local enable = tonumber(args[1]) == 1
        if enable then
            ply:SetNWBool("ut_invincible", true)
            ply:GodEnable()
        else
            ply:SetNWBool("ut_invincible", false)
            ply:GodDisable()
        end
        net.Start("ut_invincible_status")
        net.WriteEntity(ply)
        net.WriteBool(enable)
        net.Broadcast()
    end)
    
    print("[UNDERTALE] Серверная часть триггера загружена")
end

-- КЛИЕНТСКАЯ ЧАСТЬ ДЛЯ СТАТУСА
if CLIENT then
    net.Receive("ut_invincible_status", function()
        local ply = net.ReadEntity()
        local enabled = net.ReadBool()
        if ply == LocalPlayer() then
            if enabled then
                chat.AddText(Color(0, 255, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), "Статус: ВКЛЮЧЕНО")
            else
                chat.AddText(Color(255, 0, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), "Статус: ВЫКЛЮЧЕНО")
            end
        end
    end)
end