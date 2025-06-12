# 工作目录和输出目录
INPUT_DIR="/mnt/in"
OUTPUT_DIR="/mnt/out"
THREAD_NUM=${THREADS:-4}  # 默认线程数为4

# 检查输入目录是否存在
if [ ! -d "$INPUT_DIR" ]; then
    echo -e "\e[0;31m错误：输入目录 $INPUT_DIR 不存在\e[0m" >&2
    exit 1
fi

# 创建输出目录（如果不存在）
mkdir -p "$OUTPUT_DIR"

# 查找所有fastq.gz文件
tmpfile=$(mktemp)
find "$INPUT_DIR" -type f $ -name "*.fastq.gz" -o -name "*.fq.gz" $ > "$tmpfile"

# 检查是否找到fastq.gz文件
if [ ! -s "$tmpfile" ]; then
    echo -e "\e[0;31m错误：在 $INPUT_DIR 中未找到.fastq.gz或.fq.gz文件\e[0m" >&2
    rm "$tmpfile"
    exit 1
fi

# 处理单端和双端测序数据
declare -A sample_map  # 用于存储样本名和对应的文件

while IFS= read -r fqgz; do
    # 提取样本名（去除_R1/_R2和扩展名）
    BASE_NAME=$(basename -- "$fqgz")
    SAMPLE_NAME=$(echo "$BASE_NAME" | sed -E 's/_(R[12]|1|2)(_001)?\.(f(ast)?q|fastq)\.gz//g')
    
    # 将文件按样本名分组
    if [[ $BASE_NAME =~ _(R1|1)(_001)?\. ]]; then
        sample_map["${SAMPLE_NAME}_R1"]="$fqgz"
    elif [[ $BASE_NAME =~ _(R2|2)(_001)?\. ]]; then
        sample_map["${SAMPLE_NAME}_R2"]="$fqgz"
    else
        # 单端测序
        sample_map["${SAMPLE_NAME}_SE"]="$fqgz"
    fi
done < "$tmpfile"
rm "$tmpfile"

# 处理每个样本
for sample_key in "${!sample_map[@]}"; do
    if [[ $sample_key =~ _R1$ ]]; then
        # 双端测序的R1
        sample_name=${sample_key%_R1}
        r1_file="${sample_map[${sample_name}_R1]}"
        r2_file="${sample_map[${sample_name}_R2]}"
        
        if [ -n "$r2_file" ]; then
            echo -e "\e[0;34m信息：正在处理双端样本 ${sample_name}...\e[0m"
            
            fastp \
                -i "$r1_file" \
                -I "$r2_file" \
                -o "${OUTPUT_DIR}/${sample_name}_trimmed_R1.fastq.gz" \
                -O "${OUTPUT_DIR}/${sample_name}_trimmed_R2.fastq.gz" \
                --thread "$THREAD_NUM" \
                --adapter_sequence auto \
                --adapter_sequence_r2 auto \
                --qualified_quality_phred 15 \
                --length_required 50 \
                --json "${OUTPUT_DIR}/${sample_name}_fastp.json" \
                --html "${OUTPUT_DIR}/${sample_name}_fastp.html"
                
            if [ $? -ne 0 ]; then
                echo -e "\e[0;31m错误：处理样本 ${sample_name} 失败\e[0m" >&2
                exit 1
            fi
        fi
    elif [[ $sample_key =~ _SE$ ]] && [[ ! $sample_key =~ _R1$ ]] && [[ ! $sample_key =~ _R2$ ]]; then
        # 单端测序
        sample_name=${sample_key%_SE}
        se_file="${sample_map[${sample_name}_SE]}"
        
        echo -e "\e[0;34m信息：正在处理单端样本 ${sample_name}...\e[0m"
        
        fastp \
            -i "$se_file" \
            -o "${OUTPUT_DIR}/${sample_name}_trimmed.fastq.gz" \
            --thread "$THREAD_NUM" \
            --adapter_sequence auto \
            --qualified_quality_phred 15 \
            --length_required 50 \
            --json "${OUTPUT_DIR}/${sample_name}_fastp.json" \
            --html "${OUTPUT_DIR}/${sample_name}_fastp.html"
            
        if [ $? -ne 0 ]; then
            echo -e "\e[0;31m错误：处理样本 ${sample_name} 失败\e[0m" >&2
            exit 1
        fi
    fi
done

echo -e "\e[0;32m成功：所有样本处理完成。结果保存在 ${OUTPUT_DIR}\e[0m"
