using UnityEngine;
public class Defender : BaseUnit
{
    public DefenderData data;
    public Sensor sensor;
    public GameObject bulletPrefab;

    protected override void Start()
    {
        Setup();
        base.Start();
    }

    void Update()
    {
        if (sensor!.IsDetect)
        {
            attackTimer += Time.deltaTime;
            Attack(sensor!.MonsterUnit);
        }
    }

    public void Attack(Monster monster)
    {
        // if (attackTimer >= 1f / attackSpeed)
        // {
        //     monster.TakeDamage(attack);
        //     attackTimer = 0;
        // }

        if (monster == null)
        {
            return;
        }
        if (attackTimer >= attackSpeed)
        {
            GameObject go = Instantiate(bulletPrefab, this.transform.position, Quaternion.identity);
            var bullets = go.GetComponent<Bullets>() as Bullets;
            bullets.ower = this;

            bullets.rb.velocity = Vector3.left * 5f;

            // Physics2D.IgnoreCollision()

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
