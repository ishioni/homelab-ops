{
  "$schema": "https://raw.githubusercontent.com/Ylianst/MeshCentral/master/meshcentral-config-schema.json",
  "settings": {
    "plugins":{"enabled": false},
    "_mongoDb": null,
    "cert": "${HOSTNAME}",
    "_WANonly": true,
    "_LANonly": true,
    "_sessionKey": "{{ .SESSION_KEY }}",
    "port": ${PORT},
    "_aliasPort": 443,
    "redirPort": 80,
    "_redirAliasPort": 80,
    "AgentPong": 300,
    "TLSOffload": ${TLS_OFFLOAD},
    "SelfUpdate": false,
    "AllowFraming": false,
    "WebRTC": ${WEBRTC},
    "NewAccounts": ${NEWACCOUNTS}
  },
  "domains": {
    "": {
      "_title": "MyServer",
      "_title2": "Servername",
      "minify": true,
      "NewAccounts": false,
      "localSessionRecording": false,
      "_userNameIsEmail": true,
      "_certUrl": "${HOSTNAME}"
    }
  }
}
