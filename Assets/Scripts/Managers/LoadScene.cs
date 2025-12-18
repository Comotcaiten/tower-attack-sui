using UnityEngine;
using System.Runtime.InteropServices;
using UnityEngine.SceneManagement;
using TMPro;

// Lớp để giải mã JSON từ Bridge
[System.Serializable]
public class WalletData
{
    public string wallet;
    public string address;
    public string chain;
}

public class LoadScene : MonoBehaviour
{
    public TextMeshProUGUI statusText;

    [DllImport("__Internal")]
    private static extern void ConnectWalletJS(string preferredWallet);

    [DllImport("__Internal")]
    private static extern void DisconnectWalletJS(); // Khai báo thêm hàm disconnect

    [DllImport("__Internal")]
    private static extern void SetBridgeConfig(string chain, string unityObjectName);

    [DllImport("__Internal")]
    private static extern void TryReconnectJS(string preferredWallet); // Hàm tự động kết nối lại

    void Start()
    {
        #if UNITY_WEBGL && !UNITY_EDITOR
            SetBridgeConfig("sui:mainnet", "LoadScene");
            // Tự động kiểm tra xem ví đã connect trước đó chưa
            TryReconnectJS("slush"); 
        #endif
    }

    public void ConnectWallet()
    {
        #if UNITY_WEBGL && !UNITY_EDITOR
            ConnectWalletJS("slush");
        #else
            Debug.Log("Sui Wallet chỉ hoạt động trên bản Build WebGL");
        #endif
    }

    // Hàm gắn vào Button Disconnect
    public void DisconnectWallet()
    {
        #if UNITY_WEBGL && !UNITY_EDITOR
            DisconnectWalletJS();
        #endif
    }

    // --- CÁC HÀM NHẬN DỮ LIỆU ---

    public void OnWalletConnected(string jsonResponse)
    {
        // Giải mã JSON để lấy địa chỉ ví
        WalletData data = JsonUtility.FromJson<WalletData>(jsonResponse);
        string fullAddress = data.address;

        Debug.Log("Đã kết nối ví: " + fullAddress);

        if (statusText != null) 
        {
            // Hiển thị rút gọn: 0x1234...abcd
            statusText.text = fullAddress.Substring(0, 6) + "..." + fullAddress.Substring(fullAddress.Length - 4);
        }
        
        // Nếu muốn tự động vào game:
        // Invoke("StartGame", 1.5f);
    }

    public void OnWalletDisconnected(string json)
    {
        Debug.Log("Ví đã ngắt kết nối");
        if (statusText != null) statusText.text = "Disconnected";
    }

    public void OnWalletError(string errorMessage)
    {
        Debug.LogError("Lỗi ví: " + errorMessage);
        if (statusText != null) statusText.text = "Error: " + errorMessage;
    }

    public void StartGame() { SceneManager.LoadScene("PlayGame"); }
}