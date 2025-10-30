# Monstarillo Template Knowledge Base

## Template Context Structure

When running a template in Monstarillo, the `.` (dot) points to a `MonstarilloContext` object, NOT directly to table data.

### Key Context Properties

- `.CurrentTable` - The current table being processed
- `.GuiListTables` - Global configuration object
- `.CurrentTable.GuiListTable` - Table-specific GUI configuration

### Correct Template Variable Access

#### ❌ WRONG - Direct access (doesn't work):
```go
{{.GetPascalCaseTableName}}           // Wrong - method doesn't exist on context
{{.ForeignKeyDisplays}}               // Wrong - not on root context
{{.SearchConfig}}                     // Wrong - not on root context
```

#### ✅ CORRECT - Through CurrentTable:
```go
{{.CurrentTable.GetPascalCaseTableName}}           // Correct
{{.CurrentTable.GuiListTable.ForeignKeyDisplays}} // Correct
{{.CurrentTable.GuiListTable.SearchConfig}}       // Correct
```

## Available Methods on CurrentTable

### Table Name Methods
- `.CurrentTable.GetPascalCaseTableName` - "Artist"
- `.CurrentTable.GetCamelCaseTableName` - "artist" 
- `.CurrentTable.GetCamelCaseTableNamePlural` - "artists"
- `.CurrentTable.TableName` - Raw table name from JSON

### Column Methods
- `.CurrentTable.GetJavaFirstPrimaryColumnName` - Gets primary key column name
- `.CurrentTable.GetFirstPrimaryColumn` - Returns column object (for method chaining)

### Data Structure Access
- `.CurrentTable.Columns` - Array of column objects
- `.CurrentTable.GuiListTable.ForeignKeyDisplays` - Array of foreign key display configs
- `.CurrentTable.GuiListTable.SearchConfig` - Search configuration object

## Go Template Method Chaining Limitations

Go templates don't support direct method chaining like `{{.Obj.Method().AnotherMethod()}}`.

#### ❌ WRONG - Method chaining doesn't work:
```go
{{.CurrentTable.GetFirstPrimaryColumn.GetJavascriptDataType}}
```

#### ✅ CORRECT - Use `with` for method chaining:
```go
{{with .CurrentTable.GetFirstPrimaryColumn}}{{.GetJavascriptDataType}}{{end}}
```

## Column Object Methods

When iterating over columns or using `with .CurrentTable.GetFirstPrimaryColumn`:

- `.GetJavascriptDataType` - Returns JS data type (NOT GetTypeScriptDataType)
- `.GetCamelCaseColumnName` - Returns camelCase column name
- `.IsNullable` - Boolean for nullable columns
- `.IsPrimaryKey` - Boolean for primary key columns

## Template Helper Functions

### Available Functions
- `{{makeCamelCase .SomeString}}` - Converts to camelCase
- `{{makePascalCase .SomeString}}` - Converts to PascalCase

### JavaScript Template Literal Handling

#### ❌ WRONG - Triple braces cause parser errors:
```go
`/api/table/${{{.SomeValue}}}`
```

#### ✅ CORRECT - Use whitespace separation:
```go
`/api/table/${ {{- .CurrentTable.GetSomeValue -}} }`
```

## Configuration Data Structure (guilist.json)

### Table Structure
```json
{
  "tables": [
    {
      "tableName": "Artist",
      "foreignKeyDisplays": [...],
      "searchConfig": {
        "searchField": "name",
        "searchFieldType": "string",
        "searchEndpoint": "/search"
      }
    }
  ]
}
```

### Foreign Key Display Structure
```json
{
  "foreignKeyColumn": "ArtistId",
  "referencedTable": "Artist", 
  "displayField": "Name",
  "dtoFieldName": "artistName",
  "dtoFieldType": "String"
}
```

## Common Template Patterns

### Conditional Rendering Based on Foreign Keys
```go
{{if .CurrentTable.GuiListTable.ForeignKeyDisplays}}
  // Code for tables with foreign keys
{{else}}
  // Code for tables without foreign keys  
{{end}}
```

### Iterating Over Foreign Key Displays
```go
{{range .CurrentTable.GuiListTable.ForeignKeyDisplays}}
  {{.ReferencedTable}} - {{.DtoFieldName}}
{{end}}
```

