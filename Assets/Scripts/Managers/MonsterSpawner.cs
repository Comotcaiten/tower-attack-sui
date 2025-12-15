using UnityEngine;
using UnityEngine.Tilemaps;

public class MonsterSpawner : MonoBehaviour
{
    public Tilemap tilemap;
    public GameObject enemyPrefab;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            SpawnAtMouse();
        }
    }

    void SpawnAtMouse()
    {
        Vector3 worldPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        worldPos.z = 0;

        // 🔑 Convert world → cell
        Vector3Int cellPos = tilemap.WorldToCell(worldPos);

        // ❌ Không có tile thì không spawn
        if (!tilemap.HasTile(cellPos))
        {
            Debug.Log("No tile at this position. Cannot spawn enemy.");
            return;
        }

        // 🔑 Snap về tâm ô
        Vector3 spawnPos = tilemap.GetCellCenterWorld(cellPos);

        Instantiate(enemyPrefab, spawnPos, Quaternion.identity);
    }
}
