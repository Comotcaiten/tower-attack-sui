using UnityEngine;
public abstract class BaseUnit : MonoBehaviour
{
    public float MaxHP;
    public float CurrentHP;

    protected virtual void Start()
    {
        CurrentHP = MaxHP;
    }

    public virtual void TakeDamage(float damage)
    {
        CurrentHP -= damage;
        if (CurrentHP <= 0)
            Die();
    }

    protected virtual void Die()
    {
        Destroy(gameObject);
    }
}
