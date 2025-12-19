mergeInto(LibraryManager.library, {
    SetBridgeConfig: function(chain, objName) {
        var chainStr = UTF8ToString(chain);
        var objNameStr = UTF8ToString(objName);
        
        // Kiểm tra an toàn trước khi gọi
        if (window.SlushBridge && window.SlushBridge.setConfig) {
            window.SlushBridge.setConfig({
                chain: chainStr,
                unityObjectName: objNameStr
            });
        } else {
            console.warn("SlushBridge chưa sẵn sàng, đang thử lại...");
            // Thử lại sau 500ms nếu chưa thấy SlushBridge
            setTimeout(function() {
                if (window.SlushBridge) window.SlushBridge.setConfig({chain: chainStr, unityObjectName: objNameStr});
            }, 500);
        }
    },
    
    ConnectWalletJS: function(walletName) {
        if (window.SlushBridge && window.SlushBridge.connect) {
            window.SlushBridge.connect(UTF8ToString(walletName));
        } else {
            alert("Bridge chưa được tải, vui lòng tải lại trang!");
        }
    }
});