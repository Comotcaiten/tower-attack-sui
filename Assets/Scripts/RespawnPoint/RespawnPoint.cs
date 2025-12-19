using UnityEngine;

public enum RespawnState {Disable, Active, End}
public class RespawnPoint : MonoBehaviour
{
    [SerializeField] public Defender defender;
    [SerializeField] public GameObject defenderObj;

    public float timeRemain = 10f;
    public float timer = 0f;

    public RespawnState state = RespawnState.Active;

    void Start()
    {
        Spawn();
    }
    void Update()
    {

        if (state == RespawnState.End)
        {
            return;
        }
        else if (GameManager.Instance!.State == GameState.Win || GameManager.Instance!.State == GameState.Lose)
        {
            gameObject.SetActive(false);
            defenderObj.SetActive(false);
            state = RespawnState.End;
            return;
        }

        if (state == RespawnState.Disable)
        {
            timer += Time.deltaTime;

            if (timer >= timeRemain)
            {
                state = RespawnState.Active;
                timer = 0f;

                Spawn();
            }
        }
        else if (state == RespawnState.Active && defender != null && defender.isActiveAndEnabled && defender.currentHP <= 0)
        {
            state = RespawnState.Disable;
            defenderObj.SetActive(false);
        }
        
    }

    void FixedUpdate()
    {
        
    }

    public void Spawn()
    {
        defenderObj.SetActive(true);
        defender = defenderObj.GetComponent<Defender>();
        defender!.Setup();
    }
}