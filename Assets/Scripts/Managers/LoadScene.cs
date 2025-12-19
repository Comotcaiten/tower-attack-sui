using UnityEngine;
using System.Runtime.InteropServices;
using UnityEngine.SceneManagement;
using TMPro;

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
    private static extern void SetBridgeConfig(string chain, string unityObjectName);

    void Start()
    {
        // Đặt cấu hình tên đối tượng nhận tin nhắn là chính nó (LoadScene)
        #if UNITY_WEBGL && !UNITY_EDITOR
            SetBridgeConfig("sui:mainnet", gameObject.name); 
        #endif
    }

    // --- 1. NÚT CONNECT WALLET ---
    public void ConnectWallet()
    {
        #if UNITY_WEBGL && !UNITY_EDITOR
            ConnectWalletJS("slush");
        #else
            Debug.Log("Mở ví Slush (Chỉ hoạt động trên WebGL)");
        #endif
    }

    // --- 2. NÚT START ---
    public void StartGame()
    {
        // Chuyển sang Scene chơi game của bạn
        SceneManager.LoadScene("PlayGame");
    }

    // --- 3. NÚT QUIT ---
    public void QuitGame()
    {
        #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
        #else
            Application.Quit();
        #endif
    }

    // Hàm nhận dữ liệu khi ví kết nối thành công
    public void OnWalletConnected(string jsonResponse)
    {
        WalletData data = JsonUtility.FromJson<WalletData>(jsonResponse);
        if (statusText != null) 
        {
            statusText.text = "Connected: " + data.address.Substring(0, 6) + "..." + data.address.Substring(data.address.Length - 4);
        }
    }

    public void OnWalletError(string errorMessage)
    {
        if (statusText != null) statusText.text = "Error: " + errorMessage;
    }
}