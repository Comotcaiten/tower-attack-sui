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
        if (Input.GetKeyDown(KeyCode.A))
        {
            if (datas.Count <= 0)
            {
                Debug.Log("GameManager > Datas > [Null-0x00000000]: Dont have any data to spawn");
                return;
            }
            Debug.Log("Spawn Monster:" + datas[0]);
            spawnManager.SpawnMonster(datas[0]);
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
}
