using UnityEngine;
public enum ItemType { Weapon, Armor }

[CreateAssetMenu(menuName = "Data/Item")]
public class ItemData : ScriptableObject
{
    public ItemType type;
    public float attackBonus;
    public float hpBonus;
    public float defenseBonus;
}