### Iterating Over Columns with Method Access
```go
{{range .CurrentTable.Columns}}
  {{with .}}{{.GetCamelCaseColumnName}}: {{.GetJavascriptDataType}}{{end}}
{{end}}
```

### Building API Endpoints
Instead of using placeholder templates like `{{.GuiListTables.ApiConfig.Endpoints.GetAll}}`, build URLs directly:

```go
// GET /tablename
'/{{.CurrentTable.GetCamelCaseTableName}}'

// GET /tablename/123  
`/{{.CurrentTable.GetCamelCaseTableName}}/${ {{- makeCamelCase .CurrentTable.GetJavaFirstPrimaryColumnName -}} }`
```

## Data Type Considerations

### Search Field Types in JSON
- Use lowercase: `"string"`, `"number"`, `"boolean"`
- Template should handle type conversion as needed

### TypeScript vs JavaScript
- Use `.GetJavascriptDataType` for JavaScript/TypeScript output
- There is no `.GetTypeScriptDataType` method

## Best Practices

1. **Always use `.CurrentTable` prefix** for table-related data
2. **Use `with` blocks** for method chaining on returned objects
3. **Build API endpoints manually** instead of using placeholder templates
4. **Test template syntax** with simple examples before complex logic
5. **Use helper functions** like `makeCamelCase` and `makePascalCase` for consistent naming
6. **Handle nullable types** appropriately in generated code
7. **Separate common types** from table-specific types in imports

## Template File Structure

### Service Template Pattern
```go
import api from './api'
import type { {{.CurrentTable.GetPascalCaseTableName}}, ... } from '../types/{{.CurrentTable.GetPascalCaseTableName}}'
import type { ApiResponse, SearchParams } from '../types/common'
{{range .CurrentTable.GuiListTable.ForeignKeyDisplays}}import type { {{makePascalCase .ReferencedTable}} } from '../types/{{makePascalCase .ReferencedTable}}'
{{end}}

export const {{.CurrentTable.GetCamelCaseTableName}}Service = {
  // CRUD operations using built URLs
}
```

This knowledge base should help maintain consistency across template development and avoid common pitfalls when working with the Monstarillo template system.

---

# Complete MonstarilloContext API Reference

## Root Context Properties

### `.CurrentTable` (models.Table)
The current table being processed in the template.

### `.CurrentGuiTable` (models.GuiListTable) 
The GUI configuration for the current table.

### `.Tables` ([]models.Table)
Array of all tables in the database schema.

### `.Tags` ([]models.Tag)
Array of custom tags for template processing.

### `.UnitTestValuesFile` (string)
Path to unit test values configuration file.

### `.GuiListTables` (models.GuiListTables)
Complete GUI configuration including API endpoints, routing, and component configs.

## Table Methods (.CurrentTable.*)

### Basic Table Information
```go
.CurrentTable.TableName                    // Raw table name from database
.CurrentTable.DatabaseType                 // "mysql", "postgres", etc.
.CurrentTable.GetTableName()              // Returns table name
.CurrentTable.GetCamelCaseTableName()     // "artist"
.CurrentTable.GetPascalCaseTableName()    // "Artist"
.CurrentTable.GetCamelCaseTableNamePlural()   // "artists" 
.CurrentTable.GetPascalCaseTableNamePlural()  // "Artists"
.CurrentTable.GetCamelCaseTableNameEF()       // Singular camelCase (Entity Framework)
.CurrentTable.GetPascalCaseTableNameEF()      // Singular PascalCase (Entity Framework)
```

### Primary Key Methods
```go
.CurrentTable.GetPrimaryColumns()                          // []Column - all primary key columns
.CurrentTable.GetFirstPrimaryColumn()                      // *Column - first primary key column
.CurrentTable.GetFirstPrimaryColumnJavaDataType()          // Java data type of first PK
.CurrentTable.GetFirstPrimaryColumnCamelCaseColumnName()   // camelCase name of first PK
.CurrentTable.GetFirstPrimaryColumnPascalCaseColumnName()  // PascalCase name of first PK
.CurrentTable.GetJavaFirstPrimaryColumnName()              // Raw column name of first PK
.CurrentTable.GetPrimaryColumnJavaTypesAndVariables()      // "Long id, String name" format
.CurrentTable.GetPrimaryColumnVariables()                  // "id, name" format
.CurrentTable.HasCompositePrimaryKey()                     // bool - multiple primary keys
```

