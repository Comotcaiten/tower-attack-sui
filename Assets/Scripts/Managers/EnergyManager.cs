using UnityEngine;

public class EnergyManager : MonoBehaviour
{
    public int maxEnergy = 10;
    public float regenRate = 2f;

    public int CurrentEnergy { get; private set; }

    void Start()
    {
        CurrentEnergy = maxEnergy;
        InvokeRepeating(nameof(RegenEnergy), 1f, 1f);
    }

    void RegenEnergy()
    {
        CurrentEnergy = Mathf.Min(maxEnergy, CurrentEnergy + 1);
    }

    public bool CanSpend(int cost)
    {
        return CurrentEnergy >= cost;
    }

    public void Spend(int cost)
    {
        CurrentEnergy -= cost;
        // Đảm bảo năng lượng không âm, lấy giá trị lớn nhất giữa 0 và CurrentEnergy
        CurrentEnergy = Mathf.Max(0, CurrentEnergy);
    }
}
