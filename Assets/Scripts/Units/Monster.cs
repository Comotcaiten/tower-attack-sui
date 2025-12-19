using UnityEngine;

public enum MonsterState { Idle, Move, Attack, Die, End }
public class Monster : BaseUnit
{
    public MonsterData data;

    public float moveSpeed;

    // Like (9, 5) mean object ca ben go max (9, 5) and min (-9, -5)
    public Vector2 rangeAreMove = new Vector2(9, 5);

    public MonsterState state;

    private GameObject target;
    private BaseUnit targetAsUnit;

    private SensorRayMonster sensor;

    protected override void Start()
    {
        Setup();
        base.Start();
    }

    void Update()
    {
        if (state == MonsterState.End)
        {
            return;
        }
        else if (GameManager.Instance!.State == GameState.Win || GameManager.Instance!.State == GameState.Lose)
        {
            FreezeMove();
            gameObject.SetActive(false);
            state = MonsterState.End;
            return;
        }

        sensor.Cast();

        if (state != MonsterState.Attack &&
            sensor.HasDetectedHit() &&
            sensor.GetComponent<Defender>() != null &&
            sensor.GetComponent<Defender>() is Defender
        )
        {
            state = MonsterState.Attack;
            target = sensor.GetHitObject();
            targetAsUnit = sensor.GetComponent<Defender>();
            FreezeMove();
        }
        else if (state != MonsterState.Move && !sensor.HasDetectedHit())
        {
            state = MonsterState.Move;
            target = null;
            targetAsUnit = null;
            UnFreeze();
        }
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
            rb.velocity = Vector3.zero;

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

        sensor = new SensorRayMonster(this.transform);
    }

    void FreezeMove()
    {
        rb.constraints = RigidbodyConstraints2D.FreezeAll;
        rb.velocity = Vector3.zero;
    }

    void UnFreeze()
    {
        rb.constraints = RigidbodyConstraints2D.FreezePositionY;
        rb.freezeRotation = true;
    }
}
