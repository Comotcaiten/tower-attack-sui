using System.Collections;
using UnityEngine;

/// <summary>
/// Example script showing how to integrate blockchain with existing GameManager
/// Add this component alongside SuiWalletConnector
/// </summary>
public class BlockchainGameIntegration : MonoBehaviour
{
    [Header("UI References")]
    public GameObject walletConnectPanel;
    public UnityEngine.UI.Text statusText;
    public UnityEngine.UI.Button connectButton;

    private bool isBlockchainReady = false;

    void Start()
    {
        // Show wallet connect screen first
        if (walletConnectPanel != null)
        {
            walletConnectPanel.SetActive(true);
        }

        // Setup connect button
        if (connectButton != null)
        {
            connectButton.onClick.AddListener(OnConnectButtonClicked);
        }

        UpdateStatusText("Please connect your Slush Wallet to start playing");
    }

    void Update()
    {
        // Monitor wallet connection status
        if (SuiWalletConnector.Instance != null)
        {
            if (SuiWalletConnector.Instance.isConnected && !isBlockchainReady)
            {
                OnWalletConnectedSuccess();
            }
        }
    }

    void OnConnectButtonClicked()
    {
        if (SuiWalletConnector.Instance != null)
        {
            SuiWalletConnector.Instance.Connect();
            UpdateStatusText("Waiting for wallet approval...");
        }
        else
        {
            Debug.LogError("SuiWalletConnector not found in scene!");
            UpdateStatusText("Error: Wallet connector not found");
        }
    }

    void OnWalletConnectedSuccess()
    {
        UpdateStatusText("Wallet connected! Creating game session...");
        
        // Create blockchain game session
        if (SuiWalletConnector.Instance != null)
        {
            SuiWalletConnector.Instance.CreateGameSession();
        }

        // Wait for session to be created
        StartCoroutine(WaitForGameSession());
    }

    IEnumerator WaitForGameSession()
    {
        // Wait for blockchain session ID
        float timeout = 30f;
        float elapsed = 0f;

        while (string.IsNullOrEmpty(SuiWalletConnector.Instance.currentGameSessionId) && elapsed < timeout)
        {
            elapsed += Time.deltaTime;
            yield return null;
        }

        if (!string.IsNullOrEmpty(SuiWalletConnector.Instance.currentGameSessionId))
        {
            isBlockchainReady = true;
            
            if (walletConnectPanel != null)
            {
                walletConnectPanel.SetActive(false);
            }

            // Now start the actual game
            if (GameManager.Instance != null)
            {
                GameManager.Instance.OnBlockchainSessionReady();
            }

            UpdateStatusText("Ready to play!");
        }
        else
        {
            UpdateStatusText("Failed to create game session. Please try again.");
            Debug.LogError("Timeout waiting for game session creation");
        }
    }

    void UpdateStatusText(string message)
    {
        if (statusText != null)
        {
            statusText.text = message;
        }
        Debug.Log($"[Blockchain] {message}");
    }

    void OnApplicationQuit()
    {
        // Clean up game session when quitting
        if (isBlockchainReady && SuiWalletConnector.Instance != null)
        {
            SuiWalletConnector.Instance.EndGame();
        }
    }
}
