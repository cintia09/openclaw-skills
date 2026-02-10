---
name: gaokao-exam-gen
description: |
  生成中国高考模拟试卷（LaTeX+TikZ带图版或Markdown纯文本版）。支持新高考I卷（语数英）和江苏自主命题（物化地）。
  当用户提到高考、模拟卷、试卷生成、出题、考试、LaTeX试卷、TikZ图形试卷时触发。
---

# 高考模拟卷生成技能

## 支持科目与试卷规格

| 科目 | 命题 | 时长 | 满分 | 结构 |
|------|------|------|------|------|
| 语文 | 新高考I卷 | 150min | 150 | 现代文35+古文35+语用20+作文60 |
| 数学 | 新高考I卷 | 120min | 150 | 8单选+3多选+3填空+5解答(8+3+3+5) |
| 英语 | 新高考I卷 | 120min | 150 | 阅读50+七选五10+完形15+语法15+写作40(+听力30) |
| 物理 | 江苏卷 | 75min | 100 | 10单选(无多选!)+2实验+3计算 |
| 化学 | 江苏卷 | 75min | 100 | 14单选+4非选择 |
| 地理 | 江苏卷 | 75min | 100 | 20单选+3-4综合 |

详细结构规范见 `references/exam-specs/` 目录下各科文件。

## 两种输出格式

### 1. LaTeX+TikZ带图版（推荐，高质量）

生成 `.tex` 源文件 → XeLaTeX 编译 → PDF。适合数学/物理/化学等需要图形的科目。

- **模板**: 见 `assets/latex-template.tex`
- **图形**: TikZ/pgfplots 画函数曲线、几何图、电路图、有机结构式等
- **编译命令**: `xelatex -interaction=nonstopmode 文件名.tex`（可能需要跑两遍）
- **编译环境**: 需安装 `texlive-full` 或至少 `texlive-xetex texlive-lang-chinese texlive-science`

### 2. Markdown纯文本版（快速批量）

生成 `.md` 文件 → Pandoc 转 PDF。适合快速出大量试卷。

- **转PDF**: `pandoc input.md -o output.pdf --pdf-engine=xelatex -V CJKmainfont="Noto Sans CJK SC" -V geometry:margin=2cm -V fontsize=11pt`

## 生成流程

### Step 1: 确定科目和输出格式

询问用户需要哪科、几套、什么格式（LaTeX带图/Markdown纯文本）。

### Step 2: 加载考试规范

读取 `references/exam-specs/{科目}_考试规范.md`，严格遵循题型结构和分值。

### Step 3: 加载参考样板

- LaTeX版：读取 `assets/latex-template.tex` 获取排版模板
- 查看现有试卷（如有）避免题目重复

### Step 4: 生成试卷内容

**关键原则：**
1. **原创出题** — 不抄真题，但难度/风格对齐真题
2. **难度梯度** — 基础50% + 中等30% + 较难20%
3. **知识覆盖** — 按考试规范的知识点分布出题
4. **答案分布** — 选择题答案ABCD分布均匀，多选题答案各不相同
5. **题目唯一解** — 每道选择题有且仅有一个（或一组）正确答案，无争议

**子代理分配策略：**
- 1个子代理 = 1科 × 1套（试卷+答案），保持任务聚焦
- LaTeX长文件（>500行）：用分段写入法（`cat >` 首段 + 多次 `cat >>`）
- 推荐模型：Claude Opus 4.6/4.5 或 GPT-5.2（长内容生成）

### Step 5: 质检验收

**必检项目：**
- [ ] 文件大小正常（>5KB，24字节=失败占位符）
- [ ] 题目数量与考试规范一致
- [ ] LaTeX编译无错误
- [ ] TikZ图形数量合理（数学≥10个，物理≥8个，化学≥5个）
- [ ] 选择题答案分布均匀（不能全选同一个）
- [ ] 多选题答案各不相同（不能三道全ABCD）
- [ ] 每题有唯一正确答案，无争议项
- [ ] 分值总和正确

**常见问题及修正：**
- 椭圆没有渐近线（只有双曲线有）
- 单选题多解 → 修改干扰项使答案唯一
- 离子共存题注意氧化还原反应（如 Fe²⁺ 与 NO₃⁻）
- 物理题图与文字矛盾（如"带负电"但力的方向暗示正电）

### Step 6: 编译与交付

```bash
# LaTeX编译
cd 输出目录
xelatex -interaction=nonstopmode 试卷.tex
# 如有交叉引用，跑第二遍
xelatex -interaction=nonstopmode 试卷.tex

# 如缺包（如mhchem.sty）
texhash && xelatex ...

# Markdown转PDF
pandoc 试卷.md -o 试卷.pdf --pdf-engine=xelatex \
  -V CJKmainfont="Noto Sans CJK SC" \
  -V geometry:margin=2cm -V geometry:a4paper \
  -V fontsize=11pt -V linestretch=1.2 --columns=80
```

## 踩坑经验

1. **GPT-5.2 写超长heredoc（>500行）会exec超时** → 用分段写入（cat > + 多次 cat >>）
2. **子代理生成内容可能截断** → 必须检查文件大小，<2KB就是截断了
3. **多选题全ABCD不真实** → 真实高考几乎不会三道多选全选ABCD
4. **LaTeX编译缺包** → `texhash` 刷新后重试，或 `tlmgr install 包名`
5. **化学有机结构式** → TikZ `\node` + `\draw` 比 chemfig 更稳定
6. **macOS base64解码** → `base64 -D -i input -o output`（不是Linux的 `-d`）
7. **选择题必须无争议** → 用ChatGPT/Claude评测试卷是很好的质检手段
