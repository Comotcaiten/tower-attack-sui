module sui_interact::game {
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::clock::{Self, Clock};
    use sui::event;
    use std::string::{Self, String};

    // ============ Error Codes ============
    const E_NOT_AUTHORIZED: u64 = 0;
    const E_INVALID_LEVEL: u64 = 1;
    const E_MONSTER_DEAD: u64 = 2;
    const E_INSUFFICIENT_FUNDS: u64 = 3;
    const E_GAME_ALREADY_ENDED: u64 = 5;
    const E_FORTRESS_ALREADY_DESTROYED: u64 = 6;

    // ============ Constants ============
    const MAX_MONSTER_LEVEL: u64 = 3;
    const SPAWN_COST_LV1: u64 = 100_000_000; // 0.1 SUI
    const SPAWN_COST_LV2: u64 = 200_000_000; // 0.2 SUI
    const SPAWN_COST_LV3: u64 = 400_000_000; // 0.4 SUI
    const DEFENDER_POWER_INCREASE_INTERVAL: u64 = 60000; // 60 seconds in milliseconds
    
    // Weapon costs by rarity
    const WEAPON_COST_COMMON: u64 = 50_000_000;     // 0.05 SUI (rarity 1)
    const WEAPON_COST_RARE: u64 = 150_000_000;      // 0.15 SUI (rarity 2)
    const WEAPON_COST_LEGENDARY: u64 = 300_000_000; // 0.3 SUI (rarity 3)
    
    // Armor costs by rarity
    const ARMOR_COST_COMMON: u64 = 50_000_000;      // 0.05 SUI (rarity 1)
    const ARMOR_COST_RARE: u64 = 150_000_000;       // 0.15 SUI (rarity 2)
    const ARMOR_COST_LEGENDARY: u64 = 300_000_000;  // 0.3 SUI (rarity 3)

    // ============ Structs ============
    
    /// Game admin capability
    public struct AdminCap has key, store {
        id: object::UID,
    }

    /// Monster NFT - The attacking units
    public struct Monster has key, store {
        id: object::UID,
        name: String,
        level: u64,
        base_hp: u64,
        current_hp: u64,
        base_attack: u64,
        base_defense: u64,
        owner: address,
        equipped_weapon: Option<object::ID>, // Weapon NFT ID if equipped
        equipped_armor: Option<object::ID>,  // Armor NFT ID if equipped
        created_at: u64,
    }

    /// Weapon NFT - Increases attack power
    public struct Weapon has key, store {
        id: object::UID,
        name: String,
        attack_bonus: u64,
        rarity: u8, 
        owner: address,
    }

    /// Armor NFT - Increases defense
    public struct Armor has key, store {
        id: object::UID,
        name: String,
        defense_bonus: u64,
        rarity: u8,
        owner: address,
    }

    /// Fortress (Cứ điểm) - The target to attack
    public struct Fortress has key, store {
        id: object::UID,
        level: u64,
        hp: u64,
        defender_base_power: u64,
        defender_current_power: u64,
        last_power_increase: u64,
        is_destroyed: bool,
        game_id: object::ID,
    }

    /// Game Session
    public struct GameSession has key, store {
        id: object::UID,
        player: address,
        fortress_id: object::ID,
        monsters_spawned: vector<object::ID>,
        items_dropped: vector<object::ID>,
        start_time: u64,
        end_time: Option<u64>,
        victory: Option<bool>,
        reward_claimed: bool,
    }

    /// Global game registry
    public struct GameRegistry has key {
        id: object::UID,
        total_games: u64,
        total_monsters_spawned: u64,
        total_items_dropped: u64,
    }

    // ============ Events ============
    
    public struct MonsterSpawned has copy, drop {
        monster_id: object::ID,
        owner: address,
        level: u64,
        timestamp: u64,
    }

    public struct MonsterEquipped has copy, drop {
        monster_id: object::ID,
        item_id: object::ID,
        item_type: String,
    }
    

    public struct GameStarted has copy, drop {
        game_id: object::ID,
        player: address,
        timestamp: u64,
    }

    public struct GameEnded has copy, drop {
        game_id: object::ID,
        player: address,
        victory: bool,
        timestamp: u64,
    }

    public struct FortressDestroyed has copy, drop {
        fortress_id: object::ID,
        game_id: object::ID,
        timestamp: u64,
    }

    public struct WeaponPurchased has copy, drop {
        weapon_id: object::ID,
        buyer: address,
        rarity: u8,
        cost: u64,
        timestamp: u64,
    }

    public struct ArmorPurchased has copy, drop {
        armor_id: object::ID,
        buyer: address,
        rarity: u8,
        cost: u64,
        timestamp: u64,
    }

    // ============ Init Function ============
    
    fun init(ctx: &mut tx_context::TxContext) {
        // Create admin capability
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        transfer::transfer(admin_cap, tx_context::sender(ctx));

        // Create game registry
        let registry = GameRegistry {
            id: object::new(ctx),
            total_games: 0,
            total_monsters_spawned: 0,
            total_items_dropped: 0,
        };
        transfer::share_object(registry);
    }

    // ============ Game Session Functions ============
    
    /// Start a new game session
    entry fun start_game(
        registry: &mut GameRegistry,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        let game_id = object::new(ctx);
        let fortress_id = object::new(ctx);
        
        let current_time = clock::timestamp_ms(clock);
        
        // Create fortress
        let fortress_inner_id = object::uid_to_inner(&fortress_id);
        let fortress = Fortress {
            id: fortress_id,
            level: 1,
            hp: 1000,
            defender_base_power: 50,
            defender_current_power: 50,
            last_power_increase: current_time,
            is_destroyed: false,
            game_id: object::uid_to_inner(&game_id),
        };
        transfer::share_object(fortress);

        // Create game session
        let game = GameSession {
            id: game_id,
            player: tx_context::sender(ctx),
            fortress_id: fortress_inner_id,
            monsters_spawned: vector::empty(),
            items_dropped: vector::empty(),
            start_time: current_time,
            end_time: std::option::none(),
            victory: std::option::none(),
            reward_claimed: false,
        };
        
        let game_inner_id = object::uid_to_inner(&game.id);
        
        registry.total_games = registry.total_games + 1;

        event::emit(GameStarted {
            game_id: game_inner_id,
            player: tx_context::sender(ctx),
            timestamp: current_time,
        });

        transfer::share_object(game);
    }

    // ============ Monster Functions ============
    
    /// Spawn a monster (Level 1-3)
    entry fun spawn_monster(
        game: &mut GameSession,
        registry: &mut GameRegistry,
        payment: Coin<SUI>,
        level: u64,
        name: vector<u8>,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(level >= 1 && level <= MAX_MONSTER_LEVEL, E_INVALID_LEVEL);
        assert!(std::option::is_none(&game.end_time), E_GAME_ALREADY_ENDED);
        assert!(game.player == tx_context::sender(ctx), E_NOT_AUTHORIZED);

        // Check payment
        let cost = if (level == 1) {
            SPAWN_COST_LV1
        } else if (level == 2) {
            SPAWN_COST_LV2
        } else {
            SPAWN_COST_LV3
        };
        assert!(coin::value(&payment) >= cost, E_INSUFFICIENT_FUNDS);

        // Calculate monster stats based on level
        let (base_hp, base_attack, base_defense) = calculate_monster_stats(level);
        
        let monster_id = object::new(ctx);
        let monster = Monster {
            id: monster_id,
            name: string::utf8(name),
            level,
            base_hp,
            current_hp: base_hp,
            base_attack,
            base_defense,
            owner: tx_context::sender(ctx),
            equipped_weapon: std::option::none(),
            equipped_armor: std::option::none(),
            created_at: clock::timestamp_ms(clock),
        };

        let monster_inner_id = object::uid_to_inner(&monster.id);
        vector::push_back(&mut game.monsters_spawned, monster_inner_id);
        registry.total_monsters_spawned = registry.total_monsters_spawned + 1;

        event::emit(MonsterSpawned {
            monster_id: monster_inner_id,
            owner: tx_context::sender(ctx),
            level,
            timestamp: clock::timestamp_ms(clock),
        });

        // Transfer payment to treasury (burn or keep)
        transfer::public_transfer(payment, @0x0);
        
        // Transfer monster NFT to player
        transfer::public_transfer(monster, tx_context::sender(ctx));
    }

    /// Calculate monster stats based on level
    fun calculate_monster_stats(level: u64): (u64, u64, u64) {
        if (level == 1) {
            (100, 20, 10)  // HP, ATK, DEF
        } else if (level == 2) {
            (250, 45, 25)
        } else {
            (500, 90, 50)
        }
    }

    // ============ Item Functions ============
    
    /// Buy a weapon with SUI
    entry fun buy_weapon(
        registry: &mut GameRegistry,
        payment: Coin<SUI>,
        name: vector<u8>,
        rarity: u8,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(rarity >= 1 && rarity <= 3, E_INVALID_LEVEL);

        // Determine cost and attack bonus based on rarity
        let (cost, attack_bonus) = if (rarity == 1) {
            (WEAPON_COST_COMMON, 10)
        } else if (rarity == 2) {
            (WEAPON_COST_RARE, 25)
        } else {
            (WEAPON_COST_LEGENDARY, 50)
        };

        assert!(coin::value(&payment) >= cost, E_INSUFFICIENT_FUNDS);

        let buyer = tx_context::sender(ctx);
        let weapon_id = object::new(ctx);
        let weapon = Weapon {
            id: weapon_id,
            name: string::utf8(name),
            attack_bonus,
            rarity,
            owner: buyer,
        };

        let weapon_inner_id = object::uid_to_inner(&weapon.id);
        registry.total_items_dropped = registry.total_items_dropped + 1;

        event::emit(WeaponPurchased {
            weapon_id: weapon_inner_id,
            buyer,
            rarity,
            cost,
            timestamp: clock::timestamp_ms(clock),
        });

        // Burn payment
        transfer::public_transfer(payment, @0x0);
        
        // Transfer weapon to buyer
        transfer::public_transfer(weapon, buyer);
    }



    /// Buy an armor with SUI
    entry fun buy_armor(
        registry: &mut GameRegistry,
        payment: Coin<SUI>,
        name: vector<u8>,
        rarity: u8,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(rarity >= 1 && rarity <= 3, E_INVALID_LEVEL);

        // Determine cost and defense bonus based on rarity
        let (cost, defense_bonus) = if (rarity == 1) {
            (ARMOR_COST_COMMON, 10)
        } else if (rarity == 2) {
            (ARMOR_COST_RARE, 25)
        } else {
            (ARMOR_COST_LEGENDARY, 50)
        };

        assert!(coin::value(&payment) >= cost, E_INSUFFICIENT_FUNDS);

        let buyer = tx_context::sender(ctx);
        let armor_id = object::new(ctx);
        let armor = Armor {
            id: armor_id,
            name: string::utf8(name),
            defense_bonus,
            rarity,
            owner: buyer,
        };

        let armor_inner_id = object::uid_to_inner(&armor.id);
        registry.total_items_dropped = registry.total_items_dropped + 1;

        event::emit(ArmorPurchased {
            armor_id: armor_inner_id,
            buyer,
            rarity,
            cost,
            timestamp: clock::timestamp_ms(clock),
        });

        // Burn payment
        transfer::public_transfer(payment, @0x0);
        
        // Transfer armor to buyer
        transfer::public_transfer(armor, buyer);
    }



    /// Equip weapon to monster
    entry fun equip_weapon(
        monster: &mut Monster,
        weapon: &Weapon,
        ctx: &tx_context::TxContext
    ) {
        assert!(monster.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(weapon.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        
        let weapon_id = object::id(weapon);
        monster.equipped_weapon = std::option::some(weapon_id);

        event::emit(MonsterEquipped {
            monster_id: object::id(monster),
            item_id: weapon_id,
            item_type: string::utf8(b"weapon"),
        });
    }

    /// Equip armor to monster
    entry fun equip_armor(
        monster: &mut Monster,
        armor: &Armor,
        ctx: &tx_context::TxContext
    ) {
        assert!(monster.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(armor.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        
        let armor_id = object::id(armor);
        monster.equipped_armor = std::option::some(armor_id);

        event::emit(MonsterEquipped {
            monster_id: object::id(monster),
            item_id: armor_id,
            item_type: string::utf8(b"armor"),
        });
    }

    // ============ Battle Functions ============
    
    /// Update defender power based on time elapsed
    entry fun update_defender_power(
        fortress: &mut Fortress,
        clock: &Clock,
    ) {
        assert!(!fortress.is_destroyed, E_FORTRESS_ALREADY_DESTROYED);
        
        let current_time = clock::timestamp_ms(clock);
        let time_elapsed = current_time - fortress.last_power_increase;
        
        // Increase power every 60 seconds
        let power_increases = time_elapsed / DEFENDER_POWER_INCREASE_INTERVAL;
        
        if (power_increases > 0) {
            fortress.defender_current_power = fortress.defender_current_power + (power_increases * 5);
            fortress.last_power_increase = current_time;
        };
    }

    /// Attack fortress with monster
    entry fun attack_fortress(
        game: &mut GameSession,
        fortress: &mut Fortress,
        monster: &mut Monster,
        clock: &Clock,
        ctx: &tx_context::TxContext
    ) {
        assert!(game.player == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(monster.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(!fortress.is_destroyed, E_FORTRESS_ALREADY_DESTROYED);
        assert!(monster.current_hp > 0, E_MONSTER_DEAD);
        assert!(std::option::is_none(&game.end_time), E_GAME_ALREADY_ENDED);

        // Calculate total attack (base only, weapon bonus handled via equipped_weapon ID)
        let total_attack = monster.base_attack;

        // Monster attacks fortress
        let damage_to_fortress = if (total_attack > fortress.defender_current_power) {
            total_attack - fortress.defender_current_power
        } else {
            0
        };

        if (damage_to_fortress >= fortress.hp) {
            fortress.hp = 0;
            fortress.is_destroyed = true;
            
            // Game won
            game.end_time = std::option::some(clock::timestamp_ms(clock));
            game.victory = std::option::some(true);

            event::emit(FortressDestroyed {
                fortress_id: object::id(fortress),
                game_id: object::id(game),
                timestamp: clock::timestamp_ms(clock),
            });

            event::emit(GameEnded {
                game_id: object::id(game),
                player: game.player,
                victory: true,
                timestamp: clock::timestamp_ms(clock),
            });
        } else {
            fortress.hp = fortress.hp - damage_to_fortress;

            // Defender counter-attacks monster
            let damage_to_monster = if (fortress.defender_current_power > monster.base_defense) {
                fortress.defender_current_power - monster.base_defense
            } else {
                1 // Minimum damage
            };

            if (damage_to_monster >= monster.current_hp) {
                monster.current_hp = 0;
            } else {
                monster.current_hp = monster.current_hp - damage_to_monster;
            };
        };
    }

    /// End game (player forfeit or timeout)
    entry fun end_game(
        game: &mut GameSession,
        clock: &Clock,
        ctx: &tx_context::TxContext
    ) {
        assert!(game.player == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(std::option::is_none(&game.end_time), E_GAME_ALREADY_ENDED);

        game.end_time = std::option::some(clock::timestamp_ms(clock));
        game.victory = std::option::some(false);

        event::emit(GameEnded {
            game_id: object::id(game),
            player: game.player,
            victory: false,
            timestamp: clock::timestamp_ms(clock),
        });
    }

    // ============ View Functions ============
    
    /// Get monster base attack
    public fun get_monster_base_attack(monster: &Monster): u64 {
        monster.base_attack
    }

    /// Get monster base defense
    public fun get_monster_base_defense(monster: &Monster): u64 {
        monster.base_defense
    }

    // ============ Test Helper Functions ============
    
    #[test_only]
    public fun init_for_testing(ctx: &mut tx_context::TxContext) {
        init(ctx);
    }
}
