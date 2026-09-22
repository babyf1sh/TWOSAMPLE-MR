# TWOSAMPLE-MR

一个用于学习 **两样本孟德尔随机化（Two-Sample Mendelian Randomization, MR）** 的 R 项目。

本项目以 GTEx eQTL 数据和 OpenGWAS GWAS 数据为例，从 SNP 特异性 Wald Ratio 计算逐步扩展到 IVW MR 分析，同时记录数据匹配、等位基因协调（harmonisation）以及数据质量问题的诊断过程。

> **说明：** 本项目主要用于学习 TwoSampleMR 工作流程和可重复分析实践，并非针对具体疾病和基因的正式生物医学研究。

---

## 一、项目目标

本项目希望通过一个小型、可重复的实例，理解并实践以下 MR 分析流程：

```text
GTEx eQTL
    ↓
选择基因及组织
    ↓
获得 SNP–基因表达关联
    ↓
OpenGWAS
    ↓
获得 SNP–疾病结局关联
    ↓
匹配 SNP
    ↓
等位基因协调（Harmonisation）
    ↓
Wald Ratio / IVW
    ↓
MR 分析结果
```

其中：

- **暴露（Exposure）**：基因表达水平
- **工具变量（Instrument）**：与基因表达相关的 SNP
- **结局（Outcome）**：疾病 GWAS 表型
- **MR 方法**：Wald Ratio、IVW

---

## 二、当前示例

### 1. 暴露数据

使用 `MRInstruments` 包中的 `gtex_eqtl` 数据。

当前示例选择：

- 组织：`Adipose Subcutaneous`
- 基因：`DHRS4-AS1`

即：

> 研究皮下脂肪组织中 DHRS4-AS1 基因表达与冠心病之间的潜在因果关系。

### 2. 结局数据

使用 OpenGWAS 中的：

```text
ieu-a-7
```

对应：

> Coronary heart disease（冠心病，CHD）

### 3. 当前示例中的 SNP

经过 eQTL 与 GWAS 数据匹配后，获得：

```text
rs10151793
rs59434518
```

---

# 三、版本迭代

## v1.0.0 —— 手动理解 Wald Ratio

第一版主要用于理解两样本 MR 的基本概念和数学关系。

主要内容：

- 读取 GTEx eQTL 数据
- 选择目标组织和基因
- 获取 SNP–基因表达关联
- 从 OpenGWAS 获取 SNP–CHD 关联
- 理解暴露、结局和工具变量之间的关系
- 手动计算 SNP 特异性的 Wald Ratio

Wald Ratio：

```text
Wald Ratio = β_outcome / β_exposure
```

---

## v2.0.0 —— 自动化 Wald Ratio 分析

第二版开始使用 `TwoSampleMR` 建立自动化流程。

主要完成：

1. 从 eQTL 数据中获取 SNP
2. 使用 `extract_outcome_data()` 自动提取 GWAS 数据
3. 自动匹配暴露和结局中的共同 SNP
4. 使用 `format_data()` 整理暴露数据
5. 使用 `harmonise_data()` 进行等位基因协调
6. 自动计算每个 SNP 的 Wald Ratio

核心流程：

```text
eQTL SNP
    ↓
extract_outcome_data()
    ↓
GWAS 数据
    ↓
共同 SNP 匹配
    ↓
format_data()
    ↓
harmonise_data()
    ↓
Wald Ratio
```

---

# 四、v3.0.0 —— IVW 分析与数据问题诊断

## 1. 目标

第三版原计划在 v2.0.0 的基础上进一步进行：

> **逆方差加权法（Inverse-Variance Weighted, IVW）MR 分析**

使用：

```r
mr(
  harmonised_dat,
  method_list = "mr_ivw"
)
```

进行 IVW 分析。

## 2. 实际结果

运行 IVW 时出现：

```text
No SNPs available for MR analysis
```

进一步检查发现：

```text
SNP          palindromic    ambiguous    remove    mr_keep

rs10151793       TRUE          TRUE      FALSE      FALSE
rs59434518       TRUE          TRUE      FALSE      FALSE
```

也就是说：

> 两个 SNP 均未通过 harmonisation，因此没有 SNP 可以进入后续 MR 分析。

## 3. 问题定位

两个 SNP 的等位基因为：

```text
SNP          Exposure allele    Other allele

rs10151793       C                  G
rs59434518       T                  A
```

两个 SNP 都属于 **回文 SNP（palindromic SNP）**：

```text
C / G
T / A
```

这类 SNP 在不同数据集之间进行等位基因方向判断时可能存在歧义。

## 4. EAF 缺失

检查 `gtex_eqtl` 原始数据结构后发现：

```r
names(gtex_eqtl)
```

得到：

```text
tissue
gene_name
gene_start
SNP
snp_position
effect_allele
other_allele
beta
se
pval
n
```

原始 `gtex_eqtl` 数据共有：

```text
280630 行
11 个变量
```

其中没有：

```text
EAF
```

即：

> **Effect Allele Frequency（效应等位基因频率）**

因此：

```text
eaf.exposure = NA
```

而结局 GWAS 数据中存在 `eaf.outcome`。

对于回文 SNP，EAF 可以作为额外信息帮助判断等位基因频率和链方向。当前两个 SNP 又恰好都是回文 SNP，因此在暴露侧缺少 EAF 的情况下，`TwoSampleMR` 对其进行了保守处理：

