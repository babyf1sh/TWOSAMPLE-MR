TWOSAMPLE-MR
1. 项目简介
本项目基于 Mendelian Randomization（MR，孟德尔随机化） 方法，探索遗传预测的基因表达与疾病表型之间的潜在因果关系。当前阶段以 GTEx eQTL + GWAS 为基础，建立从遗传变异、基因表达至疾病表型的 MR 分析流程，为后续开展细胞类型特异性 eQTL、细胞类型特异性 MR 以及空间转录组整合分析建立方法基础。

2. 当前研究问题
当前选择：
组织： Adipose Subcutaneous
基因： DHRS4-AS1
疾病： Coronary heart disease（冠心病）

核心问题：
遗传预测的 DHRS4-AS1 表达是否与冠心病存在潜在因果关系？

基本 MR 思路：
SNP
├── SNP → 基因表达（βX）
└── SNP → 疾病表型（βY）
             ↓
        βY / βX
             ↓
        Wald Ratio

3. 数据来源
暴露数据：GTEx eQTL
数据来自 MRInstruments 包中的：gtex_eqtl

当前筛选：
Tissue: Adipose Subcutaneous
Gene: DHRS4-AS1

结局数据：GWAS
数据来自 OpenGWAS 数据库。

GWAS ID: ieu-a-7
Outcome: Coronary heart disease

通过 TwoSampleMR 获取指定 SNP 的 GWAS 关联：

extract_outcome_data(
  snps = snps,
  outcomes = "ieu-a-7",
  proxies = FALSE
)

当前 GWAS 样本量：184,305

4. 当前工具变量
当前使用两个 SNP：
rs10151793
rs59434518
SNP	βX	SE_X	βY	SE_Y	Wald Ratio
rs10151793	-0.956368	0.0713899	0.005636	0.0218646	-0.00589
rs59434518	-0.766910	0.0807102	0.008426	0.0217027	-0.01099

其中：
βX：SNP → DHRS4-AS1 表达
βY：SNP → 冠心病
Wald Ratio = βY / βX

目前结果仅为 SNP-specific 的初步 MR 效应估计，尚未进行完整的 IVW 和敏感性分析。

5. 软件环境
软件 / R 包	版本
R	4.6.1
MRInstruments	0.3.3
TwoSampleMR	0.7.9
ieugwasr	1.1.0
dplyr	1.2.1
data.table	1.18.6.1
ggplot2	4.0.3

GWAS 数据通过 OpenGWAS API 获取，使用 TwoSampleMR / ieugwasr 进行接口访问。
API 认证信息保存在本地 .Renviron 中，不上传至 GitHub。

6. 当前代码结构
TWOSAMPLE-MR/
│
├── README.md
├── README_dev.md
├── .gitignore
│
└── R/
    ├── 01_load_eqtl.R
    ├── 02_extract_gwas.R
    └── 03_wald_ratio.R
7. 当前进度
已完成

R 环境配置

GTEx eQTL 数据读取

组织及基因筛选

SNP 工具变量确定

OpenGWAS GWAS 数据提取

eQTL 与 GWAS SNP 匹配

等位基因检查

Wald Ratio 计算

分析流程脚本化

干净 R Session 中完成流程验证

下一步

数据 harmonisation

LD 独立性检查

工具变量强度评估

IVW

其他 MR 方法

敏感性分析

细胞类型特异性 eQTL

空间转录组整合

8. 项目发展方向

当前项目：

GTEx tissue-level eQTL
        ↓
Gene-level MR
        ↓
Disease-associated genes

后续计划：

Cell-type-specific eQTL
        ↓
Cell-type-specific MR
        ↓
Disease-associated genes by cell type
        ↓
Spatial transcriptomics
        ↓
Spatial localization of disease-related genes

当前阶段主要用于建立和验证 MR 分析流程，为后续转录组与空间转录组研究提供方法基础。

