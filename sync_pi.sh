#!/bin/bash
# =============================================
# Sync project giữa máy local <-> Pi (mobile2)
# =============================================

PI_HOST="mobile2.local"
PI_USER="mobile2"
PI_DIR="/home/mobile2/Transform_bipedal/"
LOCAL_DIR="/home/cat21/Documents/projects/Transformer/Transform_bipedal/"

EXCLUDE_ARGS=(
    --exclude '.git'
    --exclude '__pycache__'
    --exclude '*.pyc'
    --exclude 'logs/'
    --exclude 'imu_logs/'
    --exclude '*.log'
    --exclude '*.jsonl'
)

usage() {
    echo ""
    echo "  Sử dụng: ./sync_pi.sh [push|pull|dry-push|dry-pull]"
    echo ""
    echo "  push       Đẩy code từ máy local → Pi"
    echo "  pull       Kéo code từ Pi → máy local"
    echo "  dry-push   Xem trước push (không thay đổi gì)"
    echo "  dry-pull   Xem trước pull (không thay đổi gì)"
    echo ""
}

do_sync() {
    local direction=$1
    local dry_run=$2
    local flags="-avz --progress"

    if [ "$dry_run" = "true" ]; then
        flags="$flags --dry-run"
        echo "🔍 [DRY-RUN] Chỉ xem trước, không thay đổi gì"
    fi

    if [ "$direction" = "push" ]; then
        echo "🚀 Đẩy code: LOCAL → Pi ($PI_HOST)"
        rsync $flags "${EXCLUDE_ARGS[@]}" "$LOCAL_DIR" "$PI_USER@$PI_HOST:$PI_DIR"
    elif [ "$direction" = "pull" ]; then
        echo "📥 Kéo code: Pi ($PI_HOST) → LOCAL"
        rsync $flags "${EXCLUDE_ARGS[@]}" "$PI_USER@$PI_HOST:$PI_DIR" "$LOCAL_DIR"
    fi

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Hoàn tất!"
    else
        echo ""
        echo "❌ Lỗi khi sync! Kiểm tra kết nối SSH tới $PI_HOST"
    fi
}

case "$1" in
    push)
        do_sync "push" "false"
        ;;
    pull)
        do_sync "pull" "false"
        ;;
    dry-push)
        do_sync "push" "true"
        ;;
    dry-pull)
        do_sync "pull" "true"
        ;;
    *)
        usage
        ;;
esac
