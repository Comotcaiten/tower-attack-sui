using UnityEngine;
public abstract class BaseUnit : MonoBehaviour
{
    [Header("Object Setup")]
    public SpriteRenderer rendRootModel;
    public Rigidbody2D rb;
    public GameObject rootItem;

    [Header("Attribute Setup")]
    public float maxHP;
    public float currentHP;
    public float attack;
    public float attackSpeed;
    public float shield;

    protected float attackTimer;

    protected virtual void Start()
    {
        currentHP = maxHP;
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

    protected virtual void SetHp(float newHp)
    {
        if (newHp < 0)
        {
            return;
        }
        currentHP = newHp;
        if (currentHP <= 0)
            Die();
    }

    protected virtual void Die()
    {
        Destroy(gameObject);
    }
}
