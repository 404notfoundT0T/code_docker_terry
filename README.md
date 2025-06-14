FASTQ 预处理工具

基于 fastp 的 Docker 化 FASTQ 文件预处理工具，用于自动化处理高通量测序数据。

功能特性：
🚀 ​​高效处理​​：支持多线程并行处理 FASTQ 文件
🔄 ​​双端/单端支持​​：自动识别并处理双端测序数据和单端数据
📊 ​​质量控制​​：自动生成 HTML 和 JSON 格式的质量报告
🐳 ​​容器化​​：开箱即用的 Docker 镜像，无需复杂环境配置

Quick Start
1. 构建 Docker 镜像
bash
复制
docker build -t fastp-processor .
2. 运行处理流程
bash
复制
docker run --rm \
  -v /path/to/input:/mnt/in \
  -v /path/to/output:/mnt/out \
  -e THREADS=8 \  # 可选：设置线程数，默认为4
  fastp-processor
输入输出

输入要求
输入目录应包含以下格式的 FASTQ 文件：
双端数据：*_R1.fastq.gz 和 *_R2.fastq.gz
单端数据：*.fastq.gz 或 *.fq.gz
输出内容
处理后的 FASTQ 文件：
双端：{sample}_trimmed_R1.fastq.gz 和 {sample}_trimmed_R2.fastq.gz
单端：{sample}_trimmed.fastq.gz
质量报告：
{sample}_fastp.html - 可视化质量报告
{sample}_fastp.json - 机器可读质量数据
CI/CD 集成
项目已配置 GitHub Actions 工作流，实现自动化构建、测试和发布：

​​自动构建​​：推送至 main 分支或创建标签时触发构建
​​功能测试​​：使用公开可用的测试数据验证处理流程
​​容器发布​​：自动推送镜像至 GitHub Container Registry (GHCR)
​​镜像签名​​：使用 cosign 对镜像进行数字签名
工作流触发条件
push 到 main 分支
创建 v*.*.* 标签
针对 main 分支的 pull request
开发指南

项目结构
复制
.
├── Dockerfile            # 容器构建定义
├── entrypoint.sh         # 主处理脚本
└── .github/workflows/    # CI/CD 工作流定义
    └── docker-build.yml  # 构建和测试工作流
自定义配置
通过环境变量调整处理参数：

bash
复制
# 在 docker run 时设置
-e THREADS=8              # 设置处理线程数
示例数据
工作流使用来自 EBI 的公开测试数据：

ERR011347_1.fastq.gz
ERR011347_2.fastq.gz
许可证
本项目采用 MIT 许可证。
