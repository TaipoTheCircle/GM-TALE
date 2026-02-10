-- ФАЙЛ: ut_battle_trigger.lua (ПОЛНЫЙ)
if CLIENT then
    print("[UNDERTALE] Загрузка улучшенного триггера боя...")
    
    UT_BATTLE_TRIGGER = UT_BATTLE_TRIGGER or {}
    
    UT_BATTLE_TRIGGER.detectionRadius = 300
    UT_BATTLE_TRIGGER.checkInterval = 0.5
    UT_BATTLE_TRIGGER.enemies = {}
    UT_BATTLE_TRIGGER.lastCheck = 0
    
    -- ТИПЫ ВРАГОВ С ПРИМЕРАМИ ДЛЯ СЕТКИ
    UT_BATTLE_TRIGGER.EnemyTypes = {
        ["npc_zombie"] = {
            name = "ЗОМБИ",
            hp = 25,
            maxhp = 25,
            class = "npc_zombie",
            width = 300,    -- ← МАЛЕНЬКИЙ
            height = 250,   -- ← МАЛЕНЬКИЙ
            attacks = {
                {
                    type = "SNIPER",
                    speed = 200,
                    count = 8,
                    pattern = "RANDOM",
                    color = Color(255, 50, 50)
                }
            },
            dialog = {
                "* Зомби медленно приближается...",
                "* Вы чувствуете запах гниения",
                "* Его глаза светятся красным"
            }
        },
        
        ["npc_combine_s"] = {
            name = "СОЛДАТ",
            hp = 30,
            maxhp = 30,
            class = "npc_combine_s",
            width = 300,    -- ← МАЛЕНЬКИЙ
            height = 250,   -- ← МАЛЕНЬКИЙ
            attacks = {
                {
                    type = "SNIPER",
                    speed = 250,
                    count = 12,
                    pattern = "SPIRAL",
                    color = Color(0, 255, 255)
                },
                {
                    type = "WAVE",
                    speed = 180,
                    count = 5,
                    pattern = "SINE",
                    color = Color(255, 255, 0)
                }
            },
            dialog = {
                "* Солдат нацеливается на вас",
                "* Слышен звук заряжания оружия",
                '* Он говорит: "Стоять!"'
            }
        },
        
        ["npc_antlion_s"] = {
            name = "АНТЛИОН",
            hp = 35,
            maxhp = 35,
            class = "npc_antlion_s",
            width = 300,    -- ← МАЛЕНЬКИЙ
            height = 250,   -- ← МАЛЕНЬКИЙ
            attacks = {
                {
                    type = "CIRCLE",
                    speed = 150,
                    count = 16,
                    pattern = "CIRCLE",
                    color = Color(255, 150, 0)
                }
            },
            dialog = {
                "* Антlion рычит",
                "* Он готовится к прыжку",
                "* Острые когти блестят"
            }
        },
        
        ["npc_antlionworker"] = {
            name = "РАБОЧИЙ",
            hp = 20,
            maxhp = 20,
            class = "npc_antlionworker",
            width = 300,    -- ← МАЛЕНЬКИЙ
            height = 250,   -- ← МАЛЕНЬКИЙ
            attacks = {
                {
                    type = "WAVE",
                    speed = 120,
                    count = 6,
                    pattern = "SINE",
                    color = Color(150, 255, 150)
                }
            },
            dialog = {
                "* Рабочий суетится",
                "* Он выглядит слабее других",
                "* Но все еще опасен"
            }
        },
        
        ["npc_headcrab"] = {
            name = "ХЕДКРАБ",
            hp = 15,
            maxhp = 15,
            class = "npc_headcrab",
            width = 300,    -- ← МАЛЕНЬКИЙ
            height = 250,   -- ← МАЛЕНЬКИЙ
            attacks = {
                {
                    type = "SNIPER",
                    speed = 180,
                    count = 4,
                    pattern = "RANDOM",
                    color = Color(255, 100, 100)
                }
            },
            dialog = {
                "* Хедкраб прыгает!",
                "* Он пытается укусить",
                "* Маленький, но опасный"
            }
        },
        
        ["npc_fastzombie"] = {
            name = "БЫСТРЫЙ ЗОМБИ",
            hp = 40,
            maxhp = 40,
            class = "npc_fastzombie",
            attacks = {
                {
                    type = "SNIPER",
                    speed = 300,
                    count = 10,
                    pattern = "SPIRAL",
                    color = Color(255, 0, 0)
                }
            },
            dialog = {
                "* Быстрый зомби бежит!",
                "* Он очень быстрый!",
                "* Будьте осторожны!"
            }
        }
    }
    
    -- ПОИСК ВРАГОВ
    UT_BATTLE_TRIGGER.FindEnemies = function()
        if not UT_BATTLE_CORE then 
            print("[UNDERTALE] Триггер: Ядро еще не загружено")
            return 
        end
        
        if UT_BATTLE_CORE.battleActive == true then
            print("[UNDERTALE] Триггер: Бой уже активен, пропускаем...")
            return 
        end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local enemies = ents.FindInSphere(ply:GetPos(), UT_BATTLE_TRIGGER.detectionRadius)
        
        for _, ent in pairs(enemies) do
            if ent:IsNPC() and not ent.BattleTriggered then
                local enemyType = UT_BATTLE_TRIGGER.EnemyTypes[ent:GetClass()]
                
                if enemyType then
                    print("[UNDERTALE] Обнаружен враг: "..enemyType.name)
                    
                    ent.BattleTriggered = true
                    
                    timer.Simple(1, function()
                        if IsValid(ent) and IsValid(ply) then
                            local distance = ply:GetPos():Distance(ent:GetPos())
                            if distance <= UT_BATTLE_TRIGGER.detectionRadius then
                                UT_BATTLE_TRIGGER.StartBattle(ent, enemyType)
                            end
                        end
                    end)
                    
                    break
                end
            end
        end
    end
    
    -- ЗАПУСК БОЯ С НЕСКОЛЬКИМИ ВРАГАМИ
    UT_BATTLE_TRIGGER.StartBattle = function(enemyEntity, enemyData)
        print("[UNDERTALE] Триггер: Запуск боя с несколькими врагами")
        
        if not UT_BATTLE_CORE then
            print("[UNDERTALE] ОШИБКА: Ядро не загружено!")
            return 
        end
        
        if UT_BATTLE_CORE.battleActive then
            print("[UNDERTALE] Триггер: Бой уже активен")
            return 
        end
        
        print("[UNDERTALE] Начинаем бой с "..enemyData.name)
        
        if UT_BATTLE_CORE.PlaySoundSafe then
            UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
        end
        
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Start then
            local music_enemy = {
                class = enemyEntity:GetClass(),
                name = enemyData.name,
                entity = enemyEntity
            }
            UT_BATTLE_MUSIC.Start(music_enemy)
        end
        
        UT_BATTLE_CORE.currentEnemy = {
            entity = enemyEntity,
            data = enemyData,
            currentAttack = 1
        }
        
        -- СОЗДАЕМ ГРУППУ ВРАГОВ (1-4 штуки)
        UT_BATTLE_CORE.currentTargets = {}
        
        -- Главный враг
        table.insert(UT_BATTLE_CORE.currentTargets, {
            name = enemyData.name,
            class = enemyEntity:GetClass(),
            hp = enemyData.hp,
            maxhp = enemyData.maxhp,
            width = randomEnemy.data.width or 400,     -- ← ДОБАВЬТЕ
            height = randomEnemy.data.height or 350,   -- ← ДОБАВЬТЕ
            entity = enemyEntity,
            attacks = enemyData.attacks,
            isMain = true
        })
        
        -- Добавляем случайных дополнительных врагов (1-3)
        local additionalCount = math.random(1, 3)
        local availableEnemies = {}
        
        for class, data in pairs(UT_BATTLE_TRIGGER.EnemyTypes) do
            if class ~= enemyEntity:GetClass() then
                table.insert(availableEnemies, {
                    class = class,
                    data = data
                })
            end
        end
        
        for i = 1, math.min(additionalCount, #availableEnemies) do
            if #availableEnemies > 0 then
                local randomIndex = math.random(#availableEnemies)
                local randomEnemy = availableEnemies[randomIndex]
                
                table.insert(UT_BATTLE_CORE.currentTargets, {
                    name = randomEnemy.data.name,
                    class = randomEnemy.class,
                    hp = randomEnemy.data.hp,
                    maxhp = enemyData.maxhp,
                    width = enemyData.width or 400,     -- ← ДОБАВЬТЕ
                    height = enemyData.height or 350,   -- ← ДОБАВЬТЕ
                    entity = nil,
                    attacks = randomEnemy.data.attacks,
                    isAdditional = true,
                    spritePath = "enemies/" .. randomEnemy.class .. "/enemy.png"
                })
                
                table.remove(availableEnemies, randomIndex)
            end
        end
        
        print("[UNDERTALE] Создано врагов: " .. #UT_BATTLE_CORE.currentTargets)
        
        -- Показываем информацию о врагах
        local enemyNames = ""
        for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
            enemyNames = enemyNames .. enemy.name
            if i < #UT_BATTLE_CORE.currentTargets then
                enemyNames = enemyNames .. ", "
            end
        end
        
        if enemyData.dialog and #enemyData.dialog > 0 then
            local randomDialog = enemyData.dialog[math.random(#enemyData.dialog)]
            chat.AddText(Color(255, 150, 0), "[ВРАГ] ", Color(255, 255, 255), randomDialog)
        end
        
        chat.AddText(Color(255, 50, 50), "[БОЙ НАЧАТ!] ", Color(255, 255, 255), 
            "Встречены враги: " .. enemyNames .. " (" .. #UT_BATTLE_CORE.currentTargets .. " шт.)")
        chat.AddText(Color(255, 255, 0), "[СИСТЕМА] ", Color(255, 255, 255), 
            "Враги отображены в сетке выше. Используйте стрелки для выбора цели.")
        
        timer.Simple(2, function()
            if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                UT_BATTLE_HUD.CreateBattleMenu()
            else
                chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
                    "Модуль интерфейса не загружен!")
            end
        end)
    end
    
    -- СБРОС ТРИГГЕРОВ
    UT_BATTLE_TRIGGER.ResetTriggers = function()
        print("[UNDERTALE] Сброс триггеров врагов")
        
        local npcs = ents.FindByClass("npc_*")
        for _, npc in pairs(npcs) do
            if npc.BattleTriggered then
                npc.BattleTriggered = false
            end
        end
    end
    
    -- ИНИЦИАЛИЗАЦИЯ
    UT_BATTLE_TRIGGER.Initialize = function()
        print("[UNDERTALE] Инициализация триггера боя")
        
        UT_BATTLE_TRIGGER.detectionRadius = UT_BATTLE_TRIGGER.detectionRadius or 300
        UT_BATTLE_TRIGGER.checkInterval = UT_BATTLE_TRIGGER.checkInterval or 0.5
        UT_BATTLE_TRIGGER.lastCheck = UT_BATTLE_TRIGGER.lastCheck or 0
        
        UT_BATTLE_TRIGGER.ResetTriggers()
        
        hook.Add("Think", "UT_BattleTrigger", function()
            if not UT_BATTLE_CORE then return end
            
            if not UT_BATTLE_TRIGGER.lastCheck then 
                UT_BATTLE_TRIGGER.lastCheck = CurTime() 
            end
            
            local checkInterval = UT_BATTLE_TRIGGER.checkInterval or 0.5
            local lastCheck = UT_BATTLE_TRIGGER.lastCheck or 0
            
            if CurTime() - lastCheck > checkInterval then
                UT_BATTLE_TRIGGER.FindEnemies()
                UT_BATTLE_TRIGGER.lastCheck = CurTime()
            end
        end)
        
        concommand.Add("ut_reset_triggers", function()
            UT_BATTLE_TRIGGER.ResetTriggers()
            chat.AddText(Color(0, 255, 0), "[ТРИГГЕРЫ] ", Color(255, 255, 255), 
                "Все триггеры врагов сброшены!")
        end)
    end
    
    timer.Simple(5, function()
        UT_BATTLE_TRIGGER.Initialize()
        print("[UNDERTALE] Триггер боя готов к работе")
        chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), 
            "Система боя активирована. Подойдите к врагу!")
    end)
    
    print("[UNDERTALE] Улучшенный триггер боя загружен")
end