using UnityEngine;

public enum MonsterState {Idle, Move, Attack, Die}
public class Monster : BaseUnit
{
    public MonsterData data;

    public float moveSpeed;

    // Like (9, 5) mean object ca ben go max (9, 5) and min (-9, -5)
    public Vector2 rangeAreMove;

    public MonsterState state;

    private GameObject target;
    private BaseUnit targetAsUnit;

    protected override void Start()
    {
        Setup();
        base.Start();
    }

    void FixedUpdate()
    {
        // Cập nhật vận tốc trong FixedUpdate để đồng bộ với hệ thống vật lý
        if (state == MonsterState.Move)
        {
            Move();
        }
        if (state == MonsterState.Attack && target != null && targetAsUnit is Defender)
        {
            Attack(targetAsUnit);
        }

        // Kiểm tra giới hạn
        CheckBounds();
    }

    // Hủy đối tượng khi nó ra khỏi giới hạn (min/max):
    void CheckBounds()
    {
        Vector3 pos = transform.position;

        if (Mathf.Abs(pos.x) > Mathf.Abs(rangeAreMove.x) ||
            Mathf.Abs(pos.y) > Mathf.Abs(rangeAreMove.y))
        {
            Die();
        }
    }

    void Move()
    {
        rb.velocity = Vector3.right * moveSpeed;
    }

    public void Attack(BaseUnit target)
    {
        attackTimer += Time.deltaTime;
        if (attackTimer >= 1f / attackSpeed)
        {
            target.TakeDamage(attack);
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
        moveSpeed = data.moveSpeed;
        
        state = MonsterState.Move;
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        Debug.Log(collision.name);

        if (collision.gameObject.CompareTag(TagConfigs.DefenderTag))
        {
            state = MonsterState.Attack;

            rb.velocity = Vector3.zero;

            target = collision.gameObject;
            targetAsUnit = target.GetComponent<Defender>();
        }
    }

    void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag(TagConfigs.DefenderTag))
        {
            state = MonsterState.Move;

            target = null;
            targetAsUnit = null;
        }
    }
}
