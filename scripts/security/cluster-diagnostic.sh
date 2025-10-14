#!/bin/bash
# scripts/security/cluster-diagnostic.sh

echo "=== MECHBOT CLUSTER DIAGNOSTIC ==="

# 1. Check cluster status
echo "1. Cluster Status:"
kubectl cluster-info
kubectl get nodes

# 2. Check system components
echo -e "\n2. System Components:"
kubectl get pods -n kube-system

# 3. Check DNS functionality
echo -e "\n3. DNS Check:"
kubectl get svc -n kube-system kube-dns

# 4. Check RBAC permissions
echo -e "\n4. RBAC Check:"
kubectl auth can-i get pods --as=system:anonymous

# 5. Check existing namespaces
echo -e "\n5. Existing Namespaces:"
kubectl get namespaces

echo -e "\n=== DIAGNOSTIC COMPLETE ==="
