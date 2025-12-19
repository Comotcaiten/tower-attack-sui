using System.Runtime.InteropServices;
using UnityEngine;

public class SuiWalletConnector : MonoBehaviour
{
    public static SuiWalletConnector Instance { get; private set; }

    // Your published package ID from Sui blockchain
    [Header("Sui Smart Contract Settings")]
    [Tooltip("Package ID from your published Move contract")]
    public string packageId = "0x0008d7344547816527d57c88354a5b7392922177f2c3655ab4396c2a26d30b55";

    [Header("Game Session")]
    public string currentGameSessionId = "";
    public string currentWalletAddress = "";
    public bool isConnected = false;

    [Header("Monster Management")]
    public string lastSpawnedMonsterId = "";

#if UNITY_WEBGL && !UNITY_EDITOR
    // Import JavaScript functions from .jslib
    [DllImport("__Internal")]
    private static extern void ConnectWallet();

    [DllImport("__Internal")]
    private static extern void DisconnectWallet();

    [DllImport("__Internal")]
    private static extern string GetWalletAddress();

    [DllImport("__Internal")]
    private static extern int IsWalletConnected();

    [DllImport("__Internal")]
    private static extern void StartGameSession(string packageId);

    [DllImport("__Internal")]
    private static extern void SpawnMonster(string packageId, int level);

    [DllImport("__Internal")]
    private static extern void AttackFortress(string packageId, string monsterId, string gameSessionId);

    [DllImport("__Internal")]
    private static extern void UpgradeMonsterHP(string packageId, string monsterId);

    [DllImport("__Internal")]
    private static extern void UpgradeMonsterAttack(string packageId, string monsterId);

    [DllImport("__Internal")]
    private static extern void UpgradeMonsterDefense(string packageId, string monsterId);

    [DllImport("__Internal")]
    private static extern void EndGameSession(string packageId, string gameSessionId);
#endif

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        // Check connection status periodically
        InvokeRepeating("CheckWalletConnection", 1f, 2f);
    }

    void CheckWalletConnection()
    {
#if UNITY_WEBGL && !UNITY_EDITOR
        isConnected = IsWalletConnected() == 1;
        if (isConnected)
        {
            string address = GetWalletAddress();
            if (!string.IsNullOrEmpty(address))
            {
                currentWalletAddress = address;
            }
        }
        else
        {
            currentWalletAddress = "";
        }
#else
        Debug.Log("Wallet connection only works in WebGL build");
#endif
    }

    // ========== Public Methods to Call from Unity ==========

    public void Connect()
    {
#if UNITY_WEBGL && !UNITY_EDITOR
        ConnectWallet();
        Debug.Log("Requesting wallet connection...");
#else
        Debug.Log("Connect wallet - WebGL only");
#endif
    }

    public void Disconnect()
    {
#if UNITY_WEBGL && !UNITY_EDITOR
        DisconnectWallet();
        currentWalletAddress = "";
        isConnected = false;
        Debug.Log("Disconnecting wallet...");
#else
        Debug.Log("Disconnect wallet - WebGL only");
#endif
    }

    public void CreateGameSession()
    {
        if (!isConnected)
        {
            Debug.LogWarning("Wallet not connected. Please connect first.");
            return;
        }

#if UNITY_WEBGL && !UNITY_EDITOR
        StartGameSession(packageId);
        Debug.Log("Starting new game session...");
#else
        Debug.Log("Start game session - WebGL only");
#endif
    }

    public void SpawnMonsterLevel(int level)
    {
        if (!isConnected)
        {
            Debug.LogWarning("Wallet not connected. Please connect first.");
            return;
        }

        if (level < 1 || level > 3)
        {
            Debug.LogError("Invalid monster level. Must be 1, 2, or 3");
            return;
        }

#if UNITY_WEBGL && !UNITY_EDITOR
        SpawnMonster(packageId, level);
        Debug.Log($"Spawning monster level {level}...");
#else
        Debug.Log($"Spawn monster level {level} - WebGL only");
#endif
    }

    public void AttackWithMonster(string monsterId)
    {
        if (!isConnected)
        {
            Debug.LogWarning("Wallet not connected.");
            return;
        }

        if (string.IsNullOrEmpty(currentGameSessionId))
        {
            Debug.LogWarning("No active game session. Start a game session first.");
            return;
        }

#if UNITY_WEBGL && !UNITY_EDITOR
        AttackFortress(packageId, monsterId, currentGameSessionId);
        Debug.Log($"Monster {monsterId} attacking fortress...");
#else
        Debug.Log($"Attack with monster {monsterId} - WebGL only");
#endif
    }

    public void UpgradeHP(string monsterId)
    {
        if (!isConnected) return;
#if UNITY_WEBGL && !UNITY_EDITOR
        UpgradeMonsterHP(packageId, monsterId);
        Debug.Log($"Upgrading monster HP...");
#else
        Debug.Log("Upgrade HP - WebGL only");
#endif
    }

    public void UpgradeAttack(string monsterId)
    {
        if (!isConnected) return;
#if UNITY_WEBGL && !UNITY_EDITOR
        UpgradeMonsterAttack(packageId, monsterId);
        Debug.Log($"Upgrading monster Attack...");
#else
        Debug.Log("Upgrade Attack - WebGL only");
#endif
    }

    public void UpgradeDefense(string monsterId)
    {
        if (!isConnected) return;
#if UNITY_WEBGL && !UNITY_EDITOR
        UpgradeMonsterDefense(packageId, monsterId);
        Debug.Log($"Upgrading monster Defense...");
#else
        Debug.Log("Upgrade Defense - WebGL only");
#endif
    }

    public void EndGame()
    {
        if (!isConnected || string.IsNullOrEmpty(currentGameSessionId)) return;
#if UNITY_WEBGL && !UNITY_EDITOR
        EndGameSession(packageId, currentGameSessionId);
        Debug.Log("Ending game session...");
#else
        Debug.Log("End game - WebGL only");
#endif
    }

    // ========== Callbacks from JavaScript ==========
    // These methods will be called from JavaScript when transactions complete

    public void OnWalletConnected(string address)
    {
        currentWalletAddress = address;
        isConnected = true;
        Debug.Log($"Wallet connected: {address}");
    }

    public void OnWalletDisconnected()
    {
        currentWalletAddress = "";
        isConnected = false;
        currentGameSessionId = "";
        Debug.Log("Wallet disconnected");
    }

    public void OnGameSessionCreated(string sessionId)
    {
        currentGameSessionId = sessionId;
        Debug.Log($"Game session created: {sessionId}");
        // Notify GameManager that session is ready
        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnBlockchainSessionReady();
        }
    }

    public void OnMonsterSpawned(string monsterId)
    {
        lastSpawnedMonsterId = monsterId;
        Debug.Log($"Monster spawned: {monsterId}");
    }

    public void OnTransactionSuccess(string message)
    {
        Debug.Log($"Transaction successful: {message}");
    }

    public void OnTransactionError(string error)
    {
        Debug.LogError($"Transaction failed: {error}");
    }
}
