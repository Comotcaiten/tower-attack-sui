using UnityEngine;
public class Defender : BaseUnit
{
    public float attack;
    public float attackSpeed;

    private float attackTimer;

    void Update()
    {
        attackTimer += Time.deltaTime;
    }

    public void Attack(Monster monster)
    {
        if (attackTimer >= 1f / attackSpeed)
        {
            monster.TakeDamage(attack);
            attackTimer = 0;
        }
    }
}
