mergeInto(LibraryManager.library, {
    SetBridgeConfig: function(chain, objName) {
        window.SlushBridge.setConfig({
            chain: UTF8ToString(chain),
            unityObjectName: UTF8ToString(objName)
        });
    },
    ConnectWalletJS: function(walletName) {
        window.SlushBridge.connect(UTF8ToString(walletName));
    },
    DisconnectWalletJS: function() {
        window.SlushBridge.disconnect();
    },
    TryReconnectJS: function(walletName) {
        window.SlushBridge.tryReconnect(UTF8ToString(walletName));
    }
});