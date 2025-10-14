#!/bin/bash
# scripts/security/final-verification.sh

echo "=== MECHBOT 2.0X FINAL VERIFICATION ==="

# Check cluster connectivity
if kubectl cluster-info &>/dev/null; then
    echo "✅ Kubernetes cluster accessible"
else
    echo "❌ Cannot connect to cluster"
    exit 1
fi

# Verify namespace exists
if kubectl get namespace mechbot-prod &>/dev/null; then
    echo "✅ mechbot-prod namespace exists"
else
    echo "⚠️  mechbot-prod namespace missing - creating now"
    kubectl create namespace mechbot-prod
fi

# Verify DNS is working
if kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default &>/dev/null; then
    echo "✅ DNS resolution working"
else
    echo "❌ DNS issues detected"
fi

# Run security audit
./scripts/security/audit.sh

echo "=== VERIFICATION COMPLETE ==="