### Column Access Methods
```go
.CurrentTable.Columns                           // []Column - all columns
.CurrentTable.GetNonPrimaryColumns()           // []Column - non-primary columns
.CurrentTable.GetFirstNonPrimaryColumn()       // Column - first non-primary column
.CurrentTable.GetNullableColumns()             // []Column - nullable columns
.CurrentTable.GetPrimaryNonDateColumns()       // []Column - PK columns excluding dates
```

### Column Type Checking Methods
```go
.CurrentTable.HasJavascriptStringColumn()       // bool - has String columns
.CurrentTable.HasJavascriptNumberColumn()       // bool - has Number columns  
.CurrentTable.HasJavaTypeColumn("String")       // bool - has specific Java type
.CurrentTable.HasAutoIncrementColumn()          // bool - has auto-increment
.CurrentTable.HasAnyDateColumn()               // bool - has date/datetime/timestamp
.CurrentTable.HasDateColumn()                  // bool - has date columns
.CurrentTable.HasDateTimeColumn()              // bool - has datetime columns
.CurrentTable.HasTimestampColumn()             // bool - has timestamp columns
.CurrentTable.HasYearColumn()                  // bool - has year columns
```

### Foreign Key Methods
```go
.CurrentTable.ForeignKeys                       // []ForeignKey - all foreign key relationships
.CurrentTable.ReferencedForeignKeys            // []ForeignKey - tables referencing this one
.CurrentTable.GetFkTableNameForColumn("artistId")  // Returns referenced table name
```

### Unit Test Value Methods
```go
.CurrentTable.GetJavaFirstPrimaryUnitTestValue()    // First test value for PK
.CurrentTable.GetJavaSecondPrimaryUnitTestValue()   // Second test value for PK
.CurrentTable.GetCSharpFirstPrimaryUnitTestValue()  // C# first test value
.CurrentTable.GetCSharpSecondPrimaryUnitTestValue() // C# second test value
.CurrentTable.GetFirstPrimarySetString()           // Set string for first PK
```

### Advanced Methods
```go
.CurrentTable.GetColumnListWithCSharpTypes()       // "string name, int id" format
.CurrentTable.GetTableNameInCase("camel")          // Get table name in specific case
```

## Column Methods (when using .CurrentTable.GetFirstPrimaryColumn() or iterating)

### Basic Column Information
```go
.ColumnName                    // Raw column name
.DataType                      // Database data type
.DatabaseType                  // "mysql", "postgres", etc.
.TableName                     // Table this column belongs to
.IsPrimaryKey                  // bool
.IsNullable                    // bool
.IsAutoIncrement              // bool
.IsForeignKey                 // bool
.OrdinalPosition              // int - column position
.NumericPrecision             // int
.NumericScale                 // int
.CharacterMaximumLength       // int
```

### Column Name Formatting
```go
.GetCamelCaseColumnName()      // "artistId"
.GetPascalCaseColumnName()     // "ArtistId"  
.GetTitleCaseColumnName()      // "Artist Id"
.GetColumnNameInCase("camel")  // Custom case formatting
```

### Data Type Methods
```go
.GetJavascriptDataType()       // "string", "number", "boolean"
.GetJavascriptDefaultValue()   // Default value for JS
.GetJavaDataType()            // "String", "Integer", "Long"
.GetCSharpDataType()          // "string", "int", "long"
.GetGoDataType()              // "string", "int64", "bool"
```

### Unit Test Methods
```go
.GetJavaFirstUnitTestValue()           // "1L", "\"test\""
.GetJavaSecondUnitTestValue()          // "2L", "\"test2\""
.GetCSharpFirstUnitTestValue()         // "1", "\"test\""
.GetCSharpSecondUnitTestValue()        // "2", "\"test2\""
.GetGoFirstUnitTestValue()             // "1", "\"test\""
.GetGoSecondUnitTestValue()            // "2", "\"test2\""
```

### Type Checking Methods
```go
.IsBinary()                    // bool - byte[] type
.IsGoIntFamilyType()          // bool - Go integer types
```

