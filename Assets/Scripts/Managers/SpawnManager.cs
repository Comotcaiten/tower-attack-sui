using UnityEngine;
public class SpawnManager : MonoBehaviour
{
    public Transform spawnPoint;
    public EnergyManager energyManager;

    public GameObject prefab;

    public void SpawnMonster(MonsterData data, Vector3 spawnPoints) //Lane lane)
    {
        if (!energyManager.CanSpend(data.energyCost))
        {
            Debug.Log("Can be spawn monster because this monster need more energy than storage energy");
            return;
        }

        energyManager.Spend(data.energyCost);
        GameObject go = Instantiate(prefab, spawnPoints, Quaternion.identity);
        Monster monster = go.GetComponent<Monster>();
        monster.data = data;;
    }
}
