using UnityEngine;

public class LaneManager : MonoBehaviour
{
    public int width = 15;   // X: 1 → 15
    public int height = 5;   // Y: 1 → 5

    public Sprite[] tiles;   // 2 sprite so le

    void Start()
    {
        GenerateMap();
    }

    void GenerateMap()
    {
        for (int y = 1; y <= height; y++)
        {
            Sprite laneSprite = (y % 2 == 1) ? tiles[0] : tiles[1];

            for (int x = 1; x <= width; x++)
            {
                CreateTile(x, y, laneSprite);
            }
        }
    }

    void CreateTile(int x, int y, Sprite sprite)
    {
        GameObject tile = new GameObject($"Tile_{x}_{y}");
        tile.transform.parent = transform;

        // ✅ TOẠ ĐỘ NGUYÊN
        tile.transform.position = new Vector3(x, y, 0);

        var sr = tile.AddComponent<SpriteRenderer>();
        sr.sprite = sprite;
        sr.sortingOrder = 0;
    }

    // 🔥 Spawn quái CHUẨN LANE
    public Vector3 GetTilePosition(int x, int y)
    {
        return new Vector3(x, y, 0);
    }
}