## GUI Configuration (.CurrentTable.GuiListTable.*)

### Foreign Key Display Configuration
```go
.CurrentTable.GuiListTable.ForeignKeyDisplays    // []ForeignKeyDisplay
```

#### ForeignKeyDisplay Properties
```go
.ForeignKeyColumn      // "ArtistId"
.ReferencedTable      // "Artist"
.DisplayField         // "Name"
.DtoFieldName         // "artistName"
.DtoFieldType         // "String"
.ShowInList          // bool
.ShowInDetail        // bool
```

### Search Configuration  
```go
.CurrentTable.GuiListTable.SearchConfig         // *SearchConfig (can be nil)
.CurrentTable.GuiListTable.SearchConfig.IsSearchable     // bool
.CurrentTable.GuiListTable.SearchConfig.SearchField      // "name"
.CurrentTable.GuiListTable.SearchConfig.SearchFieldType  // "string"
.CurrentTable.GuiListTable.SearchConfig.SearchEndpoint   // "/search"
```

### Service Configuration
```go
.CurrentTable.GuiListTable.ServiceConfig                    // ServiceConfig
.CurrentTable.GuiListTable.ServiceConfig.UseJoinedQueries   // bool
.CurrentTable.GuiListTable.ServiceConfig.EnableSearch       // bool
```

### GUI Column Configurations
```go
.CurrentTable.GuiListTable.GuiList          // List view columns
.CurrentTable.GuiListTable.GuiEdit          // Edit form columns  
.CurrentTable.GuiListTable.GuiView          // View/detail columns
.CurrentTable.GuiListTable.GuiCreate        // Create form columns
.CurrentTable.GuiListTable.TableName        // Table name
.CurrentTable.GuiListTable.AllowAttachedFiles  // bool
```

#### GuiListColumn Properties (in GuiList.Columns[], GuiEdit.Columns[], etc.)
```go
.ColumnName             // "ArtistId"
.Title                 // "Artist ID"
.Value                 // "artistId"
.GuiControl           // "BaseInput", "BaseSelect"
.SelectOptions        // " artistId_Artist"
.SelectKey           // "artistId"
.SelectValue         // "name"
.SelectTableName     // "Artist"
.IsForeignKeyDisplay // bool
```

### GUI Methods
```go
.CurrentTable.GuiListTable.HasGuiControl("BaseSelect")           // bool
.CurrentTable.GuiListTable.GetEditGuiControlForColumn("name")    // "BaseInput"
.CurrentTable.GuiListTable.GetEditSelectKeyForColumn("artistId") // "artistId"
.CurrentTable.GuiListTable.GetEditSelectValueForColumn("artistId") // "name"
```

## Global Configuration (.GuiListTables.*)

### API Configuration
```go
.GuiListTables.ApiConfig                    // ApiConfig
.GuiListTables.ApiConfig.BaseUrl           // "/api"
.GuiListTables.ApiConfig.Endpoints         // Endpoints struct
.GuiListTables.ApiConfig.Endpoints.GetAll  // "GET /{tableName}"
.GuiListTables.ApiConfig.Endpoints.GetById // "GET /{tableName}/{id}"
.GuiListTables.ApiConfig.Endpoints.Create  // "POST /{tableName}"
.GuiListTables.ApiConfig.Endpoints.Update  // "PUT /{tableName}/{id}"
.GuiListTables.ApiConfig.Endpoints.Delete  // "DELETE /{tableName}/{id}"
.GuiListTables.ApiConfig.Endpoints.Search  // "GET /{tableName}/search"
```

### Route Configuration  
```go
.GuiListTables.RouteConfig                      // RouteConfig
.GuiListTables.RouteConfig.BasePath            // "/{tableName}s"
.GuiListTables.RouteConfig.RouteNames          // RouteNames struct
.GuiListTables.RouteConfig.RouteNames.List     // "{TableName}List"
.GuiListTables.RouteConfig.RouteNames.View     // "{TableName}View"
.GuiListTables.RouteConfig.RouteNames.Edit     // "{TableName}Edit"
.GuiListTables.RouteConfig.RouteNames.Create   // "{TableName}Create"
```

### Component Configuration
```go
.GuiListTables.ComponentConfig                 // ComponentConfig
.GuiListTables.ComponentConfig.BasePath       // "@/components/{tableName}"
.GuiListTables.ComponentConfig.Imports        // map[string]string
```

