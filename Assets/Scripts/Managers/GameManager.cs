using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public enum GameState
{
    Preparing,
    Playing,
    Win,
    Lose,
    End
}

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;

    public GameState State { get; private set; }

    public SpawnManager spawnManager;

    public List<MonsterData> datas;

    public GameObject GameWinScreen;
    public GameObject EnergyBarUI;

    [Header("Blockchain Integration")]
    public bool useBlockchain = false;
    private bool blockchainSessionReady = false;

    void Awake()
    {
        Instance = this;
        State = GameState.Preparing;
    }

    void Start()
    {
        // If blockchain is enabled, wait for session
        if (!useBlockchain)
        {
            StartGame();
        }
        GameWinScreen!.SetActive(false);
    }

    // Called by BlockchainGameIntegration when session is ready
    public void OnBlockchainSessionReady()
    {
        blockchainSessionReady = true;
        StartGame();
    }

    void Update()
    {
        if (State == GameState.Playing)
        {
            if (Input.GetMouseButtonDown(0))
            {
                if (datas.Count <= 0)
                {
                    Debug.Log("GameManager > Datas > [Null-0x00000000]: Dont have any data to spawn");
                    return;
                }
                Debug.Log("Mouse Button Down");
                HandleClick();
            }
        }
    }

    public void StartGame()
    {
        State = GameState.Playing;
    }

    public void Win()
    {
        State = GameState.Win;

        GameWinScreen!.SetActive(true);
        EnergyBarUI!.SetActive(false);

    }

    public void Lose()
    {
        State = GameState.Lose;
    }

    void HandleClick()
    {
        Vector2 worldPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);

        RaycastHit2D hit = Physics2D.Raycast(worldPos, Vector2.zero);

        if (hit.collider == null)
            return;

        if (!hit.collider.CompareTag(TagConfigs.PointerTag))
            return;
        
        Debug.Log("Point: " + hit.transform.position);
        
        // Spawn monster in Unity
        spawnManager.SpawnMonster(datas[0], hit.transform.position);

        // If blockchain enabled, spawn on-chain too
        if (useBlockchain && blockchainSessionReady && SuiWalletConnector.Instance != null)
        {
            // Determine monster level (you can make this dynamic based on datas[0])
            int monsterLevel = 1; // Default level 1
            SuiWalletConnector.Instance.SpawnMonsterLevel(monsterLevel);
        }
    }

    IEnumerator EndAfter() {
        yield return new WaitForSeconds(1f);

        State = GameState.End;
    } 
}
