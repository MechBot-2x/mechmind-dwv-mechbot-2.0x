# En token-manager.sh, reemplaza la función rotate_jwt con esta versión corregida:
rotate_jwt() {
    NEW_JWT=$(openssl rand -base64 32 | tr -d '\n')
    # Codificar correctamente en base64
    ENCODED_JWT=$(echo -n "$NEW_JWT" | base64 | tr -d '\n')
    
    kubectl patch secret mechbot-secrets -n mechbot-prod \
        --type='json' -p="[{\"op\":\"replace\",\"path\":\"/data/jwt-secret\",\"value\":\"$ENCODED_JWT\"}]"
    
    echo "✅ JWT Secret rotado"
}
