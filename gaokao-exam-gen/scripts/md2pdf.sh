#!/bin/bash
# 高考模拟卷 Markdown → PDF 批量转换
# 用法: ./md2pdf.sh <输入目录> <输出目录>
# 示例: ./md2pdf.sh gaokao/生成试卷/数学 gaokao/PDF/数学

INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./pdf_output}"

mkdir -p "$OUTPUT_DIR"

for md in "$INPUT_DIR"/*.md; do
    [ -f "$md" ] || continue
    basename=$(basename "$md" .md)
    echo "Converting: $basename"
    pandoc "$md" \
        -o "$OUTPUT_DIR/${basename}.pdf" \
        --pdf-engine=xelatex \
        -V mainfont="Noto Sans CJK SC" \
        -V CJKmainfont="Noto Sans CJK SC" \
        -V geometry:margin=2cm \
        -V geometry:a4paper \
        -V fontsize=11pt \
        -V linestretch=1.2 \
        --columns=80 \
        2>&1 | grep -v "Missing character"
    
    if [ -f "$OUTPUT_DIR/${basename}.pdf" ]; then
        size=$(stat -c%s "$OUTPUT_DIR/${basename}.pdf" 2>/dev/null || stat -f%z "$OUTPUT_DIR/${basename}.pdf")
        echo "  ✅ ${basename}.pdf (${size} bytes)"
    else
        echo "  ❌ Failed: ${basename}"
    fi
done

echo "Done! Output: $OUTPUT_DIR"
