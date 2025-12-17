using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tower : MonoBehaviour
{
    [SerializeField] private Rigidbody2D rb;
    [SerializeField] private SpriteRenderer rend;

    public float maxHp = 10000f;
    public float currentHP;
    public float shield = 500f;
    public float attack = 9999999999999999999f;

    // Start is called before the first frame update
    void Start()
    {
        Setup();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void Setup()
    {
        rb = GetComponent<Rigidbody2D>();
        currentHP = maxHp;
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision && collision.gameObject.CompareTag(TagConfigs.MonsterTag))
        {
            Monster mon = collision.gameObject.GetComponent<Monster>();
            TakeDamage(mon.attack);
            mon.TakeDamage(attack);
        }
    }


    public virtual void TakeDamage(float damage)
    {
        float defense = Mathf.Max(0, shield);
        float denominator = damage + defense;
        float finalDamage = 1f;

        if (denominator > 0f)
        {
            // Tính hệ số giảm sát thương dựa trên tỉ lệ:
            // Nếu Attack = 50, Shield = 50 => Hệ số = 50 / 100 = 0.5 (giảm 50% sát thương)
            // Nếu Attack = 100, Shield = 0 => Hệ số = 100 / 100 = 1.0 (không giảm)
            // Nếu Attack = 10, Shield = 90 => Hệ số = 10 / 100 = 0.1 (giảm 90% sát thương)

            float damageMultiplier = damage / denominator;
            // Sát thương thực tế phải nhận
            finalDamage = damage * damageMultiplier;
        }
        else
        {
            // Trường hợp cả Attack và Shield đều bằng 0, sát thương bằng 0.
            finalDamage = 1f;
        }

        currentHP -= finalDamage;
        currentHP = Mathf.Max(currentHP, 0f);
        if (currentHP <= 0)
        {
            Die();
        }
    }

    protected void Die()
    {
        Destroy(gameObject);
    }
}