```text
palindromic = TRUE
ambiguous = TRUE
mr_keep = FALSE
```

最终：

```text
可用于 MR 的 SNP 数量 = 0
```

因此 IVW 无法执行。

---

# 五、为什么没有人为修改 EAF？

本项目没有采用：

```r
eaf.exposure <- eaf.outcome
```

也没有直接修改：

```r
harmonised_dat$mr_keep <- TRUE
```

原因是：

### 1. 不能随意复制 EAF

暴露数据和结局数据来自不同数据源。即使是相同 SNP，也不能在没有依据的情况下直接认为 `eaf.exposure` 与 `eaf.outcome` 相同。

### 2. 不能为了得到结果而强行修改 `mr_keep`

`mr_keep` 是 harmonisation 和质量控制过程产生的结果。直接修改它相当于绕过质量控制，并没有真正解决回文 SNP 的方向歧义。

因此，本项目选择保留这个问题，而不是人为制造一个 IVW 结果。

---

# 六、v3.0.0 最终结论

本版本**没有产生 IVW MR 效应值**。

最终分析流程为：

```text
eQTL 数据
    ↓
GWAS 数据
    ↓
SNP 匹配
    ↓
harmonise_data()
    ↓
发现两个 SNP 均为回文 SNP
    ↓
暴露数据缺少 EAF
    ↓
无法解决等位基因方向歧义
    ↓
mr_keep = FALSE
    ↓
没有 SNP 进入 MR
    ↓
IVW 未执行
```

因此：

> **v3.0.0 的结果不是“IVW 分析成功”，而是成功定位了导致 IVW 无法执行的数据问题。**

这也是本项目的一部分分析结果。

---

# 七、项目局限性

本项目主要用于学习 TwoSampleMR 的基本工作流程，因此存在以下局限：

### 1. 数据集较小

当前示例只使用了少量 SNP，不能作为正式的生物医学因果推断结果。

### 2. eQTL 数据缺少 EAF

当前使用的 `MRInstruments::gtex_eqtl` 数据对象没有提供暴露侧 EAF。

### 3. 当前 SNP 均为回文 SNP

`rs10151793` 和 `rs59434518` 均属于回文 SNP，因此 EAF 缺失直接影响 harmonisation。

### 4. 尚未进行完整的工具变量筛选

正式 MR 分析还需要考虑：

- SNP–暴露关联强度
- F 统计量
- LD clumping
- 工具变量独立性
- 弱工具变量问题

### 5. 尚未进行完整的敏感性分析

正式 MR 分析通常还需要根据工具变量数量和数据情况考虑：

- 异质性检验
- 水平多效性检验
- MR-Egger
- Weighted Median
- Leave-one-out analysis
- 其他敏感性分析

因此，本项目的结果不应直接解释为：

> DHRS4-AS1 对冠心病具有或不具有因果作用。

---

# 八、项目最终成果

通过三个版本，本项目完成了从手动计算到自动化 MR 流程的学习：

```text
v1.0.0
手动理解 Wald Ratio
        ↓
v2.0.0
自动提取、匹配、协调并计算 Wald Ratio
        ↓
v3.0.0
尝试 IVW
        ↓
发现并定位真实数据问题
```

项目最终形成了一个基本的 TwoSampleMR 分析框架，并通过实际的数据问题理解了：

> **MR 分析不仅是调用统计方法得到一个效应值，更重要的是理解数据来源、等位基因方向、质量控制以及为什么某些 SNP 不能进入最终分析。**

---

# 九、后续方向

本项目在 v3.0.0 停止迭代。

后续真正进入转录组学与 MR 研究时，将使用更加合适的 eQTL 数据，并重新建立分析流程。

后续正式研究流程预计包括：

```text
高质量 eQTL 数据
        ↓
工具变量筛选
        ↓
LD clumping
        ↓
GWAS 数据提取
        ↓
Allele harmonisation
        ↓
IVW
        ↓
敏感性分析
        ↓
多基因 / 多组织分析
        ↓
进一步向单细胞 / 细胞类型特异性 eQTL 扩展
```

---

# 十、项目环境

当前主要 R 环境：

```text
R                 4.6.1
MRInstruments     0.3.3
TwoSampleMR       0.7.9
ieugwasr          1.1.0
dplyr             1.2.1
data.table        1.18.6.1
ggplot2            4.0.3
```

数据来源：

- GTEx eQTL：`MRInstruments::gtex_eqtl`
- GWAS：OpenGWAS
- MR 分析：TwoSampleMR

---

# 十一、项目结构

```text
TWOSAMPLE-MR/
├── README.md
├── README_dev.md
├── .gitignore
└── R/
    ├── 01_load_eqtl.R
    ├── 02_extract_gwas.R
    ├── 03_wald_ratio.R
    └── 04_ivw.R
```

其中：

```text
01_load_eqtl.R
```

负责加载并筛选 eQTL 数据。

```text
02_extract_gwas.R
```

负责从 OpenGWAS 提取结局数据。

```text
03_wald_ratio.R
```

负责 SNP 匹配、harmonisation 和 Wald Ratio。

```text
04_ivw.R
```

负责 IVW 尝试及 harmonisation 问题诊断。

---

# 十二、版本标签

```text
v1.0.0    手动 Wald Ratio
v2.0.0    自动化 Wald Ratio
v3.0.0    IVW 尝试与数据问题诊断
```

**项目最终版本：v3.0.0**
