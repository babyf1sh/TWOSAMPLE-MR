# TWOSAMPLE-MR



### 1\. 项目简介

本项目是一个以\*\*孟德尔随机化（Mendelian Randomization, MR）\*\*为核心的方法学习与实践项目。



项目目前尝试将：

GTEx eQTL 数据作为暴露（Exposure）数据；

GWAS 数据作为结局（Outcome）数据；

使用 TwoSampleMR 等 R 工具进行孟德尔随机化分析。



当前阶段的主要目的是熟悉从：遗传变异 → 基因表达 → 疾病表型的分析思路，以及掌握 eQTL 数据、GWAS 数据和 MR 方法之间的衔接。

当前项目使用的是组织水平（tissue-level）的 GTEx eQTL 数据作为前期学习案例，目前还没有进入细胞类型特异性的 eQTL 分析，也尚未进行空间转录组整合。



### 2\. 当前研究问题

目前选择：

组织：Adipose Subcutaneous

基因：DHRS4-AS1

疾病表型：冠心病（Coronary heart disease）

希望通过孟德尔随机化方法初步研究：遗传预测的 DHRS4-AS1 基因表达是否与冠心病存在潜在的因果关系。

基本 MR 思路为：

&#x20;            SNP

&#x20;           /   \\

&#x20;          /     \\

&#x20;         ↓       ↓

&#x20;  基因表达      疾病表型

&#x20;     βX           βY

&#x20;          \\     /

&#x20;           \\   /

&#x20;            MR

&#x20;             ↓

&#x20;      βY / βX

&#x20;      Wald Ratio

其中：

βX：SNP → 基因表达的效应；

βY：SNP → 疾病表型的效应；

βY / βX：单个 SNP 对应的 Wald Ratio，即 SNP 层面的 MR 因果效应估计。

当存在多个工具变量 SNP 时，可以进一步使用 IVW 等方法对多个 SNP 的效应进行整合。

目前项目尚未进入 IVW 和敏感性分析阶段。



### 3\. 数据来源

#### 3.1 暴露数据：GTEx eQTL

暴露数据来自 R 包 MRInstruments 提供的 GTEx eQTL 数据集：gtex\_eqtl

当前使用的组织和基因为：

组织：Adipose Subcutaneous

基因：DHRS4-AS1



GTEx eQTL 数据中，与本项目相关的主要字段包括：

字段	含义

SNP	SNP 编号

effect\_allele	效应等位基因

other\_allele	另一等位基因

beta	SNP 对基因表达的效应

se	β 的标准误

pval	关联 P 值

tissue	组织

gene\_name	基因名称

本项目中：

βX = SNP → DHRS4-AS1 表达



#### 3.2 结局数据：GWAS

疾病结局数据来自 OpenGWAS 数据库。

当前使用的 GWAS：

GWAS ID：ieu-a-7

结局：Coronary heart disease（冠心病）

通过 TwoSampleMR 从 OpenGWAS 获取指定 SNP 的结局关联数据：



chd\_out\_dat <- extract\_outcome\_data(

&#x20; snps = snps,

&#x20; outcomes = "ieu-a-7",

&#x20; proxies = FALSE

)



本项目当前使用：

rs10151793

rs59434518

两个 SNP 的 GWAS 关联数据。

当前提取到的 GWAS 样本量为：184,305

结局数据中的主要字段包括：

字段	含义

SNP	SNP 编号

effect\_allele	效应等位基因

other\_allele	另一等位基因

beta	SNP 对疾病表型的效应

se	β 的标准误

pval	关联 P 值

本项目中：

βY = SNP → 冠心病



### 4\. GWAS API 数据获取方式

本项目的 GWAS 数据并不是手动下载一个本地 GWAS 文件，而是通过 OpenGWAS API 获取。

数据访问关系可以理解为：

OpenGWAS 数据库

&#x20;      ↑

&#x20;  OpenGWAS API

&#x20;      ↑

&#x20;  ieugwasr

&#x20;      ↑

&#x20; TwoSampleMR

&#x20;      ↑

extract\_outcome\_data()

&#x20;      ↑

指定 SNP + GWAS ID

当前使用的主要 R 包：

TwoSampleMR 0.7.9

ieugwasr 1.1.0

具体调用：



extract\_outcome\_data(

&#x20; snps = snps,

&#x20; outcomes = "ieu-a-7",

&#x20; proxies = FALSE

)



其中：

snps：需要查询的 SNP；

outcomes = "ieu-a-7"：指定冠心病 GWAS；

proxies = FALSE：不使用代理 SNP，仅提取指定 SNP 本身的 GWAS 关联。

因此，本项目当前两个 SNP 的 GWAS 数据来源可以明确记录为：

OpenGWAS 数据库中的 ieu-a-7（Coronary heart disease），通过 TwoSampleMR::extract\_outcome\_data() 获取。



#### 4.1其中关于如何调用OPENGWAS数据

1.登录或注册‘https://api.opengwas.io/profile/’以获取OPENGWAS API

2.将JWT配置到R



ieugwasr 1.1.0

TwoSampleMR 0.7.9



3.确认用户目录后创建.Renviron文件，文件中只写“OPENGWAS\_JWT=你的JWT（也就是API）”



normalizePath("\~")

file.edit("\~/.Renviron")



4.配置成功后session-restart R并测试是否有权限访问OPENGAWS



ieugwasr::get\_opengwas\_jwt()

ieugwasr::user()



### 5\. 当前使用的工具变量 SNP



当前从 GTEx eQTL 数据中使用两个 SNP：

rs10151793

rs59434518



目前获得的暴露和结局效应如下：

SNP	βX	SE\_X	βY	SE\_Y

rs10151793	-0.956368	0.0713899	0.005636	0.0218646

