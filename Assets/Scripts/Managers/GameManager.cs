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

    void Awake()
    {
        Instance = this;
        State = GameState.Preparing;
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
