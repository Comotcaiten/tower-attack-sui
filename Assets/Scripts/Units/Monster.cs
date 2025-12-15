using UnityEngine;
public class Monster : BaseUnit
{
    public MonsterData data;
    public SpriteRenderer rendRootModel;
    // public Lane currentLane;

    public Rigidbody2D rb;
    private float attackTimer;

    // Like (9, 5) mean object ca ben go max (9, 5) and min (-9, -5)
    public Vector2 rangeAreMove;

    public GameObject rootItem;
    public float rotateSpeed = 30f; // Điều chỉnh tốc độ
    protected override void Start()
    {
        base.Start();

        Setup();
    }

    void FixedUpdate()
    {
        // Cập nhật vận tốc trong FixedUpdate để đồng bộ với hệ thống vật lý
        Move();
        ActivityItem();

        // Kiểm tra giới hạn cũng nên ở đây nếu bạn muốn nó gắn liền với logic vật lý
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
        rb.velocity = Vector3.right * data.moveSpeed;
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

    // Đặt trong Update()
    void ActivityItem()
    {
        // Xoay quanh trục Z 30 độ mỗi giây
        rootItem.transform.Rotate(0f, 0f, rotateSpeed * Time.deltaTime);
    }

    void Setup()
    {
        rendRootModel.sprite = data.sprite;
    }
}
