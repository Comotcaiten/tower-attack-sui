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

    void Awake()
    {
        Instance = this;
        State = GameState.Preparing;
    }

    void Start()
    {
        StartGame();
        GameWinScreen!.SetActive(false);
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
        // SpawnAtPointer(hit.collider.transform.position);
        spawnManager.SpawnMonster(datas[0], hit.transform.position);
    }

    IEnumerator EndAfter() {
        yield return new WaitForSeconds(1f);

        State = GameState.End;
    } 
}
