using UnityEngine;
public class Monster : BaseUnit
{
    public MonsterData data;
    public Lane currentLane;

    private float attackTimer;

    void Update()
    {
        if (GameManager.Instance.State != GameState.Playing)
            return;

        Move();
    }

    void Move()
    {
        transform.Translate(Vector2.right * data.moveSpeed * Time.deltaTime);
    }

    public void Attack(BaseUnit target)
    {
        attackTimer += Time.deltaTime;
        if (attackTimer >= 1f / data.attackSpeed)
        {
            target.TakeDamage(data.attack);
            attackTimer = 0;
        }
    }
}
