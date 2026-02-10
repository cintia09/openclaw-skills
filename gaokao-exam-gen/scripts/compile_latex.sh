#!/bin/bash
# LaTeX 试卷编译脚本
# 用法: ./compile_latex.sh <tex文件路径>
# 示例: ./compile_latex.sh gaokao/LaTeX版/数学/模拟卷01_试卷.tex

TEX_FILE="$1"

if [ -z "$TEX_FILE" ] || [ ! -f "$TEX_FILE" ]; then
    echo "用法: $0 <tex文件路径>"
    exit 1
fi

DIR=$(dirname "$TEX_FILE")
FILE=$(basename "$TEX_FILE")
NAME="${FILE%.tex}"

cd "$DIR" || exit 1

echo "Compiling: $FILE"

# 第一遍编译
xelatex -interaction=nonstopmode "$FILE" 2>&1 | tail -5

# 检查是否需要第二遍（交叉引用）
if grep -q "Rerun" "${NAME}.log" 2>/dev/null; then
    echo "Re-running for cross-references..."
    xelatex -interaction=nonstopmode "$FILE" 2>&1 | tail -3
fi

# 检查结果
if [ -f "${NAME}.pdf" ]; then
    size=$(stat -c%s "${NAME}.pdf" 2>/dev/null || stat -f%z "${NAME}.pdf")
    pages=$(pdfinfo "${NAME}.pdf" 2>/dev/null | grep Pages | awk '{print $2}')
    echo "✅ ${NAME}.pdf — ${size} bytes, ${pages:-?} pages"
else
    echo "❌ Compilation failed. Check ${NAME}.log"
    # 显示关键错误
    grep -A2 "^!" "${NAME}.log" 2>/dev/null | head -20
fi
