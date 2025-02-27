---
sidebar_position: 1
---

# 简介

## KCL 是什么?

[Kusion 配置语言（KCL）](https://github.com/kcl-lang/kcl) 是一个开源的基于约束的记录及函数语言。KCL 通过成熟的编程语言技术和实践来改进对大量繁杂配置比如云原生 Kubernetes 配置场景的编写，致力于构建围绕配置的更好的模块化、扩展性和稳定性，更简单的逻辑编写，以及更简单的自动化和生态工具集成。

## 为什么使用 KCL?

KCL 期望通过更现代化的声明式配置语言在 Kubernetes 资源管理解决如下问题：

+ 通过**代码抽象**等手段屏蔽基础设施和平台的细节，降低研发者负担
+ **编辑**和**校验**已有的存量配置或模版
+ 通过配置语言无副作用地管理跨团队的大规模配置数据，提升团队协作效率
  + 用**生产级高性能编程语言**以**编写代码**的方式提升配置的灵活度，比如条件语句、循环、函数、包管理等特性提升配置重用的能力
  + 在代码层面提升**配置语义验证**的能力，比如字段可选/必选、类型、范围等配置检查能力
  + 提供**配置分块编写、组合和抽象的能力**，比如结构定义、结构继承、约束定义等能力
  + 通过**多语言 SDK**，**KCL 语言插件**等手段提升其**自动化**集成能力

您可以将 KCL 用于

+ 生成静态配置数据如 JSON, YAML 等
+ 使用 schema 对配置数据进行建模并减少配置数据中的样板文件
+ 为配置数据定义带有规则约束的 schema 并对数据进行自动验证
+ 无副作用地组织、简化、统一和管理庞大的配置
+ 通过分块编写配置数据可扩展地管理庞大的配置
+ 与 [KusionStack](https://kusionstack.io) 一起，用作平台工程语言来交付现代应用程序

除了语言自身，KCL 还提供了许多额外的工具如格式化，测试、文档、包管理等工具帮助您使用、理解和检查编写的配置或策略；通过 VS Code 等 IDE 插件和 Playground 降低配置编写、分享的成本；通过 Rust, Go, 和 Python 多语言 SDK 自动化地管理和执行配置。

![](/img/docs/user_docs/intro/kcl-overview.png)

此外，KCL 是一种现代高级领域编程语言，并且它是一种编译静态的强类型语言。KCL 为开发人员提供了通过记录和函数语言设计将**配置（config）**、**建模抽象（schema）**、**逻辑（lambda）**和**策略（rule）**作为核心能力。

![](/img/docs/user_docs/intro/kcl-concepts.png)

KCL 试图提供独立于运行时的可编程性，不在本地提供线程和IO等系统功能，但支持云本地操作场景的功能，并试图为解决领域问题并提供稳定、安全、低噪声、低副作用、易于自动化和易于管理的编程支持。

总之，KCL 具备如下特点:

+ **简单易用**：源于 Python、Golang 等高级语言，采纳函数式编程语言特性，低副作用
+ **设计良好**：独立的 Spec 驱动的语法、语义、运行时和系统库设计
+ **快速建模**：以 [Schema](https://kcl-lang.io/docs/reference/lang/tour#schema) 为中心的配置类型及模块化抽象
+ **功能完备**：基于 [Config](https://kcl-lang.io/docs/reference/lang/tour#config-operations)、[Schema](https://kcl-lang.io/docs/reference/lang/tour#schema)、[Lambda](https://kcl-lang.io/docs/reference/lang/tour#function)、[Rule](https://kcl-lang.io/docs/reference/lang/tour#rule) 的配置及其模型、逻辑和策略编写
+ **可靠稳定**：依赖[静态类型系统](https://kcl-lang.io/docs/reference/lang/tour/#type-system)、[约束](https://kcl-lang.io/docs/reference/lang/tour/#validation)和[自定义规则](https://kcl-lang.io/docs/reference/lang/tour#rule)的配置稳定性
+ **强可扩展**：通过独立配置块[自动合并机制](https://kcl-lang.io/docs/reference/lang/tour/#-operators-1)保证配置编写的高可扩展性
+ **易自动化**：[CRUD APIs](https://kcl-lang.io/docs/reference/lang/tour/#kcl-cli-variable-override)，[多语言 SDK](https://kcl-lang.io/docs/reference/xlang-api/overview)，[语言插件](https://github.com/kcl-lang/kcl-plugin) 构成的梯度自动化方案
+ **极致性能**：使用 Rust & C，[LLVM](https://llvm.org/) 实现，支持编译到本地代码和 [WASM](https://webassembly.org/) 的高性能编译时和运行时
+ **API 亲和**：原生支持 [OpenAPI](https://github.com/kcl-lang/kcl-openapi)、 Kubernetes CRD， Kubernetes YAML 等 API 生态规范
+ **开发友好**：[语言工具](https://kcl-lang.io/docs/tools/cli/kcl/) (Format，Lint，Test，Vet，Doc 等)、 [IDE 插件](https://github.com/kcl-lang/vscode-kcl) 构建良好的研发体验
+ **安全可控**：面向领域，不原生提供线程、IO 等系统级功能，低噪音，低安全风险，易维护，易治理
+ **多语言API**：[Go](https://kcl-lang.io/docs/reference/xlang-api/go-api)，[Python](https://kcl-lang.io/docs/reference/xlang-api/python-api)，[Java](https://kcl-lang.io/docs/reference/xlang-api/java-api) 和 [REST API](https://kcl-lang.io/docs/reference/xlang-api/rest-api) 满足不同场景和应用使用需求
+ **生态集成**：通过 [Kustomize KCL 插件](https://github.com/kcl-lang/kustomize-kcl), [Helm KCL 插件](https://github.com/kcl-lang/helm-kcl) 或者 [KPT KCL SDK](https://github.com/kcl-lang/kpt-kcl-sdk) 直接编辑或校验资源
+ **生产可用**：广泛应用在蚂蚁集团平台工程及自动化的生产环境实践中

虽然 KCL 不是通用语言，但它有相应的应用场景。开发人员可以通过 KCL 编写**config**、**schema**、**function**和**rule**，其中 config 用于定义数据，schema 用于描述数据的模型定义，rule 用于验证数据，schema 和 rule 还可以组合使用模型和约束来充分描述数据。此外，还可以使用 KCL 中的 lambda 纯函数来组织数据代码，封装通用代码，并在需要时直接调用它。

下面是一个用 KCL 生成 kubernetes 资源的例子

```python
apiVersion = "apps/v1"
kind = "Deployment"
metadata = {
    name = "nginx"
    labels.app = name
}
spec = {
    replicas = 3
    selector.matchLabels = metadata.labels
    template.metadata.labels = metadata.labels
    template.spec.containers = [
        {
            name = metadata.name
            image = "${metadata.name}:1.14.2"
            ports = [{ containerPort = 80 }]
        }
    ]
}
```

我们可以使用上述 KCL 代码生成一个 Kubernetes YAML 配置

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

## 如何选择

目前社区已经进行了大量的尝试来改进其配置技术，主要可分为三类：

+ 用于模板、修补和验证的基于低级数据格式的工具，使用外部工具来增强重用和验证。
+ 领域特定语言（DSL）和配置语言（CL），以增强语言能力。
+ 基于通用语言（GPL）的解决方案，使用 GPL 的云开发工具包（CDK）或框架来定义配置。

简单的选择答案：

+ 如果您需要编写结构化的静态的 K-V，或使用 Kubernetes 原生的技术工具，建议选择 YAML。
+ 如果您希望引入编程语言便利性以消除文本(如 YAML、JSON) 模板，有良好的可读性，或者你已是 Terraform 的用户，建议选择 HCL。
+ 如果您希望引入类型功能提升稳定性，维护可扩展的配置文件，建议选择 CUE。
+ 如果您希望以现代语言方式编写复杂类型和建模，维护可扩展的配置文件，原生的纯函数和策略，和生产级的性能和自动化，建议直接选择 KCL 或将 KCL 用于对已有配置手段或工具进行增强。

### vs. YAML/JSON

YAML/JSON 适用于小型配置场景。对于需要频繁修改的大型云原生配置场景，它们更适合 KCL。所涉及的主要区别是配置数据抽象和部署之间的区别：

使用 KCL 进行配置的优点是：对于静态数据，抽象一层的优点意味着整个系统具有部署灵活性。不同的配置环境、租户和运行时可能对静态数据有不同的要求，甚至不同的组织可能有不同的规范和产品要求。KCL 可用于公开最需要的和经常修改的配置。

### vs. Jsonnet/GCL

GCL 是一种用 Python 实现的声明式配置语言，它提供了支持模板抽象的必要语言功能。然而 GCL 编译器本身是用Python编写的，且语言本身是解释执行的。对于大型模板实例（如 kubernetes 模型），性能较差。

Jsonnet 是一种用 C++ 实现的数据模板语言，适用于应用程序和工具开发人员，可以生成配置数据并通过代码组织、简化和管理大型配置，而不会产生副作用。

Jsonnet 和 GCL 非常擅长减少样板。它们都可以使用代码生成配置，就像工程师只需要编写高级 GPL 代码，而不是手动编写容易出错且难以理解的服务器二进制代码一样。Jsonnet 减少了 GCL 的一些复杂性，但在很大程度上属于同一类别。两者都有许多运行时错误，类型检查和约束能力不足。

### vs. HCL

HCL 是一种 Go 实现的结构化配置语言。HCL的原生语法受到libucl和nginx配置的启发。它用于创建一种对人类和机器友好的结构化配置语言，作为[Terraform语言](https://www.terraform.io/language)主要用于 DevOps工具、服务器配置和资源配置等。

HCL 与 GCL 有一些比较相似的地方。它确实引入了穷人版本的继承：文件覆盖。可以在多个文件中定义字段，这些文件按文件名的特定顺序被覆盖。虽然没有GCL那么复杂，但它确实存在一些相同的问题。模式是固定的，能力是有限的。

HCL 的用户界面不能通过 Terraform 提供者 Schema 定义直接感知。此外，在编写复杂对象和必需/可选字段定义时，用户界面很麻烦。动态参数受变量的条件字段约束。资源本身的约束需要由提供程序模式定义，或者与Sentinel/Rego 和其他策略语言相结合。语言本身的完整性不能自我封闭，其实现方法也不统一。

### vs. CUE

CUE 可以通过结构、无继承和其他特性用作建模，当模型定义之间没有冲突时可以实现高度抽象。因为 CUE 在运行时执行所有约束检查，所以它在大规模配置建模场景中可能存在性能瓶颈。CUE 将类型和值组合为一个概念，并通过各种语法简化了约束的编写。例如，不需要泛型类型和枚举，求和类型和空值合并是一回事。CUE 支持配置合并，但它是完全幂等的。它可能无法满足复杂的多租户和多环境配置场景的要求。对于复杂的循环和约束场景，编写起来很复杂，编写需要精确配置修改或者 Patch 的场景也很麻烦。

对于 KCL，建模是通过 KCL Schema 进行的，通过语言级工程和一些面向对象的特性（如单一继承、Mixin 复用）可以实现高模型抽象。KCL 是一种静态编译语言，用于大规模建模场景是运行时开销较低 (性能更高，更低的内存消耗)。KCL 提供了更丰富的检查声明性约束语法，这使得配置和策略编写更加容易。对于一些配置字段组合约束，它更容易编写（与 CUE 相比，KCL 提供了更多的 if-guard 组合约束、all/any/map/filter 表达式和其他集合约束编写方法，这使得编写更容易）。

### vs. Dhall

Dhall 是一种可编程配置语言，它组合了 JSON、函数、类型和 imports 导入等功能, 本身风格偏向函数式，如果您学过 haskell 等函数式风格语言，可能会对它感到熟悉的。相比于 Dhall, KCL 也提供了类似功能的组合，提供给用户配置可编程和抽象的能力，不过 KCL 在建模、约束检查、自动化等方面做了更多的改进，同时能够通过包管理手段进行模型共享。此外，KCL 的语法语义更贴近于面向对象语言，在一定程度上会比纯函数式风格接受程度更高。

### vs. Kustomize

Kustomize 的核心功能是其文件级覆盖功能。但是它存在多个覆盖链的问题，因为找到特定属性值的语句不能保证它是最终值，因为其他地方出现的另一个特定值可以覆盖它。对于复杂的场景，Kustomsize 文件的继承链的检索通常不如 KCL 代码的继承链检索方便，需要仔细考虑指定的配置文件覆盖顺序。此外，Kustomize 无法解决 YAML 配置编写、约束验证、模型抽象和开发等问题，更适合于简单的配置场景。

在 KCL 中，配置合并操作可以对代码中的每个配置属性进行细粒度处理，合并策略可以灵活设置，而不限于整体资源，配置之间的依赖关系可以通过KCL的import语句进行静态分析。

### vs. Helm

Helm 的概念源于操作系统的包管理机制。它是一个基于模板化 YAML 文件的包管理工具，支持包中资源的执行和管理。

KCL 自然提供了 Helm 功能的超集，因此您可以直接使用 KCL 作为替代。对于采用 Helm 的用户，KCL 中的堆栈编译结果可以打包并以 Helm 格式使用，通过 kpm 包管理工具进行分发复用。此外，我们还可以直接使用 Helm-KCL 插件直接对已有的 Helm Charts 进行无侵入的可编程扩展。

### vs. CDK

用CDK的高级语言编写可以很好地集成到应用程序项目中，这实际上是客户端运行时的一部分。对于KCL，由KCL编写的外部配置和策略与客户端运行时分离。

通用语言通常是过度的，也就是说，它远远超出了需要解决的问题。通用语言中存在各种安全问题，例如能力边界问题（启动本地线程、访问IO、网络、代码无限循环和其他安全风险）。例如，在音乐领域，有专门的音符来表达音乐，这便于学习和交流，它不能用一般语言表达清楚。

此外，由于通用语言风格多样，需要统一维护、管理和自动化。通用语言通常用于编写客户端运行时，它是服务器运行时的延续，不适合编写独立于运行时的配置，被编译成二进制文件，并最终从进程开始运行。此外，GPL 稳定性和可扩展性不易控制。然而，KCL 配置语言通常用于编写数据，将数据与简单逻辑相结合，它描述了预期的最终结果，然后由编译器或引擎使用，既具备丰富的编程抽象能力，又具备方便的数据处理方式。

### vs. OPA/Rego

Rego 起源于逻辑编程，它基于 Datalog，是一种受限制的 Prolog 形式，而 KCL 基于静态类型结构，具备部分 OOP 特性。Rego 类型化特征结构的设计是为了解决 Prolog 在人类语言编码应用中的缺点，将 Datalog 变量用于编程本质上是约束验证任务，Datalog 是一种优秀的查询语言。但对于约束强制执行，它有点麻烦，因为实际上首先需要查询要应用约束的值才能进行校验。

此外，KCL 的方法更易于找到规范化、简化、面向人类易读，面向运行时性能优良的约束和校验表示，具备静态类型，并且它更适合于从 OpenAPI 生成或者创建 OpenAPI。
