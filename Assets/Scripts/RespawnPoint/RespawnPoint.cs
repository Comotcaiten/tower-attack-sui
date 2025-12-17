using UnityEngine;

public enum RespawnState {Disable, Active}
public class RespawnPoint : MonoBehaviour
{
    [SerializeField] public Defender defender;
    [SerializeField] public GameObject defenderObj;

    public float timeRemain = 10f;
    public float timer = 0f;

    public RespawnState state = RespawnState.Active;

    void Start()
    {
        // Spawn();

        // if (defenderObj.)

        Spawn();
    }
    void Update()
    {
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