using UnityEngine;
using UnityEngine.UI; // Bắt buộc phải có để dùng Image
using TMPro;

public class EnergyDisplay : MonoBehaviour
{
    [Header("References")]
    public EnergyManager energyManager; 
    public Image energyFillImage;  // Kéo đối tượng "Energy" (màu xanh) vào đây
    public TextMeshProUGUI energyText;

    void Update()
    {
        if (energyManager == null) return;

        // Tính toán tỷ lệ phần trăm (từ 0.0 đến 1.0)
        float fillValue = (float)energyManager.CurrentEnergy / energyManager.maxEnergy;

        // Cập nhật thanh năng lượng tự co lại
        if (energyFillImage != null)
        {
            energyFillImage.fillAmount = fillValue;
        }

        // Cập nhật chữ hiển thị
        if (energyText != null)
        {
            energyText.text = $"{energyManager.CurrentEnergy}/{energyManager.maxEnergy}";
        }
    }
}