### Data Type Configuration
```go
.GuiListTables.DataTypeConfig                  // DataTypeConfig
.GuiListTables.DataTypeConfig.Date            // "BaseDatepicker"
.GuiListTables.DataTypeConfig.DateTime        // "BaseDatepickerWithTime"
.GuiListTables.DataTypeConfig.Boolean         // "BaseCheckbox"
.GuiListTables.DataTypeConfig.Text            // "BaseTextarea"
.GuiListTables.DataTypeConfig.ForeignKey      // "BaseSelect"
```

## Foreign Key Methods (.CurrentTable.ForeignKeys[].*)

### Foreign Key Information
```go
.ConstraintName           // "fk_album_artist"
.FkTableName             // "Album"
.FkColumnName            // "ArtistId" 
.PkTableName             // "Artist"
.PkColumnName            // "ArtistId"
.Relation                // Relationship type
.FkColumn                // Column object
.PkColumn                // Column object
```

### Foreign Key Name Formatting
```go
.GetCamelCaseFKTableName()        // "album"
.GetPascalCaseFKTableName()       // "Album"
.GetCamelCaseFKColumnName()       // "artistId"
.GetPascalCaseFKColumnName()      // "ArtistId"
.GetCamelCasePKTableName()        // "artist" 
.GetPascalCasePKTableName()       // "Artist"
.GetCamelCasePKColumnName()       // "artistId"
.GetPascalCasePKColumnName()      // "ArtistId"
```

### Foreign Key Plural Methods
```go
.GetCamelCaseFKTableNamePlural()      // "albums"
.GetPascalCaseFKTableNamePlural()     // "Albums"
.GetCamelCasePKTableNamePlural()      // "artists"
.GetPascalCasePKTableNamePlural()     // "Artists"
```

## Context Helper Methods

### Context-Level Methods
```go
.GetColumn("Artist", "Name")          // Get specific column
.GetTable("Artist")                   // Get specific table
.GetFkTableName("Album", "ArtistId")  // Get FK referenced table
.GetFkTableNamePlural("Album", "ArtistId")  // Get FK table plural
```

## Template Helper Functions

### Case Conversion Functions
```go
{{makeCamelCase "ArtistName"}}        // "artistName"
{{makePascalCase "artist_name"}}      // "ArtistName"
{{ToUpper "hello"}}                   // "HELLO"
{{ToLower "HELLO"}}                   // "hello"
{{makePlural "artist"}}               // "artists"
```

### Table Helper Functions
```go
{{getTable "Artist"}}                 // Get table by name
{{getTableFirstPk "Artist"}}          // Get first primary key column name
{{getTableSecondColumn "Artist"}}     // Get second column name
{{FindTableByName .Tables "Artist"}}  // Find table in collection
```

### GUI Helper Functions
```go
{{GetEditSelectKeyForColumn "Artist" "name"}}    // Get select key for column
{{GetEditSelectValueForColumn "Artist" "name"}}  // Get select value for column
{{getColumnCountByDataType "Artist" "varchar"}}  // Count columns by type
```

### Go-Specific Functions
```go
{{GetGoParseIntConversionSuffix "int64"}}         // ", 10, 64)"
{{GoIntCast "value" "int32"}}                     // "int32(value)"
```

### Tag Functions
```go
{{getTag .Tags "apiVersion"}}         // Get custom tag value
```

## Best Practices Summary

1. **Always prefix with `.CurrentTable`** for current table data
2. **Use `.CurrentTable.GuiListTable`** for GUI configurations
3. **Use helper functions** like `makeCamelCase` for consistent formatting
4. **Check for nil pointers** on SearchConfig: `{{if .CurrentTable.GuiListTable.SearchConfig}}`
5. **Use `with` blocks** for method chaining: `{{with .CurrentTable.GetFirstPrimaryColumn}}{{.GetJavascriptDataType}}{{end}}`
6. **Build URLs manually** instead of using placeholder templates
7. **Handle foreign key relationships** through ForeignKeyDisplays array
8. **Access global configs** through .GuiListTables for API endpoints and routing

This comprehensive reference should cover all available options in the MonstarilloContext for template development.