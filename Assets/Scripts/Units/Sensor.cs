using UnityEngine;

public class SensorRay
{
    public float CastLength { get; set; } = 10f;
    public LayerMask Layermask { get; set; } = 255;
    
    private Vector2 origin = Vector2.zero;
    private Transform tr;
    private Vector2 direction = Vector2.left;
    private RaycastHit2D hit2D; // Sử dụng bản 2D
    ContactFilter2D filter;

    public SensorRay(Transform _tr)
    {
        tr = _tr;
        
        // Tạo bộ lọc
        filter = new ContactFilter2D();
        filter.useTriggers = false; // Bỏ qua tất cả Trigger
        filter.SetLayerMask(Layermask); // Chỉ định Layer
        filter.useLayerMask = true;
    }

    public void Cast()
    {
        Vector2 worldOrigin = tr.TransformPoint(origin);
        Vector2 worldDirection = tr.TransformDirection(direction);

        // Sử dụng Raycast trả về danh sách kết quả (RaycastHit2D[])
        RaycastHit2D[] results = new RaycastHit2D[5];
        int hitCount = Physics2D.Raycast(worldOrigin, worldDirection, filter, results, CastLength);

        for (int i = 0; i < hitCount; i++)
        {
            // Kiểm tra Tag để bỏ qua
            if (results[i].collider.CompareTag(TagConfigs.DefenderTag)) continue;

            // Nếu không phải tag cần bỏ qua, đây chính là đối tượng ta cần
            if (results[i].collider.CompareTag(TagConfigs.MonsterTag))
            {
                hit2D = results[i];
                break;
            }
        }

        // Vẽ Debug để bạn dễ quan sát trong Scene view
        Debug.DrawRay(worldOrigin, worldDirection * CastLength, HasDetectedHit() ? Color.green : Color.red);
    }

    public bool HasDetectedHit() => hit2D.collider != null;

    // Lấy thông tin Object va chạm (thay thế cho OnTriggerEnter)
    public GameObject GetHitObject() => hit2D.collider != null ? hit2D.collider.gameObject : null;
    
    public T GetComponent<T>() where T : Component 
    {
        return hit2D.collider != null ? hit2D.collider.GetComponent<T>() : null;
    }
}


public class SensorRayMonster
{
    public float CastLength { get; set; } = 1f;
    public LayerMask Layermask { get; set; } = 255;
    
    private Vector2 origin = Vector2.zero;
    private Transform tr;
    private Vector2 direction = Vector2.right;
    private RaycastHit2D hit2D; // Sử dụng bản 2D
    ContactFilter2D filter;

    public SensorRayMonster(Transform _tr)
    {
        tr = _tr;
        Layermask = LayerMask.GetMask(LayerConfigs.DefenderLayer);

        // Tạo bộ lọc
        filter = new ContactFilter2D();
        filter.useTriggers = false; // Bỏ qua tất cả Trigger
        filter.SetLayerMask(Layermask); // Chỉ định Layer
        filter.useLayerMask = true;
    }

    public void Cast()
    {
        // 1. QUAN TRỌNG: Reset hit2D mỗi lần Cast
        hit2D = default; 

        Vector2 worldOrigin = tr.TransformPoint(origin);
        Vector2 worldDirection = tr.TransformDirection(direction);

        // 2. addPos nên tính toán dựa trên hướng nhìn, ở đây tôi dùng 0.5f thay vì 5f
        Vector2 castStartPoint = worldOrigin + (worldDirection * 0.5f);

        RaycastHit2D[] results = new RaycastHit2D[5];
        
        // Lưu ý: filter.useTriggers = false sẽ bỏ qua các Collider là Trigger
        int hitCount = Physics2D.Raycast(castStartPoint, worldDirection, filter, results, CastLength);

        for (int i = 0; i < hitCount; i++)
        {
            // Bỏ qua chính bản thân Monster
            if (results[i].collider.CompareTag(TagConfigs.MonsterTag)) continue;

            if (results[i].collider.CompareTag(TagConfigs.DefenderTag))
            {
                hit2D = results[i];
                break; // Tìm thấy rồi thì dừng vòng lặp
            }
        }

        // 3. Debug DrawRay: Vẽ từ điểm bắt đầu Cast thực tế để kiểm tra vị trí
        Debug.DrawRay(castStartPoint, worldDirection * CastLength, HasDetectedHit() ? Color.green : Color.red);
    }

    public bool HasDetectedHit() => hit2D.collider != null;

    // Lấy thông tin Object va chạm (thay thế cho OnTriggerEnter)
    public GameObject GetHitObject() => hit2D.collider != null ? hit2D.collider.gameObject : null;
    
    public T GetComponent<T>() where T : Component 
    {
        return hit2D.collider != null ? hit2D.collider.GetComponent<T>() : null;
    }
}