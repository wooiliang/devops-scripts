#!/bin/bash

# Define the keyword to search for
keyword="keyword"

# List all namespaces in the EKS cluster
namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Loop through each namespace
for namespace in $namespaces; do
    echo "Checking secrets in namespace: $namespace"
    
    # List all secrets in the current namespace
    secrets=$(kubectl get secrets -n $namespace -o jsonpath='{.items[*].metadata.name}')
    
    # Loop through each secret
    for secret in $secrets; do
        # Get the entire secret data
        secret_data=$(kubectl get secret $secret -n $namespace -o jsonpath='{.data}')
        
        # Loop through each key in the secret data
        for key in $(echo "$secret_data" | jq -r 'keys[]'); do
            # Decode the base64-encoded value for the current key
            decoded_value=$(echo "$secret_data" | jq -r ".[\"$key\"]" | base64 -d)
            
            # Check if the keyword exists in the decoded value
            if echo "$decoded_value" | grep -q "$keyword"; then
                echo "Secret '$secret' in namespace '$namespace' contains the keyword in key '$key'."
            fi
        done
    done
done
