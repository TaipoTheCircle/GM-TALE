-- ФАЙЛ: ut_attack_manager.lua
if CLIENT then
    print("[UNDERTALE] Загрузка менеджера атак...")
    
    UT_ATTACK_MANAGER = UT_ATTACK_MANAGER or {}
    
    -- Функция для получения атак врага
    function UT_ATTACK_MANAGER.GetEnemyAttacks(enemy)
        -- Сначала проверяем кастомные атаки из триггера
        if enemy.customAttacks and #enemy.customAttacks > 0 then
            return enemy.customAttacks
        end
        
        -- Затем проверяем из UT_ENEMY_DATA
        local enemyData = UT_ENEMY_DATA.Get(enemy.class)
        if enemyData and enemyData.attacks then
            return enemyData.attacks
        end
        
        -- Дефолтные атаки
        return {
            { type = "Projectile", count = 3, speed = 200, damage = 2 }
        }
    end
    
    -- Функция для создания снарядов атаки
    function UT_ATTACK_MANAGER.CreateAttackBullets(enemy, attackIndex)
        local attacks = UT_ATTACK_MANAGER.GetEnemyAttacks(enemy)
        if not attacks[attackIndex] then
            return {}
        end
        
        local attackConfig = attacks[attackIndex]
        
        -- Используем новую систему кастомных атак
        if UT_CUSTOM_ATTACKS and UT_CUSTOM_ATTACKS.CreateAttack then
            return UT_CUSTOM_ATTACKS.CreateAttack(enemy, attackConfig)
        end
        
        return {}
    end
    
    -- Функция для получения диалога атаки
    function UT_ATTACK_MANAGER.GetAttackDialog(enemy, attackIndex)
        local attacks = UT_ATTACK_MANAGER.GetEnemyAttacks(enemy)
        if attacks[attackIndex] and attacks[attackIndex].dialog then
            return attacks[attackIndex].dialog
        end
        return nil
    end
    
    print("[UNDERTALE] Менеджер атак загружен")
end