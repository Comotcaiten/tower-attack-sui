mergeInto(LibraryManager.library, {
  // Connect to Slush Wallet
  ConnectWallet: function () {
    try {
      if (typeof window.connectWallet === "function") {
        window.connectWallet();
      } else {
        console.error("connectWallet function not found");
      }
    } catch (error) {
      console.error("Error connecting wallet:", error);
    }aaa    
  },

  // Disconnect Wallet
  DisconnectWallet: function () {
    try {
      if (typeof window.disconnectWallet === "function") {
        window.disconnectWallet();
      }
    } catch (error) {
      console.error("Error disconnecting wallet:", error);
    }
  },

  // Get current wallet address (returns string pointer)
  GetWalletAddress: function () {
    try {
      var address = window.currentWalletAddress || "";
      var bufferSize = lengthBytesUTF8(address) + 1;
      var buffer = _malloc(bufferSize);
      stringToUTF8(address, buffer, bufferSize);
      return buffer;
    } catch (error) {
      console.error("Error getting wallet address:", error);
      return null;
    }
  },

  // Check if wallet is connected
  IsWalletConnected: function () {
    try {
      return window.isWalletConnected === true ? 1 : 0;
    } catch (error) {
      return 0;
    }
  },

  // Start new game session
  StartGameSession: function (packageIdPtr) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      if (typeof window.startGameSession === "function") {
        window.startGameSession(packageId);
      }
    } catch (error) {
      console.error("Error starting game session:", error);
    }
  },

  // Spawn monster
  SpawnMonster: function (packageIdPtr, level) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      if (typeof window.spawnMonster === "function") {
        window.spawnMonster(packageId, level);
      }
    } catch (error) {
      console.error("Error spawning monster:", error);
    }
  },

  // Attack fortress
  AttackFortress: function (packageIdPtr, monsterIdPtr, gameSessionIdPtr) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      var monsterId = UTF8ToString(monsterIdPtr);
      var gameSessionId = UTF8ToString(gameSessionIdPtr);
      if (typeof window.attackFortress === "function") {
        window.attackFortress(packageId, monsterId, gameSessionId);
      }
    } catch (error) {
      console.error("Error attacking fortress:", error);
    }
  },

  // Upgrade monster HP
  UpgradeMonsterHP: function (packageIdPtr, monsterIdPtr) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      var monsterId = UTF8ToString(monsterIdPtr);
      if (typeof window.upgradeMonsterHP === "function") {
        window.upgradeMonsterHP(packageId, monsterId);
      }
    } catch (error) {
      console.error("Error upgrading monster HP:", error);
    }
  },

  // Upgrade monster Attack
  UpgradeMonsterAttack: function (packageIdPtr, monsterIdPtr) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      var monsterId = UTF8ToString(monsterIdPtr);
      if (typeof window.upgradeMonsterAttack === "function") {
        window.upgradeMonsterAttack(packageId, monsterId);
      }
    } catch (error) {
      console.error("Error upgrading monster attack:", error);
    }
  },

  // Upgrade monster Defense
  UpgradeMonsterDefense: function (packageIdPtr, monsterIdPtr) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      var monsterId = UTF8ToString(monsterIdPtr);
      if (typeof window.upgradeMonsterDefense === "function") {
        window.upgradeMonsterDefense(packageId, monsterId);
      }
    } catch (error) {
      console.error("Error upgrading monster defense:", error);
    }
  },

  // End game session
  EndGameSession: function (packageIdPtr, gameSessionIdPtr) {
    try {
      var packageId = UTF8ToString(packageIdPtr);
      var gameSessionId = UTF8ToString(gameSessionIdPtr);
      if (typeof window.endGameSession === "function") {
        window.endGameSession(packageId, gameSessionId);
      }
    } catch (error) {
      console.error("Error ending game session:", error);
    }
  },
});
