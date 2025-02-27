---
slug: 2022-declarative-config-overview
title: 声明式配置技术概述
authors:
  name: 徐鹏飞
  title: KCL 团队成员
tags: [KCL, Configuration]
---

## 零、前言

文本仅用于澄清声明式配置技术概述，[KCL](https://github.com/kcl-lang/kcl) 概念以及核心设计，以及与其他配置语言的对比。

## 一、声明式配置概述

### 1.1 配置的重要性

- 软件不是一成不变的，每天有成千上万的配置更新，并且配置本身也在逐渐演进，对规模化效率有较高的诉求
  - **配置更新越来越频繁**：配置提供了一种改变系统功能的低开销方式，不断发展的业务需求、基础设施要求和其他因素意味着系统需要不断变化。
  - **配置规模越来越大**：一份配置往往要分发到不同的云站点、不同的租户、不同的环境等。
  - **配置场景广泛**：应用配置、数据库配置、网络配置、监控配置等。
  - **配置格式繁多**：JSON, YAML, XML, TOML, 各种配置模版如 Java Velocity, Go Template 等。
- 配置的稳定性至关重要，系统宕机或出错的一个最主要原因是有大量工程师进行频繁的实时配置更新，表 1 示出了几个由于配置导致的系统出错事件。

| 时间 | 事件 |
| --- | --- |
| 2021 年 7 月 | 中国 Bilibili 公司由于 SLB Lua 配置计算出错陷入死循环导致网站宕机 |
| 2021 年 10 月 | 韩国 KT 公司由于路由配置错误导致在全国范围内遭受重大网络中断 |

表 1 配置导致的系统出错事件

### 1.2 声明式配置分类

云原生时代带来了如雨后春笋般的技术发展，出现了大量面向终态的声明式配置实践，如图 1 所示，声明式配置一般可分为如下几种方式。
![](/img/blog/2022-09-15-declarative-config-overview/01-declarative-config.png)
图 1 声明式配置方式分类

#### 1.2.1 结构化 (Structured) 的 KV

结构化的 KV 可以满足最小化数据声明需求，比如数字、字符串、列表和字典等数据类型，并且随着云原生技术快速发展应用，声明式 API 可以满足 X as Data 发展的诉求，并且面向机器可读可写，面向人类可读。其优劣如下:

- 优势
  - 语法简单，易于编写和阅读
  - 多语言 API 丰富
  - 有各种 Path 工具方便数据查询，如 XPath, JsonPath 等
- 痛点
  - 冗余信息多：当配置规模较大时，维护和阅读配置很困难，因为重要的配置信息被淹没在了大量不相关的重复细节中
  - 功能性不足
    - 约束校验能力
    - 复杂逻辑编写能力
    - 测试、调试能力
    - 不易抽象和复用
    - Kustomize 的 Patch 比较定制，基本是通过固定几种 Patch Merge 策略

结构化 KV 的代表技术有

- JSON/YAML：非常方便阅读，以及自动化处理，不同的语言均具有丰富的 API 支持。
- [Kustomize](https://kustomize.io/)：提供了一种无需**模板**和 **DSL** 即可自定义 Kubernetes 资源基础配置和差异化配置的解决方案，本身不解决约束的问题，需要配合大量的额外工具进行约束检查如 [Kube-linter](https://github.com/stackrox/kube-linter)、[Checkov](https://github.com/bridgecrewio/checkov) 等检查工具，图 2 示出了 Kustomize 的典型工作方式。

![](/img/blog/2022-09-15-declarative-config-overview/02-kustomize.png)
图 2 Kustomize 典型工作方式

#### 1.2.3 模版化 (Templated) 的 KV

模版化 (Templated) 的 KV 赋予静态配置数据动态参数的能力，可以做到一份模版+动态参数输出不同的静态配置数据。其优劣如下:

- 优势
  - 简单的配置逻辑，循环支持
  - 支持外部动态参数输入模版
- 痛点
  - 容易落入所有配置参数都是模版参数的陷阱
  - 当配置规模变大时，开发者和工具都难以维护和分析它们

模版化代表技术有:

- [Helm](https://helm.sh/)：Kubernetes 资源的包管理工具，通过配置模版管理 Kubernetes 资源配置。图 3 示出了一个 Helm Jekins Package ConfigMap 配置模版，可以看出这些模版本身都十分短小，可以书写简单的逻辑，适合 Kubernetes 基础组件固定的一系列资源配置通过包管理+额外的配置参数进行安装。相比于单纯的模版化的 KV，Helm 一定程度上提供了模版存储/引用和语义化版本管理的能力相比于 Kustomize 更适合管理外部 Charts, 但是在多环境、多租户的配置管理上不太擅长。

![](/img/blog/2022-09-15-declarative-config-overview/03-helm.png)

图 3 Helm Jekins Package ConfigMap 配置模版

- 其他各种配置模版：Java Velocity, Go Template 等文本模板引擎非常适合 HTML 编写模板。但是在配置场景中使用时，存在所有配置字段即模版参数的风险，开发者和工具都难以维护和分析它们。

#### 1.2.3 代码化 (Programmable) 的 KV

Configuration as Code (CaC), 使用代码产生配置，就像工程师们只需要写高级 GPL 代码，而不是手工编写容易出错而且难以理解的服务器二进制代码一样。配置变更同代码变更同样严肃地对待，同样可以执行单元测试、集成测试等。代码模块化和重用是维护配置代码比手动编辑 JSON/YAML 等配置文件更容易的一个关键原因。其优劣如下:

- 优势
  - 必要的编程能力（变量定义、逻辑判断、循环、断言等）
  - 代码模块化与抽象（支持定义数据模版，并用模版得到新的配置数据）
  - 可以抽象配置模版+并使用配置覆盖
- 痛点
  - 类型检查不足
  - 运行时错误
  - 约束能力不足

代码化 KV 的代表技术有:

- [GCL](https://github.com/rix0rrr/gcl)：一种 Python 实现的声明式配置编程语言，提供了必要的言能力支持模版抽象，但编译器本身是 Python 编写，且语言本身是解释执行，对于大的模版实例 (比如 K8s 型) 性能较差。
- [HCL](https://github.com/hashicorp/hcl)：一种 Go 实现结构化配置语言，原生语法受到 libuclnginx 配置等的启发，用于创建对人类和机器都友好的结构化配置语言，主要针对 devops 工具、服务器配置及 Terraform 中定义资源配置等。
- [Jsonnet](https://github.com/google/jsonnet)：一种 C++ 实现的数据模板语言，适用于应用程序工具开发人员，可以生成配置数据并且无副作用组织、简化、统一管理庞大的配置。

#### 1.2.4 类型化 (Typed) 的 KV

类型化的 KV，基于代码化 KV，多了类型检查和约束的能力，其优劣如下:

- 优势
  - 配置合并完全幂等，天然防止配置冲突
  - 丰富的配置约束语法用于编写约束
  - 将类型和值约束编写抽象为同一种形式，编写简单
  - 配置顺序无关
- 痛点
  - 图合并和幂等合并等概念复杂，用户理解成本较高
  - 类型和值混合定义提高抽象程度的同时提升了用户的理解成本，并且所有约束在运行时进行检查，大规模配置代码下有性能瓶颈
  - 对于想要配置覆盖、修改的多租户、多环境场景难以实现
  - 对于带条件的约束场景，定义和校验混合定义编写用户界面不友好

类型化 KV 的代表技术有:

- [CUE](https://github.com/cue-lang/cue)：CUE 解决的核心问题是“类型检查”，主要应用于配置约束校验场景及简单的云原生配置场景

#### 1.2.5 模型化 (Structural) 的 KV

模型化的 KV 在代码化和类型化 KV 的基础上以高级语言建模能力为核心描述，期望做到模型的快速编写与分发，其优劣如下:

- 优势
  - 引入可分块、可扩展的 KV 配置块编写方式
  - 类高级编程语言的编写、测试方式
  - 语言内置的强校验、强约束支持
  - 面向人类可读可写，面向机器部分可读可写
- 不足
  - 扩展新模型及生态构建需要一定的研发成本，或者使用工具对社区中已有的 JsonSchema 和 OpenAPI 模型进行模型转换、迁移和集成。

模型化 KV 的代表技术有:

- [KCL](https://github.com/kcl-lang/kcl)：一种 Rust 实现的声明式配置策略编程语言，把运维类研发统一为一种声明式的代码编写，可以针对差异化应用交付场景抽象出用户模型并添加相应的约束能力，期望借助可编程 DevOps 理念解决规模化运维场景中的配置策略编写的效率和可扩展性等问题。图 4 示出了一个 KCL 编写应用交付配置代码的典型场景

![](/img/blog/2022-09-15-declarative-config-overview/04-kcl-app-code.png)

图 4 使用 KCL 编写应用交付配置代码

### 1.3 不同声明式配置方式的选择标准与最佳实践

- 配置的规模：对于小规模的配置场景，完全可以使用 YAML/JSON 等配置，比如应用自身的简单配置，CI/CD 的配置。此外对于小规模配置场景存在的多环境、多租户等需求可以借助 Kustomize 的 overlay 能力实现简单配置的合并覆盖等操作。
- 模型抽象与约束的必要性：对于较大规模的配置场景特别是对多租户、多环境等有配置模型和运维特性研发和沉淀迫切需求的，可以使用代码化、类型化和模型化的 KV 方式。

此外，从不同声明式配置方式的使用场景出发

- 如果需要编写结构化的静态的 K-V，或使用 Kubernetes 原生的技术工具，建议选择 YAML
- 如果希望引入编程语言便利性以消除文本(如 YAML、JSON) 模板，有良好的可读性，或者已是 [Terraform](https://www.terraform.io) 的用户，建议选择 HCL
- 如果希望引入类型功能提升稳定性，维护可扩展的配置文件，建议选择 CUE 之类的数据约束语言
- 如果希望以现代语言方式编写复杂类型和建模，维护可扩展的配置文件，原生的纯函数和策略，和生产级的性能和自动化，建议选择 KCL

不同于社区中的其他同类型领域语言，KCL 是一种面向应用研发人员并采纳了现代语言设计和技术的静态强类型编译语言

> 注意，本文将不会讨论通用语言编写配置的情况，通用语言一般是 Overkill 的，即远远超过了需要解决的问题，通用语言存在各式各样的安全问题，比如能力边界问题 (启动本地线程、访问 IO, 网络，代码死循环等不安全隐患)，比如像音乐领域就有专门的音符去表示音乐，方便学习与交流，不是一般文字语言可以表述清楚的。
>
> 此外，通用语言因为本身就样式繁多，存在统一维护、管理和自动化的成本，通用语言一般用来编写客户端运行时，是服务端运行时的一个延续，不适合编写与运行时无关的配置，最终被编译为二进制从进程启动，稳定性和扩展性不好控制，而配置语言往往编写的是数据，再搭配以简单的逻辑，描述的是期望的最终结果，然后由编译器或者引擎来消费这个期望结果。

## 二、KCL 的核心设计与应用场景

Kusion 配置语言（KCL）是一个开源的基于约束的记录及函数语言。KCL 通过成熟的编程语言技术和实践来改进对大量繁杂配置的编写，致力于构建围绕配置的更好的模块化、扩展性和稳定性，更简单的逻辑编写，以及更快的自动化集成和良好的生态延展性。

KCL 的核心特性是其**建模**和**约束**能力，KCL 核心功能基本围绕 KCL 这个两个核心特性展开，此外 KCL 遵循以用户为中心的配置理念而设计其核心特性，可以从两个方面理解：

- **以领域模型为中心的配置视图**：借助 KCL 语言丰富的特性及 [KCL OpenAPI](https://kcl-lang.io/docs/tools/cli/openapi/) 等工具，可以将社区中广泛的、设计良好的模型直接集成到 KCL 中（比如 K8s 资源模型），用户也可以根据自己的业务场景设计、实现自己的 KCL 模型 (库) ，形成一整套领域模型架构交由其他配置终端用户使用。
- **以终端用户为中心的配置视图**：借助 KCL 的代码封装、抽象和复用能力，可以对模型架构进行进一步抽象和简化（比如将 K8s 资源模型抽象为以应用为核心的 Server 模型），做到**最小化终端用户配置输入**，简化用户的配置界面，方便手动或者使用自动化 API 对其进行修改。

不论是以何为中心的配置视图，对于代码而言（包括配置代码）都存在对配置数据约束的需求，比如类型约束、配置字段必选/可选约束、范围约束、不可变性约束等，这也是 KCL 致力于解决的核心问题之一。综上，KCL 是一个开源的基于约束和声明的函数式语言，KCL 主要包含如图 5 所示的核心特性：

![](/img/blog/2022-09-15-declarative-config-overview/05-kcl-core-feature.png)

图 5 KCL 核心特性

- **简单易用**：源于 Python、Golang 等高级语言，采纳函数式编程语言特性，低副作用
- **设计良好**：独立的 Spec 驱动的语法、语义、运行时和系统库设计
- **快速建模**：以 [Schema](https://kcl-lang.io/docs/reference/lang/tour#schema) 为中心的配置类型及模块化抽象
- **功能完备**：基于 [Config](https://kcl-lang.io/docs/reference/lang/tour#config-operations)、[Schema](https://kcl-lang.io/docs/reference/lang/tour#schema)、[Lambda](https://kcl-lang.io/docs/reference/lang/tour#function)、[Rule](https://kcl-lang.io/docs/reference/lang/tour#rule) 的配置及其模型、逻辑和策略编写
- **可靠稳定**：依赖[静态类型系统](https://kcl-lang.io/docs/reference/lang/tour/#type-system)、[约束](https://kcl-lang.io/docs/reference/lang/tour/#validation)和[自定义规则](https://kcl-lang.io/docs/reference/lang/tour#rule)的配置稳定性
- **强可扩展**：通过独立配置块[自动合并机制](https://kcl-lang.io/docs/reference/lang/tour/#-operators-1)保证配置编写的高可扩展性
- **易自动化**：[CRUD APIs](https://kcl-lang.io/docs/reference/lang/tour/#kcl-cli-variable-override)，[多语言 SDK](https://kcl-lang.io/docs/reference/xlang-api/overview)，[语言插件](https://github.com/kcl-lang/kcl-plugin) 构成的梯度自动化方案
- **极致性能**：使用 Rust & C，[LLVM](https://llvm.org/) 实现，支持编译到本地代码和 [WASM](https://webassembly.org/) 的高性能编译时和运行时
- **API 亲和**：原生支持 [OpenAPI](https://github.com/kcl-lang/kcl-openapi)、 Kubernetes CRD， Kubernetes YAML 等 API 生态规范
- **开发友好**：[语言工具](https://kcl-lang.io/docs/tools/cli/kcl/) (Format，Lint，Test，Vet，Doc 等)、 [IDE 插件](https://github.com/kcl-lang/vscode-kcl) 构建良好的研发体验
- **安全可控**：面向领域，不原生提供线程、IO 等系统级功能，低噪音，低安全风险，易维护，易治理
- **多语言API**：[Go](https://kcl-lang.io/docs/reference/xlang-api/go-api), [Python](https://kcl-lang.io/docs/reference/xlang-api/python-api) 和 [REST API](https://kcl-lang.io/docs/reference/xlang-api/rest-api) 满足不同场景和应用使用需求
- **生产可用**：广泛应用在蚂蚁集团平台工程及自动化的生产环境实践中

![](/img/blog/2022-09-15-declarative-config-overview/06-kcl-code-design.png)

图 6 KCL 语言核心设计

更多语言设计和能力详见 [KCL 文档](https://kcl-lang.io/docs/reference/lang/tour)，尽管 KCL 不是通用语言，但它有相应的应用场景，如图 6 所示，研发者可以通过 KCL 编写**配置(config)**、**模型(schema)**、**函数(lambda)**及**规则(rule)**，其中 Config 用于定义数据，Schema 用于对数据的模型定义进行描述，Rule 用于对数据进行校验，并且 Schema 和 Rule 还可以组合使用用于完整描述数据的模型及其约束，此外还可以使用 KCL 中的 lambda 纯函数进行数据代码组织，将常用代码封装起来,在需要使用时可以直接调用。

对于使用场景而言，KCL 可以进行结构化 KV 数据验证、复杂配置模型定义与抽象、强约束校验避免配置错误、分块编写及配置合并能力、自动化集成和工程扩展等能力，下面针对这些功能和使用场景进行阐述。

### 2.1 结构化 KV 数据验证

如图 7 所示，KCL 支持对 JSON/YAML 数据进行格式校验。作为一种配置语言，KCL 在验证方面几乎涵盖了 OpenAPI 校验的所有功能。在 KCL 中可以通过一个结构定义来约束配置数据，同时支持通过 check 块自定义约束规则，在 schema 中书写校验表达式对 schema 定义的属性进行校验和约束。通过 check 表达式可以非常清晰简单地校验输入的 JSON/YAML 是否满足相应的 schema 结构定义与 check 约束。

![](/img/blog/2022-09-15-declarative-config-overview/07-kcl-validation.png)

图 7 KCL 中结构化 KV 校验方式

基于此，KCL 提供了相应的[校验工具](https://kcl-lang.io/docs/tools/cli/kcl/vet)直接对 JSON/YAML 数据进行校验。此外，通过 KCL schema 的 check 表达式可以非常清晰简单地校验输入的 JSON 是否满足相应的 schema 结构定义与 check 约束。此外，基于此能力可以构建如图 8 所示的 KV 校验可视化产品。

![](/img/blog/2022-09-15-declarative-config-overview/08-kcl-validation-ui.png)

图 8 基于 KCL 结构化 KV 校验能力构建的可视化产品界面

### 2.2 复杂配置模型定义与抽象

如图 9 所示，借助 KCL 语言丰富的特性及 [KCL OpenAPI](https://kcl-lang.io/docs/tools/cli/openapi/) 等工具，可以将社区中广泛的、设计良好的模型直接集成到 KCL 中（比如 K8s 资源模型 CRD），用户也可以根据自己的业务场景设计、实现自己的 KCL 模型 (库) ，形成一整套领域模型架构交由其他配置终端用户使用。

![](/img/blog/2022-09-15-declarative-config-overview/09-kcl-modeling.png)

图 9 KCL 复杂配置建模的一般方式

基于此，可以像图 10 示出的那样用一个大的 [Konfig 仓库](https://github.com/KusionStack/konfig) 管理全部的 KCL 配置代码，将业务配置代码 (应用代码)、基础配置代码 (核心模型+底层模型)在一个大库中，方便代码间的版本依赖管理，自动化系统处理也比较简单，定位唯一代码库的目录及文件即可，代码互通，统一管理，便于查找、修改、维护，可以使用统一的 CI/CD 流程进行配置管理（此外，大库模式也是 Google 等头部互联网公司内部实践的模式）。

![](/img/blog/2022-09-15-declarative-config-overview/10-kcl-konfig.png)

图 10 使用 KCL 的语言能力集成领域模型并抽象用户模型并使用

### 2.3 强约束校验避免配置错误

如图 11 所示，在 KCL 中可以通过丰富的强约束校验手段避免配置错误：

![](/img/blog/2022-09-15-declarative-config-overview/11-kcl-constraint.png)

图 11 KCL 强约束校验手段

- KCL 语言的类型系统被设计为静态的，类型和值定义分离，支持编译时类型推导和类型检查，静态类型不仅仅可以提前在编译时分析大部分的类型错误，还可以降低后端运行时的动态类型检查的性能损耗。此外，KCL Schema 结构的属性强制为非空，可以有效避免配置遗漏。
- 当需要导出的 KCL 配置被声明之后，它们的类型和值均不能发生变化，这样的静态特性保证了配置不会被随意篡改。
- KCL 支持通过结构体内置的校验规则进一步保障稳定性。比如对于如图 12 所示的 KCL 代码，，在 `App` 中定义对 `containerPort`、`services`、`volumes` 的校验规则，目前校验规则在运行时执行判断，后续 KCL 会尝试通过编译时的静态分析对规则进行判断从而发现问题。

![](/img/blog/2022-09-15-declarative-config-overview/12-kcl-app-schema.png)

图 12 带规则约束的 KCL 代码校验

### 2.4 分块编写及配置合并

KCL 提供了配置分块编写及自动合并配置的能力，并且支持幂等合并、补丁合并和唯一配置合并等策略。幂等合并中的多份配置需要满足交换律，并且需要开发人员手动处理基础配置和不同环境配置冲突。 补丁合并作为一个覆盖功能，包括覆盖、删除和添加。唯一的配置要求配置块是全局唯一的并且未修改或以任何形式重新定义。 KCL 通过多种合并策略简化了用户侧的协同开发，减少了配置之间的耦合。

如图 13 所示，对于存在基线配置、多环境和多租户的应用配置场景，有一个基本配置 base.k。 开发和 SRE 分别维护生产和开发环境的配置 base.k 和 prod.k，他们的配置互不影响，由 KCL 编译器合并成一个 prod 环境的等效配置代码。

![](/img/blog/2022-09-15-declarative-config-overview/13-kcl-isolated-config.png)

图 13 多环境场景配置分块编写实例

### 2.5 自动化集成

在 KCL 中提供了很多自动化相关的能力，主要包括工具和多语言 API。 通过 `package_identifier : key_identifier`的模式支持对任意配置键值的索引，从而完成对任意键值的增删改查。比如图 14 所示修改某个应用配置的镜像内容，可以直接执行如下指令修改镜像，修改前后的 diff 如下图所示。

![](/img/blog/2022-09-15-declarative-config-overview/14-kcl-image-update.png)

图 14 使用 KCL CLI/API 自动修改应用配置镜像

此外，可以基于 KCL 的自动化能力实现如图 15 所示的一镜交付及自动化运维能力并集成到 CI/CD 当中。

![](/img/blog/2022-09-15-declarative-config-overview/15-kcl-automation.png)

图 15 典型 KCL 自动化集成链路

## 三、KCL 与其他声明式配置的对比

### 3.1 vs. JSON/YAML

YAML/JSON 配置等适合小规模的配置场景，对于大规模且需要频繁修改的云原生配置场景，比较适合 KCL 比较适合，其中涉及到主要差异是配置数据抽象与展开的差异：

- 对于 JSON/YAML 等静态配置数据展开的好处是：简单、易读、易于处理，但是随着静态配置规模的增加，当配置规模较大时，JSON/YAML 等文件维护和阅读配置很困难，因为重要的配置信息被**淹没在了大量不相关的重复细节**中。
- 对于使用 KCL 语言进行配置抽象的好处是：对于静态数据，抽象一层的好处这意味着整体系统具有**部署的灵活性**，不同的配置环境、配置租户、运行时可能会对静态数据具有不同的要求，甚至不同的组织可能有不同的规范和产品要求，可以使用 KCL 将最需要、最常修改的配置暴露给用户，对差异化的配置进行抽象，抽象的好处是可以支持不同的配置需求。并且借助 KCL 语言级别的自动化集成能力，还可以很好地支持不同的语言，不同的配置 UI 等。

### 3.2 vs. Kustomize

Kustomize 的核心能力是其 Overlay 能力，并 Kustomize 支持文件级的覆盖，但是存在会存在多个覆盖链条的问题，因为找到具体字段值的声明并不能保证这是最终值，因为其他地方出现的另一个具体值可以覆盖它，对于复杂的场景，Kustomize 文件的继承链检索往往不如 KCL 代码继承链检索方便，需要仔细考虑指定的配置文件覆盖顺序。此外，Kustomize 不能解决 YAML 配置编写、配置约束校验和模型抽象与开发等问题，较为适用于简单的配置场景，当配置组件增多时，对于配置的修改仍然会陷入大量重复不相关的配置细节中，并且在 IDE 中不能很好地显示配置之间的依赖和覆盖关系情况，只能通过搜索/替换等批量修改配置。

在 KCL 中，配置合并的操作可以细粒度到代码中每一个配置字段，并且可以灵活的设置合并策略，并不局限于资源整体，并且通过 KCL 的 import 可以静态分析出配置之间的依赖关系。

### 3.3 vs. HCL

#### 3.3.1 功能对比

|  | HCL | KCL |
| --- | --- | --- |
| 建模能力 | 通过 Terraform Go Provider Schema 定义，在用户界面不直接感知，此外编写复杂的 object 和必选/可选字段定义时用户界面较为繁琐 | 通过 KCL Schema 进行建模，通过语言级别的工程和部分面向对象特性，可以实现较高的模型抽象 |
| 约束能力 | 通过 Variable 的 condition 字段对动态参数进行约束，Resource 本身的约束需要通过 Go Provider Schema 定义或者结合 Sentinel/Rego 等策略语言完成，语言本身的完整能力不能自闭环，且实现方式不统一 | 以 Schema 为核心，在进行建模的同时定义其约束，在 KCL 内部自闭环并一统一方式实现，支持多种约束函数编写，支持可选/必选字段定义 |
| 扩展性 | Terraform HCL 通过分文件进行 Override, 模式比较固定，能力受限。| KCL 可以自定义配置分块编写方式和多种合并策略，可以满足复杂的多租户、多环境配置场景需求 |
| 语言化编写能力 | 编写复杂的对象定义和必选/可选字段定义时用户界面较为繁琐 | 复杂的结构定义、约束场景编写简单，不借助其他外围 GPL 或工具，语言编写自闭环 |

#### 3.3.2 举例

**Terraform HCL Variable 约束校验编写 vs. KCL Schema 声明式约束校验编写**

- HCL

```python
variable "subnet_delegations" {
  type = list(object({
    name               = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default     = null
  validation {
    condition = var.subnet_delegations == null ? true : alltrue([for d in var.subnet_delegations : (d != null)])
  }
  validation {
    condition = var.subnet_delegations == null ? true : alltrue([for n in var.subnet_delegations.*.name : (n != null)])
  }
  validation {
    condition = var.subnet_delegations == null ? true : alltrue([for d in var.subnet_delegations.*.service_delegation : (d != null)])
  }
  validation {
    condition = var.subnet_delegations == null ? true : alltrue([for n in var.subnet_delegations.*.service_delegation.name : (n != null)])
  }
}
```

- KCL

```python
schema SubnetDelegation:
    name: str
    service_delegation: ServiceDelegation

schema ServiceDelegation:
    name: str
    actions?: [str]  # 使用 ? 标记可选属性

subnet_delegations: [SubnetDelegation] = option("subnet_delegations")
```

此外，KCL 还可以像高级语言一样写类型，写继承，写内置的约束，这些功能是 HCL 所不具备的

**Terraform HCL 函数 vs. KCL Lambda 函数编写**

- 正如 [https://www.terraform.io/language/functions](https://www.terraform.io/language/functions) 文档和 [https://github.com/hashicorp/terraform/issues/27696](https://github.com/hashicorp/terraform/issues/27696) 中展示的那样，Terraform HCL 提供了丰富的内置函数用于提供，但是并不支持用户在 Terraform 中使用 HCL 自定义函数 (或者需要编写复杂的 Go Provider 来模拟一个用户的本地自定义函数)；而 KCL 不仅支持用户使用 lambda 关键字直接在 KCL 代码中自定义函数，还支持使用 Python, Go 等语言为 KCL [编写插件函数](https://kcl-lang.io/docs/reference/plugin/overview)

- KCL 自定义定义函数并调用

```python
add_func = lambda x: int, y: int -> int {
    x + y
}
two = add_func(1, 1)  # 2
```

**HCL 删除 null 值与 KCL 使用 -n 编译参数删除 null 值**

- HCL

```python
variable "conf" {
  type = object({
    description = string
    name        = string
    namespace   = string
    params = list(object({
      default     = optional(string)
      description = string
      name        = string
      type        = string
    }))
    resources = optional(object({
      inputs = optional(list(object({
        name = string
        type = string
      })))
      outputs = optional(list(object({
        name = string
        type = string
      })))
    }))
    results = optional(list(object({
      name        = string
      description = string
    })))
    steps = list(object({
      args    = optional(list(string))
      command = optional(list(string))
      env = optional(list(object({
        name  = string
        value = string
      })))
      image = string
      name  = string
      resources = optional(object({
        limits = optional(object({
          cpu    = string
          memory = string
        }))
        requests = optional(object({
          cpu    = string
          memory = string
        }))
      }))
      script     = optional(string)
      workingDir = string
    }))
  })
}

locals {
  conf = merge(
    defaults(var.conf, {}),
    { for k, v in var.conf : k => v if v != null },
    { resources = { for k, v in var.conf.resources : k => v if v != null } },
    { steps = [for step in var.conf.steps : merge(
      { resources = {} },
      { for k, v in step : k => v if v != null },
    )] },
  )
}
```

- KCL (编译参数添加 -n 忽略 null 值)

```python
schema Param:
    default?: str
    name: str

schema Resource:
    cpu: str
    memory: str

schema Step:
    args?: [str]
    command?: [str]
    env?: {str:str}
    image: str
    name: str
    resources?: {"limits" | "requests": Resource}
    script?: str
    workingDir: str

schema K8sManifest:
    name: str
    namespace: str
    params: [Param]
    results?: [str]
    steps: [Step]

conf: K8sManifest = option("conf")
```

综上可以看出，在 KCL 中，通过 Schema 来声明方式定义其类型和约束，可以看出相比于 Terraform HCL, 在实现相同功能的情况下，KCL 的约束可以编写的更加简单 (不需要像 Terraform 那样重复地书写 validation 和 condition 字段)，并且额外提供了字段设置为可选的能力 (`?`运算符，不像 Terraform 配置字段默认可空，KCL Schema 字段默认必选)，结构更加分明，并且可以在代码层面直接获得类型检查和约束校验的能力。

### 3.4 vs. CUE

#### 3.4.1 功能对比

|  | CUE | KCL |
| --- | --- | --- |
| 建模能力 | 通过 Struct 进行建模，无继承等特性，当模型定义之间无冲突时可以实现较高的抽象。由于 CUE 在运行时进行所有的约束检查，在大规模建模场景可能存在性能瓶颈 | 通过 KCL Schema 进行建模，通过语言级别的工程和部分面向对象特性（如单继承），可以实现较高的模型抽象。 KCL 是静态编译型语言，对于大规模建模场景开销较小 |
| 约束能力 | CUE 将类型和值合并到一个概念中，通过各种语法简化了约束的编写，比如不需要泛型和枚举，求和类型和空值合并都是一回事 | KCL 提供了跟更丰富的 check 声明式约束语法，编写起来更加容易，对于一些配置字段组合约束编写更加简单（能力上比 CUE 多了 if guard 组合约束，all/any/map/filter 等集合约束编写方式，编写更加容易） |
| 分块编写能力 | 支持语言内部配置合并，CUE 的配置合并是完全幂等的，对于满足复杂的多租户、多环境配置场景的覆盖需求可能无法满足 | KCL 可以自定义配置分块编写方式和多种合并策略，KCL 同时支持幂等和非幂等的合并策略,可以满足复杂的多租户、多环境配置场景需求 |
| 语言化编写能力 | 对于复杂的循环、条件约束场景编写复杂，对于需要进行配置精确修改的编写场景较为繁琐 | 复杂的结构定义、循环、条件约束场景编写简单 |

#### 3.4.2 举例

**CUE 约束校验编写 vs. KCL Schema 声明式约束校验编写及配置分块编写能力**

CUE (执行命令 `cue export base.cue prod.cue`)

- base.cue

```cue
// base.cue
import "list"

#App: {
    domainType: "Standard" | "Customized" | "Global",
    containerPort: >=1 & <=65535,
    volumes: [...#Volume],
    services: [...#Service],
}

#Service: {
    clusterIP: string,
    type: string,

    if type == "ClusterIP" {
        clusterIP: "None"
    }
}

#Volume: {
    container: string | *"*"  // The default value of `container` is "*"
    mountPath: string,
    _check: false & list.Contains(["/", "/boot", "/home", "dev", "/etc", "/root"], mountPath),
}

app: #App & {
    domainType: "Standard",
    containerPort: 80,
    volumes: [
        {
            mountPath: "/tmp"
        }
    ],
    services: [
        {
            clusterIP: "None",
            type: "ClusterIP"
        }
    ]
}

```

- prod.cue

```python
// prod.cue
app: #App & {
    containerPort: 8080,  // error: app.containerPort: conflicting values 8080 and 80:
}
```

KCL (执行命令 `kcl base.k prod.k`)

- base.k

```python
# base.k
schema App:
    domainType: "Standard" | "Customized" | "Global"
    containerPort: int
    volumes: [Volume]
    services: [Service]

    check:
        1 <= containerPort <= 65535

schema Service:
    clusterIP: str
    $type: str

    check:
        clusterIP == "None" if $type == "ClusterIP"

schema Volume:
    container: str = "*"  # The default value of `container` is "*"
    mountPath: str

    check:
        mountPath not in ["/", "/boot", "/home", "dev", "/etc", "/root"]

app: App {
    domainType = "Standard"
    containerPort = 80
    volumes = [
        {
            mountPath = "/tmp"
        }
    ]
    services = [
        {
            clusterIP = "None"
            $type = "ClusterIP"
        }
    ]
}

```

- prod.k

```python
# prod.k
app: App {
    # 可以使用 = 属性运算符对 base app 的 containerPort 进行修改
    containerPort = 8080
    # 可以使用 += 属性运算符对 base app 的 volumes 进行添加
    # 此处表示在 prod 环境增加一个 volume, 一共两个 volume
    volumes += [
        {
            mountPath = "/tmp2"
        }
    ]
}
```

此外由于 CUE 的幂等合并特性，在场景上并无法使用类似 kustomize 的 overlay 配置覆盖和 patch 等能力，比如上述的 base.cue 和 prod.cue 一起编译会报错。

### 3.5 Performance

在代码规模较大或者计算量较高的场景情况下 KCL 比 CUE/Jsonnet/HCL 等语言性能更好 (CUE 等语言受限于运行时约束检查开销，而 KCL 是一个静态编译型语言)

- CUE (test.cue)

```cue
import "list"

temp: {
        for i, _ in list.Range(0, 10000, 1) {
                "a\(i)": list.Max([1, 2])
        }
}
```

- KCL (test.k)

```python
a = lambda x: int, y: int -> int {
    max([x, y])
}
temp = {"a${i}": a(1, 2) for i in range(10000)}
```

- Jsonnet (test.jsonnet)

```jsonnet
local a(x, y) = std.max(x, y);
{
    temp: {["a%d" % i]: a(1, 2) for i in std.range(0, 10000)},
}
```

- Terraform HCL (test.tf, 由于 terraform range 函数只支持最多 1024 个迭代器，将 range(10000) 拆分为 10 个子 range)

```python
output "r1" {
  value = {for s in range(0, 1000) : format("a%d", s) => max(1, 2)}
}
output "r2" {
  value = {for s in range(1000, 2000) : format("a%d", s) => max(1, 2)}
}
output "r3" {
  value = {for s in range(1000, 2000) : format("a%d", s) => max(1, 2)}
}
output "r4" {
  value = {for s in range(2000, 3000) : format("a%d", s) => max(1, 2)}
}
output "r5" {
  value = {for s in range(3000, 4000) : format("a%d", s) => max(1, 2)}
}
output "r6" {
  value = {for s in range(5000, 6000) : format("a%d", s) => max(1, 2)}
}
output "r7" {
  value = {for s in range(6000, 7000) : format("a%d", s) => max(1, 2)}
}
output "r8" {
  value = {for s in range(7000, 8000) : format("a%d", s) => max(1, 2)}
}
output "r9" {
  value = {for s in range(8000, 9000) : format("a%d", s) => max(1, 2)}
}
output "r10" {
  value = {for s in range(9000, 10000) : format("a%d", s) => max(1, 2)}
}
```

- 运行时间（考虑到生产环境的实际资源开销，本次测试以单核为准）

| 环境 | KCL v0.4.3 运行时间 (包含编译+运行时间) | CUE v0.4.3 运行时间 (包含编译+运行时间) | Jsonnet v0.18.0 运行时间 (包含编译+运行时间) | HCL in Terraform v1.3.0 运行时间 (包含编译+运行时间) |
| --- | --- | --- | --- | --- |
| OS: macOS 10.15.7; CPU: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz; Memory: 32 GB 2400 MHz DDR4; 不开启 NUMA | 440 ms (kcl test.k) | 6290 ms (cue export test.cue) | 3340 ms (jsonnet test.jsonnet) | 1774 ms (terraform plan -parallelism=1)|

综上可以看出：CUE 和 KCL 均可以覆盖到绝大多数配置校验场景，并且均支持属性类型定义、配置默认值、约束校验等编写，但是 CUE 对于不同的约束条件场景无统一的写法，且不能很好地透出校验错误，KCL 使用 check 关键字作统一处理，支持用户自定义错误输出。

#### 另一个复杂的例子

使用 KCL 和 CUE 编写 Kubernetes 配置

- CUE (test.cue)

```cue
package templates

import (
 apps "k8s.io/api/apps/v1"
)

deployment: apps.#Deployment

deployment: {
 apiVersion: "apps/v1"
 kind:       "Deployment"
 metadata: {
  name:   "me"
  labels: me: "me"
 }
}
```

- KCL (test.k)

```python
import kubernetes.api.apps.v1

deployment = v1.Deployment {
    metadata.name = "me"
    metadata.labels.name = "me"
}
```

| 环境 | KCL v0.4.3 运行时间 (包含编译+运行时间) | CUE v0.4.3 运行时间 (包含编译+运行时间) |
| --- | --- | --- |
| OS: macOS 10.15.7; CPU: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz; Memory: 32 GB 2400 MHz DDR4; no NUMA | 140 ms (kcl test.k) | 350 ms (cue export test.cue) |

## 四、小结

文本对声明式配置技术做了整体概述，其中重点阐述了 KCL 概念、核心设计、使用场景以及与其他配置语言的对比，期望帮助大家更好的理解声明式配置技术及 KCL 语言。更多 KCL 的概念、背景、设计与用户案例等相关内容，欢迎访问 [KCL 网站](https://kcl-lang.io/)

## 五、参考

- KusionStack Cloud Native Configuration Practice Blog: [https://kusionstack.io/blog/2021-kusion-intro](https://kusionstack.io/blog/2021-kusion-intro)
- Terraform Language: [https://www.terraform.io/language](https://www.terraform.io/language)
- Terraform Provider Kubernetes: [https://github.com/hashicorp/terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes)
- Terraform Provider AWS: [https://github.com/hashicorp/terraform-provider-aws](https://github.com/hashicorp/terraform-provider-aws)
- Pulumi: [https://www.pulumi.com/docs/](https://www.pulumi.com/docs/)
- Pulumi vs. Terraform: [https://www.pulumi.com/docs/intro/vs/terraform/](https://www.pulumi.com/docs/intro/vs/terraform/)
- Google SRE Work Book Configuration Design: [https://sre.google/workbook/configuration-design/](https://sre.google/workbook/configuration-design/)
- Google Borg Paper: [https://storage.googleapis.com/pub-tools-public-publication-data/pdf/43438.pdf](https://storage.googleapis.com/pub-tools-public-publication-data/pdf/43438.pdf)
- Holistic Configuration Management at Facebook: [https://sigops.org/s/conferences/sosp/2015/current/2015-Monterey/printable/008-tang.pdf](https://sigops.org/s/conferences/sosp/2015/current/2015-Monterey/printable/008-tang.pdf)
- JSON Spec: [https://www.json.org/json-en.html](https://www.json.org/json-en.html)
- YAML Spec: [https://yaml.org/spec/](https://yaml.org/spec/)
- GCL: [https://github.com/rix0rrr/gcl](https://github.com/rix0rrr/gcl)
- HCL: [https://github.com/hashicorp/hcl](https://github.com/hashicorp/hcl)
- CUE: [https://github.com/cue-lang/cue](https://github.com/cue-lang/cue)
- Jsonnet: [https://github.com/google/jsonnet](https://github.com/google/jsonnet)
- Dhall: [https://github.com/dhall-lang/dhall-lang](https://github.com/dhall-lang/dhall-lang)
- Thrift: [https://github.com/Thriftpy/thriftpy2](https://github.com/Thriftpy/thriftpy2)
- Kustomize: [https://kustomize.io/](https://kustomize.io/)
- Kube-linter: [https://github.com/stackrox/kube-linter](https://github.com/stackrox/kube-linter)
- Checkov: [https://github.com/bridgecrewio/checkov](https://github.com/bridgecrewio/checkov)
- KCL Documents: [https://kcl-lang.io/docs/reference/lang/tour](https://kcl-lang.io/docs/reference/lang/tour)
- How Terraform Works: A Visual Intro: [https://betterprogramming.pub/how-terraform-works-a-visual-intro-6328cddbe067](https://betterprogramming.pub/how-terraform-works-a-visual-intro-6328cddbe067) 
- How Terraform Works: Modules Illustrated: [https://awstip.com/terraform-modules-illustrate-26cbc48be83a](https://awstip.com/terraform-modules-illustrate-26cbc48be83a)
- Helm: [https://helm.sh/](https://helm.sh/)
- Helm vs. Kustomize: [https://harness.io/blog/helm-vs-kustomize](https://harness.io/blog/helm-vs-kustomize)
- KubeVela: [https://kubevela.io/docs/](https://kubevela.io/docs/)
