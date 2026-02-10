-- ФАЙЛ: config.lua (ИСПРАВЛЕННЫЙ)
if CLIENT then
    print("[UNDERTALE] Загрузка конфигурации системы...")
    
    UNDERTALE_CONFIG = UNDERTALE_CONFIG or {}
    
    -- КОНФИГУРАЦИЯ СЕТКИ ВРАГОВ
    UNDERTALE_CONFIG.ENEMY_GRID = {
        COLUMNS = 6,
        ROWS = 2,
        MAX_ENEMIES = 12,
        CELL_PADDING = 5,
        
        GRID = {
            WIDTH_RATIO = 0.9,
            HEIGHT_RATIO = 0.4,
            Y_POSITION = 0.1,
            BACKGROUND_COLOR = Color(0, 20, 0, 80),
            LINE_COLOR = Color(0, 100, 0, 30),
            BORDER_COLOR = Color(0, 255, 0, 80),
            BORDER_SIZE = 2
        }
    }
    
    -- КОНФИГУРАЦИЯ ВРАГОВ
    UNDERTALE_CONFIG.ENEMIES = {
        DEFAULT_SPRITE = "undertale/default_enemy.png",
        FALLBACK_COLOR = Color(200, 50, 50, 200),
        
        CELL = {
            BACKGROUND_COLOR = Color(30, 30, 40, 180),
            SELECTED_BORDER = Color(255, 255, 0, 200),
            NORMAL_BORDER = Color(255, 255, 255, 80),
            SELECTED_SIZE = 3,
            NORMAL_SIZE = 1
        },
        
        SPRITE = {
            WIDTH_RATIO = 0.7,
            HEIGHT_RATIO = 0.7,
            PULSE_SPEED = 2,
            PULSE_AMOUNT = 0.1
        },
        
        HP_BAR = {
            WIDTH_RATIO = 0.8,
            HEIGHT = 10,
            BACKGROUND_COLOR = Color(50, 50, 50, 255),
            BORDER_COLOR = Color(255, 255, 255, 100),
            BORDER_SIZE = 1,
            
            COLORS = {
                HEALTHY = Color(0, 255, 0, 255),
                WOUNDED = Color(255, 255, 0, 255),
                CRITICAL = Color(255, 50, 0, 255)
            }
        },
        
        DEATH = {
            BACKGROUND_COLOR = Color(80, 80, 80, 120),
            CROSS_COLOR = Color(150, 0, 0, 180),
            TEXT_COLOR = Color(200, 50, 50, 180),
            SPEED = 50,
            MAX_OFFSET = 100,
            REMOVE_DELAY = 3
        }
    }
    
    -- НАСТРОЙКИ ИНТЕРФЕЙСА
    UNDERTALE_CONFIG.UI = {
        BATTLE_FRAME = {
            BACKGROUND_COLOR = Color(0, 0, 0, 255),
            DARKEN_COLOR = Color(0, 0, 0, 180),
            DARKEN_START = 0.55,
            GRADIENT_HEIGHT = 50
        },
        
        DIALOG_PANEL = {
            WIDTH = 900,
            HEIGHT = 250,
            BACKGROUND_COLOR = Color(0, 0, 0, 230),
            BORDER_COLOR = Color(255, 255, 255, 150),
            BORDER_SIZE = 2,
            CORNER_RADIUS = 30,
            Y_POSITION = 0.55
        },
        
        BUTTON_PANEL = {
            HEIGHT = 130,
            SPACING_RATIO = 1,
            BUTTON_HEIGHT = 90
        },
        
        INFO_PANEL = {
            WIDTH_OFFSET = 40,
            HEIGHT = 60,
            BACKGROUND_COLOR = Color(0, 0, 0, 200),
            BORDER_COLOR = Color(255, 255, 255, 100),
            BORDER_SIZE = 1,
            
            HP_BAR = {
                HEIGHT = 15,
                BACKGROUND_COLOR = Color(50, 50, 50, 255),
                COLORS = {
                    HEALTHY = Color(255, 255, 0, 255),
                    WOUNDED = Color(255, 165, 0, 255),
                    CRITICAL = Color(255, 50, 0, 255)
                },
                BORDER_COLOR = Color(255, 255, 255, 100),
                BORDER_SIZE = 2
            }
        },
        
        SELECTION = {
            ACTIVE_COLOR = Color(255, 255, 0, 200),
            INACTIVE_COLOR = Color(255, 255, 255, 80),
            BORDER_SIZE = 3
        }
    }
    
    -- КОНТРОЛЬНЫЕ НАСТРОЙКИ
    UNDERTALE_CONFIG.CONTROLS = {
        KEY_COOLDOWN = 0.15,
        KEY_REPEAT_DELAY = 0.4,
        KEY_REPEAT_RATE = 0.1,
        
        NAVIGATION = {
            GRID_COLUMNS = 6,
            WRAP_AROUND = true,
            SKIP_DEAD = true
        }
    }
    
    -- АТАКА НАСТРОЙКИ
    UNDERTALE_CONFIG.ATTACK = {
        BAR = {
            SPEED = 400,
            WIDTH = 30,
            MAX_DAMAGE = 15,
            ZONE_WIDTH = 80,
            ZONE_COLOR = Color(0, 255, 0, 50),
            ZONE_BORDER = Color(0, 255, 0, 150),
            ZONE_BORDER_SIZE = 2
        },
        
        RESULTS = {
            HIT_COLOR = Color(0, 255, 0),
            CRITICAL_COLOR = Color(255, 255, 0),
            MISS_COLOR = Color(255, 50, 50),
            
            ACCURACY = {
                CRITICAL_THRESHOLD = 0.9,
                MIN_DAMAGE = 1
            }
        }
    }
    
    -- МУЗЫКА НАСТРОЙКИ
    UNDERTALE_CONFIG.MUSIC = {
        VOLUME = 5,
        LOOP = true,
        
        TRACKS = {
            DEFAULT = {
                "undertale/enemy_approaching.mp3",
                "undertale/enemy_retreating.mp3", 
                "undertale/enemy_approaching_classic.mp3"
            },
            
            NPC_SPECIFIC = {
                ["npc_antlion_s"] = "undertale/combat_strong.mp3",
                ["npc_antlionworker"] = "undertale/combat_creepy.mp3"
            }
        }
    }
    
    -- ШРИФТЫ
    UNDERTALE_CONFIG.FONTS = {
        MENU = {
            FONT = "Arial",
            SIZE = 24,
            WEIGHT = 500
        },
        
        SMALL = {
            FONT = "Arial",
            SIZE = 18,
            WEIGHT = 400
        },
        
        PLAYER_NAME = {
            FONT = "Arial",
            SIZE = 20,
            WEIGHT = 700
        },
        
        ATTACK = {
            FONT = "Arial",
            SIZE = 36,
            WEIGHT = 700
        },
        
        ENEMY_NAME = {
            FONT = "Arial",
            SIZE = 22,
            WEIGHT = 700
        }
    }
    
    -- ЗВУКИ
    UNDERTALE_CONFIG.SOUNDS = {
        SELECT = "undertale-select-sound.mp3",
        SLASH = "undertale-slash.mp3",
        ATTACK_SLASH = "undertale-attack-slash-green-screen.mp3",
        CRITICAL = "undertale-critical.mp3",
        MISS = "undertale-miss.mp3",
        FALLBACK = "buttons/button14.wav",
        DAMAGE = "buttons/button15.wav"
    }
    
    -- ФУНКЦИИ ДЛЯ РАБОТЫ С КОНФИГОМ
    function UNDERTALE_CONFIG.GetGridPosition(index, totalCells)
        local cols = UNDERTALE_CONFIG.ENEMY_GRID.COLUMNS
        
        local col = (index - 1) % cols
        local row = math.floor((index - 1) / cols)
        
        return col, row
    end
    
    function UNDERTALE_CONFIG.GetHPBarColor(percent)
        local colors = UNDERTALE_CONFIG.ENEMIES.HP_BAR.COLORS
        
        if percent > 0.5 then
            return colors.HEALTHY
        elseif percent > 0.2 then
            return colors.WOUNDED
        else
            return colors.CRITICAL
        end
    end
    
    function UNDERTALE_CONFIG.GetGridDimensions()
        local config = UNDERTALE_CONFIG.ENEMY_GRID.GRID
        
        return {
            width = ScrW() * config.WIDTH_RATIO,
            height = ScrH() * config.HEIGHT_RATIO,
            x = ScrW()/2 - (ScrW() * config.WIDTH_RATIO)/2,
            y = ScrH() * config.Y_POSITION
        }
    end
    
    function UNDERTALE_CONFIG.GetCellDimensions(gridWidth, gridHeight)
        local cols = UNDERTALE_CONFIG.ENEMY_GRID.COLUMNS
        local rows = UNDERTALE_CONFIG.ENEMY_GRID.ROWS
        
        return {
            width = gridWidth / cols,
            height = gridHeight / rows
        }
    end
    
    function UNDERTALE_CONFIG.CreateFonts()
        for name, config in pairs(UNDERTALE_CONFIG.FONTS) do
            surface.CreateFont("UT_" .. name, {
                font = config.FONT,
                size = config.SIZE,
                weight = config.WEIGHT,
                antialias = true,
                additive = false
            })
        end
    end
    
    -- Автоматическое создание шрифтов
    timer.Simple(1, function()
        UNDERTALE_CONFIG.CreateFonts()
        print("[UNDERTALE] Шрифты созданы из конфигурации")
    end)
    
    print("[UNDERTALE] Конфигурация системы загружена")
end