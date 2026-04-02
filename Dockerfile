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
    wget -O /tmp/editor-ui.tar.gz https://github.com/other-blowsnow/n8n-i18n-chinese/releases/latest/download/editor-ui.tar.gz; \
    mkdir -p /tmp/n8n-i18n; \
    tar -xzf /tmp/editor-ui.tar.gz -C /tmp/n8n-i18n; \
    # 目标路径（n8n 静态资源路径）
    TARGET_DIR="/usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist"; \
    # 确保目标目录存在并清空旧文件（可选），然后把解压出的 dist 里的内容复制进去
    cp -rd /tmp/n8n-i18n/dist/* "$TARGET_DIR/"; \
    # 清理
    rm -rf /tmp/editor-ui.tar.gz /tmp/n8n-i18n;

USER node