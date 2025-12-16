using UnityEngine;
public class Defender : BaseUnit
{
    public DefenderData data;

    protected override void Start()
    {
        Setup();
        base.Start();
    }

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

    void Setup()
    {
        rendRootModel.sprite = data.sprite;

        maxHP = data.maxHP;
        attack = data.attack;
        attackSpeed = data.attackSpeed;
        shield = data.shield;
    }
}
