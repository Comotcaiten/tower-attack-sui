#[test_only]
module sui_interact::game_tests {
    use sui_interact::game::{Self, AdminCap, Monster, Fortress, GameSession, GameRegistry};
    use sui::test_scenario::{Self as ts, Scenario};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::test_utils;

    // Test constants
    const ADMIN: address = @0xAD;
    const PLAYER1: address = @0x1;
    const PLAYER2: address = @0x2;

    // Helper function to create a test clock
    fun create_clock(scenario: &mut Scenario): Clock {
        clock::create_for_testing(ts::ctx(scenario))
    }

    // Helper function to advance clock
    fun advance_clock(clock: &mut Clock, ms: u64) {
        clock::increment_for_testing(clock, ms);
    }

    // Test: Initialize game module
    #[test]
    fun test_init() {
        let mut scenario = ts::begin(ADMIN);
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, ADMIN);
        {
            // Admin should receive AdminCap
            assert!(ts::has_most_recent_for_sender<AdminCap>(&scenario), 0);
            
            // GameRegistry should be shared
            assert!(ts::has_most_recent_shared<GameRegistry>(), 1);
        };
        
        ts::end(scenario);
    }

    // Test: Start a new game session
    #[test]
    fun test_start_game() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            // Game session should be created and shared
            assert!(ts::has_most_recent_shared<GameSession>(), 2);
            assert!(ts::has_most_recent_shared<Fortress>(), 3);
        };
        
        ts::end(scenario);
    }

    // Test: Spawn monster level 1
    #[test]
    fun test_spawn_monster_level1() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize and start game
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            // Create payment (0.1 SUI for level 1)
            let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(
                &mut game,
                &mut registry,
                payment,
                1,
                b"Goblin",
                &clock,
                ts::ctx(&mut scenario)
            );
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            // Player should receive monster NFT
            assert!(ts::has_most_recent_for_sender<Monster>(&scenario), 4);
            
            let monster = ts::take_from_sender<Monster>(&scenario);
            assert!(game::get_monster_base_attack(&monster) == 20, 5);
            assert!(game::get_monster_base_defense(&monster) == 10, 6);
            
            ts::return_to_sender(&scenario, monster);
        };
        
        ts::end(scenario);
    }

    // Test: Spawn monster level 2 and 3
    #[test]
    fun test_spawn_monster_all_levels() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize and start game
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Spawn Level 1
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 1, b"Goblin", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Spawn Level 2
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(200_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 2, b"Orc", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Spawn Level 3
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(400_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 3, b"Dragon", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        ts::end(scenario);
    }

    // Test: Upgrade monster HP
    #[test]
    fun test_upgrade_monster_hp() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Spawn monster
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 1, b"Goblin", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Upgrade HP (0.1 SUI)
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::upgrade_monster_hp(&mut monster, payment, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_to_sender(&scenario, monster);
        };
        
        ts::end(scenario);
    }

    // Test: Upgrade monster Attack
    #[test]
    fun test_upgrade_monster_attack() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Spawn monster
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(200_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 2, b"Orc", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Upgrade Attack (0.15 SUI)
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(150_000_000, ts::ctx(&mut scenario));
            
            game::upgrade_monster_attack(&mut monster, payment, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_to_sender(&scenario, monster);
        };
        
        ts::end(scenario);
    }

    // Test: Upgrade monster Defense
    #[test]
    fun test_upgrade_monster_defense() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Spawn monster
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(400_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 3, b"Dragon", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Upgrade Defense (0.12 SUI)
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(120_000_000, ts::ctx(&mut scenario));
            
            game::upgrade_monster_defense(&mut monster, payment, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_to_sender(&scenario, monster);
        };
        
        ts::end(scenario);
    }

    // Test: Multiple upgrades on same monster
    #[test]
    fun test_multiple_upgrades() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Spawn monster
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 1, b"Goblin", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Upgrade HP twice
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment1 = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::upgrade_monster_hp(&mut monster, payment1, &clock, ts::ctx(&mut scenario));
            
            let payment2 = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            game::upgrade_monster_hp(&mut monster, payment2, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_to_sender(&scenario, monster);
        };
        
        // Upgrade Attack
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(150_000_000, ts::ctx(&mut scenario));
            
            game::upgrade_monster_attack(&mut monster, payment, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_to_sender(&scenario, monster);
        };
        
        // Upgrade Defense
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(120_000_000, ts::ctx(&mut scenario));
            
            game::upgrade_monster_defense(&mut monster, payment, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_to_sender(&scenario, monster);
        };
        
        ts::end(scenario);
    }

    // Test: Defender power increases over time
    #[test]
    fun test_defender_power_increase() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize and start game
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Update defender power after 120 seconds (2 intervals)
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut fortress = ts::take_shared<Fortress>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            // Advance time by 120 seconds
            advance_clock(&mut clock, 120_000);
            
            game::update_defender_power(&mut fortress, &clock);
            
            test_utils::destroy(clock);
            ts::return_shared(fortress);
        };
        
        ts::end(scenario);
    }

    // Test: Attack fortress (simple attack)
    #[test]
    fun test_attack_fortress() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Spawn a strong monster (level 3)
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(400_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 3, b"Dragon", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        // Attack fortress
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut fortress = ts::take_shared<Fortress>(&scenario);
            let mut monster = ts::take_from_sender<Monster>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            game::attack_fortress(&mut game, &mut fortress, &mut monster, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(fortress);
            ts::return_to_sender(&scenario, monster);
        };
        
        ts::end(scenario);
    }

    // Test: End game
    #[test]
    fun test_end_game() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize and start game
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Player ends game
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            game::end_game(&mut game, &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
        };
        
        ts::end(scenario);
    }

    // Test: Insufficient payment for monster spawn
    #[test]
    #[expected_failure(abort_code = 3)] // E_INSUFFICIENT_FUNDS
    fun test_spawn_monster_insufficient_funds() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize and start game
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            
            // Try to spawn level 1 with insufficient payment
            let payment = coin::mint_for_testing<SUI>(50_000_000, ts::ctx(&mut scenario)); // Only 0.05 SUI
            
            game::spawn_monster(&mut game, &mut registry, payment, 1, b"Goblin", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        ts::end(scenario);
    }

    // Test: Invalid monster level
    #[test]
    #[expected_failure(abort_code = 1)] // E_INVALID_LEVEL
    fun test_spawn_monster_invalid_level() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize and start game
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(500_000_000, ts::ctx(&mut scenario));
            
            // Try to spawn level 4 (invalid)
            game::spawn_monster(&mut game, &mut registry, payment, 4, b"SuperDragon", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        ts::end(scenario);
    }

    // Test: Unauthorized access
    #[test]
    #[expected_failure(abort_code = 0)] // E_NOT_AUTHORIZED
    fun test_unauthorized_spawn() {
        let mut scenario = ts::begin(ADMIN);
        
        // Initialize
        {
            game::init_for_testing(ts::ctx(&mut scenario));
        };
        
        // Player 1 starts game
        ts::next_tx(&mut scenario, PLAYER1);
        {
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            game::start_game(&mut registry, &clock, ts::ctx(&mut scenario));
            test_utils::destroy(clock);
            ts::return_shared(registry);
        };
        
        // Player 2 tries to spawn in Player 1's game (should fail)
        ts::next_tx(&mut scenario, PLAYER2);
        {
            let mut game = ts::take_shared<GameSession>(&scenario);
            let mut registry = ts::take_shared<GameRegistry>(&scenario);
            let mut clock = create_clock(&mut scenario);
            let payment = coin::mint_for_testing<SUI>(100_000_000, ts::ctx(&mut scenario));
            
            game::spawn_monster(&mut game, &mut registry, payment, 1, b"Goblin", &clock, ts::ctx(&mut scenario));
            
            test_utils::destroy(clock);
            ts::return_shared(game);
            ts::return_shared(registry);
        };
        
        ts::end(scenario);
    }
}
