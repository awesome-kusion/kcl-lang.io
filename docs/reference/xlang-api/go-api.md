---
sidebar_position: 3
---

# Go API

```go
import "kcl-lang.io/kcl-go"
```

## KCL Go SDK

```
┌─────────────────┐         ┌─────────────────┐           ┌─────────────────┐
│     kcl files   │         │   KCL-Go-API    │           │  KCLResultList  │
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
name = "kcl"
age = 1

two = 2

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
	- [Constants](#constants)
	- [func FormatCode](#func-formatcode)
	- [func FormatPath](#func-formatpath)
	- [func InitKclvmPath](#func-initkclvmpath)
	- [func InitKclvmRuntime](#func-initkclvmruntime)
	- [func LintPath](#func-lintpath)
	- [func ListDepFiles](#func-listdepfiles)
	- [func ListDownStreamFiles](#func-listdownstreamfiles)
	- [func ListUpStreamFiles](#func-listupstreamfiles)
	- [func OverrideFile](#func-overridefile)
	- [func ValidateCode](#func-validatecode)
	- [type KCLResult](#type-kclresult)
	- [type KCLResultList](#type-kclresultlist)
		- [func MustRun](#func-mustrun)
		- [func Run](#func-run)
		- [func RunFiles](#func-runfiles)
	- [type KclType](#type-kcltype)
		- [func GetSchemaType](#func-getschematype)
	- [type ListDepFilesOption](#type-listdepfilesoption)
	- [type ListDepsOptions](#type-listdepsoptions)
	- [type Option](#type-option)
		- [func WithCode](#func-withcode)
		- [func WithDisableNone](#func-withdisablenone)
		- [func WithKFilenames](#func-withkfilenames)
		- [func WithOptions](#func-withoptions)
		- [func WithOverrides](#func-withoverrides)
		- [func WithPrintOverridesAST](#func-withprintoverridesast)
		- [func WithSettings](#func-withsettings)
		- [func WithSortKeys](#func-withsortkeys)
		- [func WithWorkDir](#func-withworkdir)
	- [type ValidateOptions](#type-validateoptions)


## Constants

KclvmAbiVersion is the current kclvm ABI version.

```go
const KclvmAbiVersion = scripts.KclvmAbiVersion
```

## func [FormatCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L110>)

```go
func FormatCode(code interface{}) ([]byte, error)
```

FormatCode returns the formatted code.

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



```
a = 1 + 2
```

</p>
</details>

## func [FormatPath](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L122>)

```go
func FormatPath(path string) (changedPaths []string, err error)
```

FormatPath formats files from the given path path: if path is \`.\` or empty string, all KCL files in current directory will be formatted, not recursively if path is \`path/file.k\`, the specified KCL file will be formatted if path is \`path/to/dir\`, all KCL files in the specified dir will be formatted, not recursively if path is \`path/to/dir/...\`, all KCL files in the specified dir will be formatted recursively

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

## func [InitKclvmPath](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L54>)

```go
func InitKclvmPath(kclvmRoot string)
```

InitKclvmPath init kclvm path.

## func [InitKclvmRuntime](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L59>)

```go
func InitKclvmRuntime(n int)
```

InitKclvmRuntime init kclvm process.

## func [LintPath](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L142>)

```go
func LintPath(paths []string) (results []string, err error)
```

LintPath lint files from the given path

<details><summary>Example</summary>
<p>

```go
{

	results, err := kclvm.LintPath([]string{"testdata/lint/import.k"})
	if err != nil {
		log.Fatal(err)
	}
	for _, s := range results {
		fmt.Println(s)
	}

}
```



```
Module 'a' is reimported multiple times
Module 'a' imported but unused
```

</p>
</details>

## func [ListDepFiles](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L127>)

```go
func ListDepFiles(workDir string, opt *ListDepFilesOption) (files []string, err error)
```

ListDepFiles return the depend files from the given path

## func [ListDownStreamFiles](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L137>)

```go
func ListDownStreamFiles(workDir string, opt *ListDepsOptions) ([]string, error)
```

ListDownStreamFiles return a list of downstream depend files from the given changed path list.

## func [ListUpStreamFiles](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L132>)

```go
func ListUpStreamFiles(workDir string, opt *ListDepsOptions) (deps []string, err error)
```

ListUpStreamFiles return a list of upstream depend files from the given path list

## func [OverrideFile](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L154>)

```go
func OverrideFile(file string, specs, importPaths []string) (bool, error)
```

OverrideFile rewrites a file with override spec file: string. The File that need to be overridden specs: \[\]string. List of specs that need to be overridden.

```
Each spec string satisfies the form: <pkgpath>:<field_path>=<filed_value> or <pkgpath>:<field_path>-
When the pkgpath is '__main__', it can be omitted.
```

importPaths. List of import statements that need to be added

## func [ValidateCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L159>)

```go
func ValidateCode(data, code string, opt *ValidateOptions) (ok bool, err error)
```

ValidateCode validate data match code

## type [KCLResult](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L47>)

```go
type KCLResult = kcl.KCLResult
```

<details><summary>Example</summary>
<p>

```go
{
	const k_code = `
name = "kcl"
age = 1
	
two = 2
	
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



```
person: &{Name:kcl Age:101}
person: {Name:kcl Age:101}
```

</p>
</details>

## type [KCLResultList](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L48>)

```go
type KCLResultList = kcl.KCLResultList
```

### func [MustRun](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L64>)

```go
func MustRun(path string, opts ...Option) *KCLResultList
```

MustRun is like Run but panics if return any error.

<details><summary>Example</summary>
<p>

```go
{
	yaml := kclvm.MustRun("testdata/main.k", kclvm.WithCode(`name = "kcl"`)).First().YAMLString()
	fmt.Println(yaml)

}
```



```
name: kcl
```

</p>
</details>

<details><summary>Example (Raw Yaml)</summary>
<p>

```go
{
	const code = `
b = 1
a = 2
`
	yaml := kclvm.MustRun("testdata/main.k", kclvm.WithCode(code)).GetRawYamlResult()
	fmt.Println(yaml)

	yaml_sorted := kclvm.MustRun("testdata/main.k", kclvm.WithCode(code), kclvm.WithSortKeys(true)).GetRawYamlResult()
	fmt.Println(yaml_sorted)

}
```



```
b: 1
a: 2
a: 2
b: 1
```

</p>
</details>

<details><summary>Example (Schema Type)</summary>
<p>

```go
{
	const code = `
schema Person:
	name: str = ""

x = Person()
`
	json := kclvm.MustRun("testdata/main.k", kclvm.WithCode(code)).First().JSONString()
	fmt.Println(json)

}
```



```
{
    "x": {
        "name": ""
    }
}
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

### func [Run](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L69>)

```go
func Run(path string, opts ...Option) (*KCLResultList, error)
```

Run evaluates the KCL program with path and opts, then returns the object list.

<details><summary>Example (Get Field)</summary>
<p>

```go
{

	x, err := kclvm.Run("./testdata/app0/kcl.yaml")
	assert(err == nil, err)

	fmt.Println(x.First().Get("deploy_topology.1.zone"))

}
```



```
R000A
```

</p>
</details>

### func [RunFiles](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L74>)

```go
func RunFiles(paths []string, opts ...Option) (*KCLResultList, error)
```

RunFiles evaluates the KCL program with multi file path and opts, then returns the object list.

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

## type [KclType](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L50>)

```go
type KclType = kcl.KclType
```

### func [GetSchemaType](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L176>)

```go
func GetSchemaType(file, code, schemaName string) ([]*KclType, error)
```

GetSchemaType returns schema types from a kcl file or code.

file: string

```
The kcl filename
```

code: string

```
The kcl code string
```

schema\_name: string

```
The schema name got, when the schema name is empty, all schemas are returned.
```

## type [ListDepFilesOption](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L45>)

```go
type ListDepFilesOption = list.Option
```

## type [ListDepsOptions](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L44>)

```go
type ListDepsOptions = list.DepOptions
```

## type [Option](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L43>)

```go
type Option = kcl.Option
```

### func [WithCode](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L79>)

```go
func WithCode(codes ...string) Option
```

WithCode returns a Option which hold a kcl source code list.

### func [WithDisableNone](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L97>)

```go
func WithDisableNone(disableNone bool) Option
```

WithDisableNone returns a Option which hold a disable none switch.

### func [WithKFilenames](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L82>)

```go
func WithKFilenames(filenames ...string) Option
```

WithKFilenames returns a Option which hold a filenames list.

### func [WithOptions](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L85>)

```go
func WithOptions(key_value_list ...string) Option
```

WithOptions returns a Option which hold a key=value pair list for option function.

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



```
age: 1
name: kcl
```

</p>
</details>

### func [WithOverrides](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L88>)

```go
func WithOverrides(override_list ...string) Option
```

WithOverrides returns a Option which hold a override list.

### func [WithPrintOverridesAST](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L100>)

```go
func WithPrintOverridesAST(printOverridesAST bool) Option
```

WithPrintOverridesAST returns a Option which hold a printOverridesAST switch.

### func [WithSettings](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L91>)

```go
func WithSettings(filename string) Option
```

WithSettings returns a Option which hold a settings file.

### func [WithSortKeys](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L105>)

```go
func WithSortKeys(sortKeys bool) Option
```

WithSortKeys returns a Option which hold a sortKeys switch.

### func [WithWorkDir](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L94>)

```go
func WithWorkDir(workDir string) Option
```

WithWorkDir returns a Option which hold a work dir.

## type [ValidateOptions](<https://github.com/kcl-lang/kcl-go/blob/main/kclvm.go#L46>)

```go
type ValidateOptions = validate.ValidateOptions
```
