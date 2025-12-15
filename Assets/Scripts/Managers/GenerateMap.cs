using UnityEngine;

public class GenerateMap : MonoBehaviour
{
    public int laneCount = 5;
    public int laneLength = 15;

    public float tileSize = 1f; // nếu sprite 32px = 1 unit
    public Vector2 mapOrigin = Vector2.zero; // góc trái dưới tile (0,0)

    // Lấy vị trí spawn cho lane
    public Vector3 GetSpawnPosition(int laneIndex)
    {
        float x = mapOrigin.x - tileSize * 2; // ngoài map
        float y = mapOrigin.y + laneIndex * tileSize + tileSize / 2f;
        return new Vector3(x, y, 0);
    }

    // Lấy vị trí base (đích đến)
    public Vector3 GetEndPosition(int laneIndex)
    {
        float x = mapOrigin.x + laneLength * tileSize;
        float y = mapOrigin.y + laneIndex * tileSize + tileSize / 2f;
        return new Vector3(x, y, 0);
    }
}
