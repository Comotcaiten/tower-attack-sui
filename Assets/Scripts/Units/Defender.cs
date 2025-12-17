using UnityEngine;
public class Defender : BaseUnit
{
    public DefenderData data;
    public SensorRay sensor;
    public GameObject bulletPrefab;

    protected override void Start()
    {
        Setup();
    }

    void Update()
    {
        sensor.Cast();
        if (sensor.HasDetectedHit())
        {
            attackTimer += Time.deltaTime;
            Attack(sensor!.GetComponent<Monster>());
        }
    }

    public void Attack(Monster monster)
    {

        if (monster == null)
        {
            return;
        }
        if (attackTimer >= attackSpeed)
        {
            GameObject go = Instantiate(bulletPrefab, this.transform.position, Quaternion.identity);
            var bullets = go.GetComponent<Bullets>() as Bullets;
            bullets.ower = this;
            // bullets.rb.velocity = Vector3.left * 5f;

            attackTimer = 0;
        }
        
    }

    protected override void Die()
    {
        
    }

    public void Setup()
    {
        rendRootModel.sprite = data.sprite;

        maxHP = data.maxHP;
        currentHP = maxHP;
        attack = data.attack;
        attackSpeed = data.attackSpeed;
        shield = data.shield;

        sensor = new SensorRay(this.transform);
    }
}
