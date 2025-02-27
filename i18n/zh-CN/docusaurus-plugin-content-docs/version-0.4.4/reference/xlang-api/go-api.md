---
sidebar_position: 3
---

# Go API

```go
import "github.com/kcl-lang/kcl-go"
```

## KCL Go SDK

```
┌─────────────────┐         ┌─────────────────┐           ┌─────────────────┐
│     kcl files   │         │    KCL-Go-API   │           │  KCLResultList  │
│  ┌───────────┐  │         │                 │           │                 │
│  │    1.k    │  │         │                 │           │                 │
│  └───────────┘  │         │                 │           │  ┌───────────┐  │         ┌───────────────┐
│  ┌───────────┐  │         │  ┌───────────┐  │           │  │ KCLResult │──┼────────▶│x.Get("a.b.c") │
│  │    2.k    │  │         │  │ Run(path) │  │           │  └───────────┘  │         └───────────────┘
│  └───────────┘  │────┐    │  └───────────┘  │           │                 │
│  ┌───────────┐  │    │    │                 │           │  ┌───────────┐  │         ┌───────────────┐
│  │    3.k    │  │    │    │                 │           │  │ KCLResult │──┼────────▶│x.Get("k", &v) │
│  └───────────┘  │    │    │                 │           │  └───────────┘  │         └───────────────┘
│  ┌───────────┐  │    ├───▶│  ┌───────────┐  │──────────▶│                 │
│  │setting.yml│  │    │    │  │RunFiles() │  │           │  ┌───────────┐  │         ┌───────────────┐
│  └───────────┘  │    │    │  └───────────┘  │           │  │ KCLResult │──┼────────▶│x.JSONString() │
└─────────────────┘    │    │                 │           │  └───────────┘  │         └───────────────┘
                       │    │                 │           │                 │
┌─────────────────┐    │    │                 │           │  ┌───────────┐  │         ┌───────────────┐
│     Options     │    │    │  ┌───────────┐  │           │  │ KCLResult │──┼────────▶│x.YAMLString() │
│WithOptions      │    │    │  │MustRun()  │  │           │  └───────────┘  │         └───────────────┘
│WithOverrides    │────┘    │  └───────────┘  │           │                 │
│WithWorkDir      │         │                 │           │                 │
│WithDisableNone  │         │                 │           │                 │
└─────────────────┘         └─────────────────┘           └─────────────────┘
```

<details><summary>Example</summary>
<p>

```go
{
	const k_code = `
import kcl_plugin.hello

name = "kcl"
age = 1

two = hello.add(1, 1)

schema Person:
    name: str = "kcl"
    age: int = 1

x0 = Person {}
x1 = Person {
	age = 101
}
`

	yaml := kclvm.MustRun("testdata/main.k", kclvm.WithCode(k_code)).First().YAMLString()
	fmt.Println(yaml)

	fmt.Println("----")

	result := kclvm.MustRun("./testdata/main.k").First()
	fmt.Println(result.JSONString())

	fmt.Println("----")
	fmt.Println("x0.name:", result.Get("x0.name"))
	fmt.Println("x1.age:", result.Get("x1.age"))

	fmt.Println("----")

	var person struct {
		Name string
		Age  int
	}
	fmt.Printf("person: %+v\n", result.Get("x1", &person))
}
```

</p>
</details>

## Index

