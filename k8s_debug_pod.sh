#!/bin/bash

# Spins up a debug namespace and pod to run commands in.
#
# Usage: ./k8s_debug_pod.sh <image-name> <your-namespace-name> <your-pod-name>

# Enable debugging
#set -x

# Main function
main() {
    local image=$1
    local namespace=$2
    local pod=$3

    if [[ -z "$image" || -z "$namespace" || -z "$pod" ]]; then
        echo "Usage: $0 <image-name> <your-namespace-name> <your-pod-name>"
        exit 1
    fi

    echo "Creating namespace '$namespace' to run Pod ..."
    if ! kubectl create namespace "$namespace" 2>/dev/null; then
        echo "Namespace '$namespace' already exists or failed to create."
    fi

    echo "Launching pod '$pod' in namespace '$namespace' ..."
    if ! kubectl run "$pod" --image="$image" --restart=Never -n "$namespace" -- sleep 3600; then
        echo "Failed to launch pod. Exiting."
        exit 1
    fi

    echo "Waiting for pod '$pod' to be ready ..."
    if ! kubectl wait --for=condition=Ready pod/"$pod" -n "$namespace" --timeout=60s; then
        echo "Pod '$pod' is not ready. Exiting."
        kubectl delete pod "$pod" -n "$namespace" 2>/dev/null
        kubectl delete namespace "$namespace" 2>/dev/null
        exit 1
    fi

    echo "Installing common tools on pod '$pod' (if supported) ..."
    if [[ "$image" == *"alpine"* ]]; then
        kubectl exec -it "$pod" -n "$namespace" -- /bin/sh -c "
            apk update && \
            apk add bash curl vim && \
            apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing grpcurl && \
            echo 'Common tools installed successfully.'
        "
    elif [[ "$image" == *"ubuntu"* || "$image" == *"debian"* ]]; then
        kubectl exec -it "$pod" -n "$namespace" -- /bin/bash -c "
            apt-get update && \
            apt-get install -y bash curl vim && \
            echo 'Common tools installed successfully.'
        "
    else
        echo "Skipping tool installation. Unsupported image type."
    fi

    echo "Attaching to pod '$pod' ..."
    if ! kubectl exec -it "$pod" -n "$namespace" -- /bin/sh 2>/dev/null; then
        echo "Failed to attach to pod. Ensure the image has a shell (/bin/sh)."
    fi

    echo "Cleaning up pod '$pod' ..."
    if ! kubectl delete pod "$pod" -n "$namespace" 2>/dev/null; then
        echo "Failed to delete pod. It may have already been removed."
    fi

    echo "Cleaning up namespace '$namespace' ..."
    if ! kubectl delete namespace "$namespace" 2>/dev/null; then
        echo "Failed to delete namespace. It may have already been removed."
    fi

    echo "Exiting ..."
    echo "DONE!"
}

# Run the main function with command-line arguments
main "$@"
