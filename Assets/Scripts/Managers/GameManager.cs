using System.Collections.Generic;
using UnityEngine;
public enum GameState
{
    Preparing,
    Playing,
    Win,
    Lose
}

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;

    public GameState State { get; private set; }

    public SpawnManager spawnManager;

    public List<MonsterData> datas;

    void Awake()
    {
        Instance = this;
        State = GameState.Preparing;
    }

    void Update()
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

    public void StartGame()
    {
        State = GameState.Playing;
    }

    public void Win()
    {
        State = GameState.Win;
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
}