- [Go API](#go-api)
	- [KCL Go SDK](#kcl-go-sdk)
	- [Index](#index)
	- [func FormatCode](#func-formatcode)
			- [Output](#output)
	- [func FormatPath](#func-formatpath)
	- [func InitKclvmRuntime](#func-initkclvmruntime)
	- [func LintPath](#func-lintpath)
			- [Output](#output-1)
	- [func OverrideFile](#func-overridefile)
	- [func RunPlayground](#func-runplayground)
	- [func ValidateCode](#func-validatecode)
	- [type KCLResult](#type-kclresult)
			- [Output](#output-2)
			- [Output](#output-3)
		- [func EvalCode](#func-evalcode)
	- [type KCLResultList](#type-kclresultlist)
		- [func MustRun](#func-mustrun)
			- [Output](#output-4)
		- [func Run](#func-run)
			- [Output](#output-5)
		- [func RunFiles](#func-runfiles)
	- [type KclType](#type-kcltype)
		- [func GetSchemaType](#func-getschematype)
	- [type Option](#type-option)
		- [func WithCode](#func-withcode)
		- [func WithDisableNone](#func-withdisablenone)
		- [func WithKFilenames](#func-withkfilenames)
		- [func WithOptions](#func-withoptions)
			- [Output](#output-6)
		- [func WithOverrides](#func-withoverrides)
		- [func WithPrintOverridesAST](#func-withprintoverridesast)
		- [func WithSettings](#func-withsettings)
		- [func WithWorkDir](#func-withworkdir)
	- [type ValidateOptions](#type-validateoptions)


## func [FormatCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L98>)

```go
func FormatCode(code interface{}) ([]byte, error)
```

FormatCode returns the formatted code\.

<details><summary>Example</summary>
<p>

```go
{
	out, err := kclvm.FormatCode(`a  =  1+2`)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(out))

}
```

#### Output

```
a = 1 + 2
```

</p>
</details>

## func [FormatPath](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L110>)

```go
func FormatPath(path string) (changedPaths []string, err error)
```

FormatPath formats files from the given path path: if path is \`\.\` or empty string\, all KCL files in current directory will be formatted\, not recursively if path is \`path/file\.k\`\, the specified KCL file will be formatted if path is \`path/to/dir\`\, all KCL files in the specified dir will be formatted\, not recursively if path is \`path/to/dir/\.\.\.\`\, all KCL files in the specified dir will be formatted recursively

the returned changedPaths are the changed file paths \(relative path\)

<details><summary>Example</summary>
<p>

```go
{
	changedPaths, err := kclvm.FormatPath("testdata/fmt")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(changedPaths)
}
```

</p>
</details>

## func [InitKclvmRuntime](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L52>)

```go
func InitKclvmRuntime(n int)
```

InitKclvmRuntime init kclvm process\.

## func [LintPath](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L115>)

```go
func LintPath(path string) (results []string, err error)
```

LintPath lint files from the given path

<details><summary>Example</summary>
<p>

```go
{

	results, err := kclvm.LintPath("testdata/lint/import.k")
	if err != nil {
		log.Fatal(err)
	}
	for _, s := range results {
		fmt.Println(s)
	}

}
```

#### Output

```
Unable to import abc.
a is reimported multiple times.
a imported but unused.
```

</p>
</details>

## func [OverrideFile](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L124>)

```go
func OverrideFile(file string, specs []string) (bool, error)
```

OverrideFile rewrites a file with override spec file: string\. The File that need to be overridden specs: \[\]string\. List of specs that need to be overridden\. Each spec string satisfies the form: \<pkgpath\>:\<field\_path\>=\<filed\_value\> or \<pkgpath\>:\<field\_path\>\- When the pkgpath is '\_\_main\_\_'\, it can be omitted\.

## func [RunPlayground](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L150>)

```go
func RunPlayground(address string) error
```

RunPlayground start KCL playground on given address\.

<details><summary>Example</summary>
<p>

```go
{
	addr := "localhost:2022"
	fmt.Printf("listen at http://%s\n", addr)

	kclvm.RunPlayground(addr)
}
```

</p>
</details>

## func [ValidateCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L129>)

```go
func ValidateCode(data, code string, opt *ValidateOptions) (ok bool, err error)
```

ValidateCode validate data match code

## type [KCLResult](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L45>)

```go
type KCLResult = kcl.KCLResult
```

<details><summary>Example</summary>
<p>

```go
{
	const k_code = `
import kcl_plugin.hello

name = "kcl"
age = 1
	
two = hello.add(1, 1)
	
schema Person:
    name: str = "kcl"
    age: int = 1

x0 = Person {name = "kcl-go"}
x1 = Person {age = 101}
`

	result := kclvm.MustRun("testdata/main.k", kclvm.WithCode(k_code)).First()

	fmt.Println("x0.name:", result.Get("x0.name"))
	fmt.Println("x1.age:", result.Get("x1.age"))

}
```

#### Output

```
x0.name: kcl-go
x1.age: 101
```

</p>
</details>

<details><summary>Example ('et_struct)</summary>
<p>

```go
{
	const k_code = `
schema Person:
    name: str = "kcl"
    age: int = 1
    X: int = 2

x = {
    "a": Person {age = 101}
    "b": 123
}
`

	result := kclvm.MustRun("testdata/main.k", kclvm.WithCode(k_code)).First()

	var person struct {
		Name string
		Age  int
	}
	fmt.Printf("person: %+v\n", result.Get("x.a", &person))
	fmt.Printf("person: %+v\n", person)

}
```

#### Output

```
person: &{Name:kcl Age:101}
person: {Name:kcl Age:101}
```

</p>
</details>

### func [EvalCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L133>)

```go
func EvalCode(code string) (*KCLResult, error)
```

## type [KCLResultList](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L46>)

```go
type KCLResultList = kcl.KCLResultList
```

### func [MustRun](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L57>)

```go
func MustRun(path string, opts ...Option) *KCLResultList
```

MustRun is like Run but panics if return any error\.

<details><summary>Example</summary>
<p>

```go
{
	yaml := kclvm.MustRun("testdata/main.k", kclvm.WithCode(`name = "kcl"`)).First().YAMLString()
	fmt.Println(yaml)

}
```

#### Output

```
name: kcl
```

</p>
</details>

<details><summary>Example (Settings)</summary>
<p>

```go
{
	yaml := kclvm.MustRun("./testdata/app0/kcl.yaml").First().YAMLString()
	fmt.Println(yaml)
}
```

</p>
</details>

### func [Run](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L62>)

```go
func Run(path string, opts ...Option) (*KCLResultList, error)
```

Run evaluates the KCL program with path and opts\, then returns the object list\.

<details><summary>Example (Get Field)</summary>
<p>

```go
{

	x, err := kclvm.Run("./testdata/app0/kcl.yaml")
	assert(err == nil, err)

	fmt.Println(x.First().Get("deploy_topology.1.zone"))

}
```

#### Output

```
RZ24A
```

</p>
</details>

### func [RunFiles](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L67>)

```go
func RunFiles(paths []string, opts ...Option) (*KCLResultList, error)
```

RunFiles evaluates the KCL program with multi file path and opts\, then returns the object list\.

<details><summary>Example</summary>
<p>

```go
{
	result, _ := kclvm.RunFiles([]string{"./testdata/app0/kcl.yaml"})
	fmt.Println(result.First().YAMLString())
}
```

</p>
</details>

## type [KclType](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L48>)

```go
type KclType = kcl.KclType
```

### func [GetSchemaType](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L145>)

```go
func GetSchemaType(file, code, schemaName string) ([]*KclType, error)
```

GetSchemaType returns schema types from a kcl file or code\.

file: string The kcl filename code: string The kcl code string schema\_name: string The schema name got\, when the schema name is empty\, all schemas are returned\.

## type [Option](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L43>)

```go
type Option = kcl.Option
```

### func [WithCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L72>)

```go
func WithCode(codes ...string) Option
```

WithCode returns a Option which hold a kcl source code list\.

### func [WithDisableNone](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L90>)

```go
func WithDisableNone(disableNone bool) Option
```

WithDisableNone returns a Option which hold a disable none switch\.

### func [WithKFilenames](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L75>)

```go
func WithKFilenames(filenames ...string) Option
```

WithKFilenames returns a Option which hold a filenames list\.

### func [WithOptions](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L78>)

```go
func WithOptions(key_value_list ...string) Option
```

WithOptions returns a Option which hold a key=value pair list for option function\.

<details><summary>Example</summary>
<p>

```go
{
	const code = `
name = option("name")
age = option("age")
`
	x, err := kclvm.Run("hello.k", kclvm.WithCode(code),
		kclvm.WithOptions("name=kcl", "age=1"),
	)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(x.First().YAMLString())

}
```

#### Output

```
age: 1
name: kcl
```

</p>
</details>

### func [WithOverrides](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L81>)

```go
func WithOverrides(override_list ...string) Option
```

WithOverrides returns a Option which hold a override list\.

### func [WithPrintOverridesAST](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L93>)

```go
func WithPrintOverridesAST(printOverridesAST bool) Option
```

WithPrintOverridesAST returns a Option which hold a printOverridesAST switch\.

### func [WithSettings](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L84>)

```go
func WithSettings(filename string) Option
```

WithSettings returns a Option which hold a settings file\.

### func [WithWorkDir](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L87>)

```go
func WithWorkDir(workDir string) Option
```

WithWorkDir returns a Option which hold a work dir\.

## type [ValidateOptions](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L44>)

```go
type ValidateOptions = validate.ValidateOptions
```



Generated by [gomarkdoc](<https://github.com/princjef/gomarkdoc>)
