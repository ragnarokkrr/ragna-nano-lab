#!/bin/bash
set -e

echo "🧪 RagnaNano Lab - Running All Provisioning Tests"
echo "=================================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
for cmd in vagrant ansible molecule; do
    if command_exists "$cmd"; then
        echo "✅ $cmd is installed"
    else
        echo "❌ $cmd is not installed. Please install it first."
        exit 1
    fi
done

echo ""
echo "🔬 Running Molecule tests..."
cd molecule && molecule test && cd ..
echo "✅ Molecule tests completed"

echo ""
echo "🏠 Testing ragna-nas..."
cd ragna-nas && vagrant up && vagrant destroy -f && cd ..
echo "✅ ragna-nas tests completed"

echo ""
echo "🤖 Testing ragna-lab-sidekick..."
cd ragna-lab-sidekick && vagrant up && vagrant destroy -f && cd ..
echo "✅ ragna-lab-sidekick tests completed"

echo ""
echo "🎉 All tests completed successfully!"
echo "The Ansible provisioning scripts are ready for deployment."