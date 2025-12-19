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
    
    // Upgrade costs
    const UPGRADE_HP_COST: u64 = 100_000_000;      // 0.1 SUI per HP upgrade
    const UPGRADE_ATTACK_COST: u64 = 150_000_000;  // 0.15 SUI per Attack upgrade
    const UPGRADE_DEFENSE_COST: u64 = 120_000_000; // 0.12 SUI per Defense upgrade

    // ============ Structs ============
    
    /// Game admin capability
    public struct AdminCap has key, store {
        id: object::UID,
    }

    /// Monster NFT - The attacking units (comes with built-in armor)
    public struct Monster has key, store {
        id: object::UID,
        name: String,
        level: u64,
        base_hp: u64,
        current_hp: u64,
        max_hp: u64,
        base_attack: u64,
        base_defense: u64,
        owner: address,
        hp_upgrade_level: u64,
        attack_upgrade_level: u64,
        defense_upgrade_level: u64,
        created_at: u64,
    }

    /// Fortress - The target to attack
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

    public struct MonsterUpgraded has copy, drop {
        monster_id: object::ID,
        upgrade_type: String,
        new_level: u64,
        cost: u64,
        timestamp: u64,
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
            max_hp: base_hp,
            base_attack,
            base_defense,
            owner: tx_context::sender(ctx),
            hp_upgrade_level: 0,
            attack_upgrade_level: 0,
            defense_upgrade_level: 0,
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

    // ============ Monster Upgrade Functions ============
    
    /// Upgrade monster HP with SUI
    entry fun upgrade_monster_hp(
        monster: &mut Monster,
        payment: Coin<SUI>,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(monster.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(coin::value(&payment) >= UPGRADE_HP_COST, E_INSUFFICIENT_FUNDS);

        // Increase HP by 50 per upgrade
        let hp_increase = 50;
        monster.base_hp = monster.base_hp + hp_increase;
        monster.max_hp = monster.max_hp + hp_increase;
        monster.current_hp = monster.current_hp + hp_increase;
        monster.hp_upgrade_level = monster.hp_upgrade_level + 1;

        event::emit(MonsterUpgraded {
            monster_id: object::id(monster),
            upgrade_type: string::utf8(b"HP"),
            new_level: monster.hp_upgrade_level,
            cost: UPGRADE_HP_COST,
            timestamp: clock::timestamp_ms(clock),
        });

        // Burn payment
        transfer::public_transfer(payment, @0x0);
    }

    /// Upgrade monster Attack with SUI
    entry fun upgrade_monster_attack(
        monster: &mut Monster,
        payment: Coin<SUI>,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(monster.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(coin::value(&payment) >= UPGRADE_ATTACK_COST, E_INSUFFICIENT_FUNDS);

        // Increase Attack by 15 per upgrade
        monster.base_attack = monster.base_attack + 15;
        monster.attack_upgrade_level = monster.attack_upgrade_level + 1;

        event::emit(MonsterUpgraded {
            monster_id: object::id(monster),
            upgrade_type: string::utf8(b"Attack"),
            new_level: monster.attack_upgrade_level,
            cost: UPGRADE_ATTACK_COST,
            timestamp: clock::timestamp_ms(clock),
        });

        // Burn payment
        transfer::public_transfer(payment, @0x0);
    }

    /// Upgrade monster Defense with SUI
    entry fun upgrade_monster_defense(
        monster: &mut Monster,
        payment: Coin<SUI>,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(monster.owner == tx_context::sender(ctx), E_NOT_AUTHORIZED);
        assert!(coin::value(&payment) >= UPGRADE_DEFENSE_COST, E_INSUFFICIENT_FUNDS);

        // Increase Defense by 10 per upgrade
        monster.base_defense = monster.base_defense + 10;
        monster.defense_upgrade_level = monster.defense_upgrade_level + 1;

        event::emit(MonsterUpgraded {
            monster_id: object::id(monster),
            upgrade_type: string::utf8(b"Defense"),
            new_level: monster.defense_upgrade_level,
            cost: UPGRADE_DEFENSE_COST,
            timestamp: clock::timestamp_ms(clock),
        });

        // Burn payment
        transfer::public_transfer(payment, @0x0);
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

        // Use upgraded attack value
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
