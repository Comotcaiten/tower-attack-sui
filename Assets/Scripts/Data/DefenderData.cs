using UnityEngine;
[CreateAssetMenu(menuName = "Data/Defender")]
public class DefenderData : ScriptableObject
{
    public string defenderName;
    public Sprite sprite;
    public int level;
    public float maxHP;
    public float attack;
    public float shield;
    public float attackSpeed;
    public bool hasPassive;
}
