using UnityEngine;
[CreateAssetMenu(menuName = "Data/Monster")]
public class MonsterData : ScriptableObject
{
    public string monsterName;
    // public MonsterType type;

    public int level;
    public int energyCost;

    public float maxHP;
    public float attack;
    public float attackSpeed;
    public float moveSpeed;

    public bool hasPassive;
}
