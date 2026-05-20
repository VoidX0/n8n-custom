FROM n8nio/n8n:latest

# 从Alpine 3.23 Copy依赖
COPY --from=alpine:3.23 /sbin/apk /sbin/apk
COPY --from=alpine:3.23 /usr/lib/libapk.so* /usr/lib/

USER root

# 安装必要工具和依赖
RUN apk add --no-cache docker-cli-compose yq tar

# 设置环境变量
ENV N8N_DEFAULT_LOCALE=zh-CN
# 下载并安装n8n-editor-ui的中文翻译文件
RUN set -ex; \
    # 下载并解压翻译包
    wget -O /tmp/editor-ui.tar.gz https://github.com/other-blowsnow/n8n-i18n-chinese/releases/latest/download/editor-ui.tar.gz; \
    mkdir -p /tmp/n8n-i18n; \
    tar -xzf /tmp/editor-ui.tar.gz -C /tmp/n8n-i18n; \
    \
    # 定义所有可能的 n8n 静态资源路径
    # 1. /usr/local/lib... (常见于官方镜像)
    # 2. /usr/lib... (某些 Alpine 构建版本)
    # 3. 包含 @n8n/ 作用域的新路径
    # 4. 不含 @n8n/ 作用域的旧路径
    POSSIBLE_PATHS=" \
        /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist \
        /usr/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist \
    "; \
    \
    TARGET_DIR=""; \
    for path in $POSSIBLE_PATHS; do \
        if [ -d "$path" ]; then \
            TARGET_DIR="$path"; \
            echo "Found target directory at: $TARGET_DIR"; \
            break; \
        fi; \
    done; \
    \
    # 检查是否找到了有效路径
    if [ -z "$TARGET_DIR" ]; then \
        echo "Error: Could not find n8n-editor-ui dist directory in any of the expected locations."; \
        exit 1; \
    fi; \
    \
    # 执行复制操作
    cp -rd /tmp/n8n-i18n/dist/* "$TARGET_DIR/"; \
    \
    # 清理垃圾
    rm -rf /tmp/editor-ui.tar.gz /tmp/n8n-i18n;

USER node