rs59434518	-0.766910	0.0807102	0.008426	0.0217027



其中：

βX：SNP → DHRS4-AS1 表达

βY：SNP → 冠心病

当前两个 SNP 在 eQTL 和 GWAS 数据中的效应等位基因能够对应。



### 6\. 初步 Wald Ratio 分析



对于单个 SNP，可以通过 Wald Ratio 估计该 SNP 对应的 MR 效应：

βMR = βY / βX



当前两个 SNP 的初步结果：

SNP	Wald Ratio

rs10151793	≈ -0.00589

rs59434518	≈ -0.01099



这一步主要用于理解 MR 的基本原理：

SNP → 基因表达

&#x20;       ↓

&#x20;      βX



SNP → 疾病

&#x20;       ↓

&#x20;      βY



βY / βX

&#x20;       ↓

单 SNP 的 MR 效应估计



目前这些结果仅属于初步 SNP 层面的 MR 效应估计，不能直接作为最终因果结论。



### 7\. 软件与运行环境



本项目当前使用的 R 环境：

R version 4.6.1 (2026-06-24 ucrt)

主要 R 包及版本：

软件 / R 包	版本	主要用途

R	4.6.1	统计计算环境

MRInstruments	0.3.3	获取遗传关联数据，包括 GTEx eQTL

TwoSampleMR	0.7.9	MR 分析及 GWAS 数据提取

ieugwasr	1.1.0	OpenGWAS 数据库/API 接口

dplyr	1.2.1	数据整理

data.table	1.18.6.1	数据处理

ggplot2	4.0.3	数据可视化



版本信息通过 R 中的 packageVersion() 获取。



### 8\. 项目代码结构



当前项目代码：

TWOSAMPLE-MR/

│

├── README.md

├── .gitignore

│

└── R/

&#x20;   ├── 01\_load\_eqtl.R

&#x20;   ├── 02\_extract\_gwas.R

&#x20;   └── 03\_wald\_ratio.R



01\_load\_eqtl.R

主要完成：

加载 MRInstruments；

读取 gtex\_eqtl；

筛选 Adipose Subcutaneous；

筛选 DHRS4-AS1；

获得对应的 eQTL 数据。



02\_extract\_gwas.R

主要完成：

指定工具变量 SNP；

使用 TwoSampleMR；

通过 OpenGWAS 获取 ieu-a-7；

提取冠心病 GWAS 中对应 SNP 的效应。



03\_wald\_ratio.R

主要完成：

整合 βX 和 βY；

计算：

βY / βX

得到两个 SNP 的 Wald Ratio。



### 9\. API 认证与隐私

OpenGWAS API 的认证信息保存在本地：

.Renviron

该文件可能包含 API token / JWT 等私密认证信息

因此：

.Renviron

绝对不能上传到 GitHub。

当前 .gitignore 已经将其排除：

.Renviron

同时，本地 R 工作空间文件：

mr\_project.RData

mr\_project.Rhistory

也不上传到 GitHub。

这些文件属于本地分析状态，而不是项目核心代码。



### 10\. 当前研究进度

已完成

配置 R 分析环境

安装并加载 MR 相关 R 包

获取 GTEx eQTL 数据

选择 Adipose Subcutaneous

选择 DHRS4-AS1

确定工具变量 SNP

获取冠心病 GWAS 数据

使用 SNP 作为 eQTL 与 GWAS 的连接键

检查两个数据集中的效应等位基因

计算 SNP-specific Wald Ratio

将分析过程整理为 R 脚本

在干净的 R Session 中成功运行三个脚本



尚未完成

正式的数据 harmonisation

LD 独立性检查

工具变量强度评估

IVW

Weighted median 等其他 MR 方法

敏感性分析

MR 结果解释

扩展到细胞类型特异性 eQTL

与空间转录组数据进行整合



### 11\. 方法学说明



当前项目使用的是组织水平 GTEx eQTL 数据。

因此，目前的分析还不能回答最终的细胞类型和空间层面问题。

当前工作主要是建立：



组织水平 eQTL

&#x20;     ↓

基因表达

&#x20;     ↓

GWAS

&#x20;     ↓

MR

&#x20;     ↓

疾病相关基因



后续计划进一步扩展为：



细胞类型特异性 eQTL

&#x20;         ↓

细胞类型特异性 MR

&#x20;         ↓

不同细胞类型中的疾病相关基因

&#x20;         ↓

空间转录组

&#x20;         ↓

组织空间区域 / domain

&#x20;         ↓

进一步定位疾病相关基因及其空间分布



因此，当前项目属于后续研究工作的基础方法学习和流程验证阶段。



### 12\. 下一步计划



下一阶段首先完善标准 MR 分析流程：



GTEx eQTL

&#x20;   ↓

GWAS

&#x20;   ↓

SNP harmonisation

&#x20;   ↓

工具变量检查

&#x20;   ↓

IVW

&#x20;   ↓

其他 MR 方法

&#x20;   ↓

敏感性分析

&#x20;   ↓

结果解释



在完成组织水平 MR 流程后，再逐步进入：



cell-type eQTL

&#x20;       ↓

cell-type-specific MR

&#x20;       ↓

spatial transcriptomics



最终希望建立从遗传变异、基因表达、疾病表型到细胞类型和空间定位的完整分析框架。



### 13\. 项目定位



本项目当前主要用于：

学习孟德尔随机化方法；

熟悉 eQTL 与 GWAS 数据结构；

学习 OpenGWAS API 数据获取；

建立可复现的 R 分析流程；

为后续细胞类型特异性转录组和空间转录组研究建立基础。



当前结果属于方法学习和流程验证阶段，不应直接作为最终生物学结论。

